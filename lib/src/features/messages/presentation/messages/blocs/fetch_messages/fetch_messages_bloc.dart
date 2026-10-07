import 'dart:async';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/database/app_database.dart' as db;
import 'package:general/src/core/realtime/chat_repository.dart';
import 'package:general/src/core/realtime/realtime_client.dart';
import 'package:general/src/features/chats/presentation/chats/bloc/manager_get_users_chat/get_users_chat_bloc.dart';
import 'package:general/src/features/messages/data/mappers/drift_message_mapper.dart';
import 'package:general/src/features/messages/messages.dart';
import 'package:general/src/features/messages/presentation/messages/view/messages_page.dart';

part 'fetch_messages_event.dart';
part 'fetch_messages_state.dart';

class FetchMessagesBloc
    extends Bloc<BaseFetchMessagesEvent, FetchMessagesState> {
  final CloseChatUC _closeChatUC;

  // Offline/realtime transport (Centrifugo + drift). legacy realtime is fully removed,
  // so this is the ONLY chat transport — required, not optional.
  final ChatRepository _chatRepo;
  final RealtimeClient _realtimeClient;

  StreamSubscription<List<db.Message>>? _driftSub;
  VoidCallback? _scrollCallback;

  // Realtime-path bookkeeping.
  int _roomLocalId = 0;
  List<db.Message> _liveWindow = const [];
  final List<db.Message> _olderPages = [];
  int? _oldestSeq;
  bool _reachedTop = false;
  bool _isLoadingOlder = false;
  // Server room id of the open conversation (for the durable read receipt path).
  int _serverRoomId = 0;
  // Highest seq already reported to the backend as read, so the durable receipt
  // is re-issued from the LIVE high-water-mark (not the possibly-stale/0 open-
  // time snapshot) and only when it actually advances (debounce).
  int _lastRemoteReadSeqSent = 0;

  FetchMessagesBloc(
    this._closeChatUC,
    this._chatRepo,
    this._realtimeClient,
  ) : super(
          FetchMessagesState(scrollController: ScrollController()),
        ) {
    on<FetchMessagesEvent>(_fetchMessageEvent);
    on<AddListenerEvent>(_addListenerEvent);
    on<RemoveListenerEvent>(_removeListenerEvent);
    on<RetrySendMessageEvent>(_retrySendMessageEvent);
    on<CloseMessagesEvent>(_closeMessagesEvent);
    on<LocalDeleteMessagesEvent>(_localDeleteMessagesEvent);
    on<LocalUpdateReactMessagesEvent>(_reactEvent);
    on<FinishUploadingVideoEvent>(_finishUploadingVideoEvent);
    on<RealtimeMessagesUpdatedEvent>(_onRealtimeUpdated);
    on<ClearJumpTargetEvent>(_clearJumpTargetEvent);
  }

  // === realtime/offline transport ===========================================

  int get _meId => MyDataModel.getInstance().id ?? 0;

  /// Open a 1:1 conversation over the drift/realtime stack: pull the REST delta,
  /// bind the local newest-first stream, and subscribe the live channel. The UI
  /// renders entirely from the stream (offline-first), so it survives reconnects.
  Future<void> _openRealtime(
    FetchMessagesEvent event,
    Emitter<FetchMessagesState> emit,
  ) async {
    var serverRoomId = event.params.chatId ?? 0;
    final userId = event.params.userId ?? state.userId;

    // Set the "currently open chat" marker BEFORE any await — otherwise an
    // incoming message for this same room that lands during the async open
    // window would wrongly bump the unread counter (the guard checks this id).
    di<FetchUsersChatBloc>().currentChatId = serverRoomId;

    emit(state.copyWith(
      reqState: RequestState.loading,
      isPagination: false,
      currentPage: 1,
      data: const [],
      userId: userId,
      chatId: serverRoomId,
      // Carry the search-jump target so the UI can scroll+highlight once the
      // first window renders (null on a normal open).
      moveToMessage: event.params.messageIdToMove != null,
      messageIdToMove: event.params.messageIdToMove,
    ));

    _olderPages.clear();
    _liveWindow = const [];
    _oldestSeq = null;
    _reachedTop = false;
    _serverRoomId = serverRoomId;
    _lastRemoteReadSeqSent = 0;
    // Reset the paging guard on every open; a stale `true` left over from a
    // previous conversation (or an interrupted older-page load) would otherwise
    // freeze pagination for this room forever.
    _isLoadingOlder = false;

    final repo = _chatRepo;
    final peerId = int.tryParse(userId);

    // Instant-open: resolve (or create) the local room row only — a fast local
    // upsert — then bind the drift stream so cached messages render immediately.
    // The REST delta is pulled in the BACKGROUND (no await) so a slow/offline
    // server never blocks the first paint; the stream re-renders when it lands.
    RoomRef ref;
    try {
      final localId = await repo.ensureDmRoom(
        serverRoomId: serverRoomId,
        peerUserId: peerId,
      );
      ref = RoomRef(localId: localId, serverRoomId: serverRoomId);
    } catch (_) {
      final existing = await repo.roomByServerId(serverRoomId);
      if (existing == null) {
        emit(state.copyWith(reqState: RequestState.error));
        return;
      }
      ref = existing;
    }
    _roomLocalId = ref.localId;

    // Bind the drift stream FIRST so cached messages paint immediately, before
    // the (network) server-room-id resolution below — the open never blocks on it.
    await _driftSub?.cancel();
    _driftSub = repo
        .watchMessages(ref.localId)
        .listen((msgs) => add(RealtimeMessagesUpdatedEvent(msgs)));

    // Opening the conversation = everything is read → clear the unread badge now
    // (the list reads the same drift room, so the count disappears immediately).
    await repo.clearUnread(ref.localId);

    // Resolve the REAL server room id when the open didn't carry one (opened from
    // a profile / friend picker / agency / search / moment / meet — none of which
    // know the chat_id). The legacy path got-or-created the room via POST
    // /Chat-room and threaded its id; the offline-first open dropped that step, so
    // every server hop below ran against room 0 (sync 404 "Room not found", read
    // receipt on /Chat-room/0/read). Re-introduce it via the lightweight
    // get-or-create endpoint, then re-link the drift room to the real id (folding
    // the peer-keyed orphan + migrating its messages). When it can't be resolved
    // (offline / failure -> 0) we skip the server-dependent steps and rely on the
    // local stream + the next rooms-list sync to upgrade the room, instead of
    // firing them against room 0.
    if (serverRoomId <= 0 && peerId != null && peerId > 0) {
      final resolved = await repo.resolveServerRoomId(peerUserId: peerId);
      if (resolved > 0) {
        serverRoomId = resolved;
        _serverRoomId = resolved;
        di<FetchUsersChatBloc>().currentChatId = resolved;
        // Re-bind the drift room to the real server id. getOrCreateDmRoom folds
        // the orphan (serverRoomId 0) row into the real room and migrates its
        // messages, so the local id may change — re-point the stream + state.
        try {
          final relinked = await repo.ensureDmRoom(
            serverRoomId: resolved,
            peerUserId: peerId,
          );
          if (relinked != ref.localId) {
            ref = RoomRef(localId: relinked, serverRoomId: resolved);
            _roomLocalId = relinked;
            await _driftSub?.cancel();
            _driftSub = repo
                .watchMessages(ref.localId)
                .listen((msgs) => add(RealtimeMessagesUpdatedEvent(msgs)));
            await repo.clearUnread(ref.localId);
          }
        } catch (_) {/* keep the local-first room; sync will upgrade it later */}
        emit(state.copyWith(chatId: resolved));
      }
    }

    // From here on, only run the server-dependent steps when we actually hold a
    // real room id. With a 0 id they would 404 (sync/read) or no-op; the local
    // stream already renders and the rooms-list sync will materialize the id.
    final hasServerRoom = serverRoomId > 0;

    if (hasServerRoom) {
      // Dual mark-read: tell the backend the room is read (durable outbox POST),
      // regardless of transport, so the server counter doesn't bounce back on the
      // next refetch. Carries the room's read high-water-mark so the backend
      // persists the cursor (and re-broadcasts the seen receipt) at the right seq.
      // Best-effort — the local badge is already cleared above.
      final readSeq = await repo.roomLastSeq(ref.localId);
      repo
          .markReadRemote(
            roomLocalId: ref.localId,
            readPath: EndPoints.markRoomRead(serverRoomId),
            upToSeq: readSeq,
          )
          .catchError((_) {});

      // Cold-open backfill: pull the newest history page (before_seq) so a
      // conversation with an empty/sparse local cache still shows recent messages
      // immediately — the drift stream above re-renders when it lands. (since_seq
      // alone returns nothing once the forward cursor has passed the local rows,
      // which left DMs opening empty.)
      repo
          .backfillLatest(roomLocalId: ref.localId, serverRoomId: serverRoomId)
          .catchError((_) => 0);

      // Background catch-up: pull the REST delta after the local-first render.
      // Failures are non-fatal — the cached window stands on its own.
      repo
          .syncRoom(roomLocalId: ref.localId, serverRoomId: serverRoomId)
          .catchError((_) => 0);
    }

    try {
      await _realtimeClient.openChat(
        peerUserId: peerId ?? 0,
        roomLocalId: ref.localId,
        serverRoomId: serverRoomId,
      );
    } catch (_) {/* realtime optional; local-first path stands alone */}

    di<FetchUsersChatBloc>().currentChatId = serverRoomId;
    di<FetchUsersChatBloc>().add(ReadMessageEvent(
      chatId: serverRoomId,
      userId: userId,
    ));
  }

  void _onRealtimeUpdated(
    RealtimeMessagesUpdatedEvent event,
    Emitter<FetchMessagesState> emit,
  ) {
    _liveWindow = event.messages;
    final merged = _mergeWindows();
    _oldestSeq = merged
        .map((m) => m.serverSeq)
        .whereType<int>()
        .fold<int?>(null, (min, s) => min == null || s < min ? s : min);

    final mapped = merged
        .map((m) =>
            DriftMessageMapper.toEntity(m, currentUserId: _meId, chatId: state.chatId))
        .toList();

    // Media (image/voice/video) now writes its optimistic row to drift via
    // ChatRepository.send/sendMedia (isLocal:true attachment), so the in-flight
    // bubble already arrives in this window — no in-memory bubbles to preserve.

    emit(state.copyWith(
      data: mapped,
      isPagination: false,
      reqState: mapped.isEmpty ? RequestState.empty : RequestState.loaded,
      // Keep the search-jump target alive across stream re-renders until the UI
      // has actually scrolled to it; the page clears it once the jump runs.
      moveToMessage: state.moveToMessage,
      messageIdToMove: state.messageIdToMove,
    ));

    // The conversation is on screen, so everything up to the newest seq is read.
    // Mark the drift room read so its unread badge clears in the chats list
    // (which now reads the same room row) — both on open and on live arrivals.
    final maxSeq = _liveWindow
        .map((m) => m.serverSeq)
        .whereType<int>()
        .fold<int>(0, (mx, s) => s > mx ? s : mx);
    if (maxSeq > 0 && _roomLocalId > 0) {
      _chatRepo.markRead(roomLocalId: _roomLocalId, upToSeq: maxSeq);

      // Re-issue the DURABLE backend read receipt from the LIVE high-water-mark.
      // The open-time receipt in [_openRealtime] uses the room's open-time
      // snapshot, which is 0/stale for a freshly-opened room (its seqs only land
      // once the stream/sync fills in), so the server unread counter bounced
      // back on the next refetch. Debounced on the seq actually advancing so a
      // status-only emission (read/reaction) doesn't re-POST the same seq.
      if (maxSeq > _lastRemoteReadSeqSent && _serverRoomId > 0) {
        _lastRemoteReadSeqSent = maxSeq;
        _chatRepo
            .markReadRemote(
              roomLocalId: _roomLocalId,
              readPath: EndPoints.markRoomRead(_serverRoomId),
              upToSeq: maxSeq,
            )
            .catchError((_) {});
      }
    }
  }

  /// Drop the search-jump target once the UI has scrolled to it. `copyWith`
  /// can't null these fields, so rebuild the state preserving everything else.
  void _clearJumpTargetEvent(
    ClearJumpTargetEvent event,
    Emitter<FetchMessagesState> emit,
  ) {
    if (state.messageIdToMove == null && state.moveToMessage == null) return;
    emit(FetchMessagesState(
      data: state.data,
      userId: state.userId,
      room: state.room,
      reqState: state.reqState,
      moveToMessage: null,
      messageIdToMove: null,
      isPagination: state.isPagination,
      chatId: state.chatId,
      scrollController: state.scrollController,
      currentPage: state.currentPage,
      lastPage: state.lastPage,
    ));
  }

  /// Live newest-first window + older keyset pages, de-duplicated by client_uuid
  /// and re-sorted (pending null-seq rows stay on top, mirroring the DAO order).
  List<db.Message> _mergeWindows() {
    if (_olderPages.isEmpty) return _liveWindow;
    final byUuid = <String, db.Message>{};
    for (final m in _olderPages) {
      byUuid[m.clientUuid] = m;
    }
    for (final m in _liveWindow) {
      byUuid[m.clientUuid] = m; // live wins (freshest state)
    }
    final all = byUuid.values.toList()
      ..sort((a, b) {
        final sa = a.serverSeq;
        final sb = b.serverSeq;
        if (sa == null && sb == null) {
          return b.createdAtClient.compareTo(a.createdAtClient);
        }
        if (sa == null) return -1;
        if (sb == null) return 1;
        return sb.compareTo(sa);
      });
    return all;
  }

  Future<void> _loadOlderRealtime(Emitter<FetchMessagesState> emit) async {
    // Also bail when the room isn't resolved yet (roomLocalId == 0): a scroll
    // that fires during the open race would otherwise keyset-page against room 0.
    if (_isLoadingOlder ||
        _reachedTop ||
        _oldestSeq == null ||
        _roomLocalId == 0) {
      return;
    }
    _isLoadingOlder = true;
    emit(state.copyWith(isPagination: true));
    try {
      final older = await _chatRepo.olderPage(
        roomLocalId: _roomLocalId,
        beforeServerSeq: _oldestSeq!,
      );
      if (older.isNotEmpty) {
        _olderPages.addAll(older);
      }
      _reachedTop = older.isEmpty;
      final merged = _mergeWindows();
      _oldestSeq = merged
          .map((m) => m.serverSeq)
          .whereType<int>()
          .fold<int?>(null, (min, s) => min == null || s < min ? s : min);
      final mapped = merged
          .map((m) => DriftMessageMapper.toEntity(m,
              currentUserId: _meId, chatId: state.chatId))
          .toList();
      emit(state.copyWith(data: mapped, isPagination: false));
    } finally {
      _isLoadingOlder = false;
    }
  }

  Future<void> _fetchMessageEvent(
    FetchMessagesEvent event,
    Emitter<FetchMessagesState> emit,
  ) async {
    // Centrifugo/drift is the ONLY chat transport (legacy realtime removed). Opening +
    // pagination always route through the offline-first realtime path:
    // [_openRealtime] resolves the local drift room (by server room id when
    // present, otherwise by peer for a brand-new conversation), binds the
    // newest-first stream, and subscribes the live channel. The drift open
    // already clears unread + drives the durable REST read receipt internally.
    if (event.isFirstPage == true) {
      await _openRealtime(event, emit);
    } else {
      await _loadOlderRealtime(emit);
    }

    if (event.isLoading == true) {
      // Presence poll for the peer (transport-agnostic "online" indicator).
      di<UserOnlineBloc>().add(UserOnlineEvent(userId: event.params.userId));
      // Clear the chats-list unread badge + counter for the room we just opened.
      di<FetchUsersChatBloc>().currentChatId = state.chatId;
      di<FetchUsersChatBloc>().add(ReadMessageEvent(
        chatId: state.chatId,
        userId: event.params.userId,
      ));
      di<FetchUsersChatBloc>().add(UpdateTotalMessages(
        userId: event.params.userId,
        isIncreased: false,
      ));
    }
  }

  void _listener(FetchMessagesParamsUC params) {
    // Realtime/offline window: prefetch the next drift page at ~70% scroll
    // (≈30 messages left of a 50-item page) so paging never freezes the list.
    // `_isLoadingOlder` (set inside `_loadOlderRealtime`) guards re-entry.
    handlePrefetchScrollListener(
      controller: state.scrollController,
      fun: () {
        if (_isLoadingOlder || _reachedTop) return;
        // isFirstPage stays false → `_loadOlderRealtime` keyset-pages drift.
        add(FetchMessagesEvent(
          params: FetchMessagesParamsUC(chatId: state.chatId),
          isLoading: false,
        ));
      },
    );
  }

  void _addListenerEvent(
    AddListenerEvent event,
    Emitter<FetchMessagesState> emit,
  ) {
    if (_scrollCallback != null) {
      state.scrollController.removeListener(_scrollCallback!);
    }
    _scrollCallback = () => _listener(event.params);
    state.scrollController.addListener(_scrollCallback!);
  }

  void _removeListenerEvent(
    RemoveListenerEvent event,
    Emitter<FetchMessagesState> emit,
  ) {
    if (_scrollCallback != null) {
      state.scrollController.removeListener(_scrollCallback!);
      _scrollCallback = null;
    }
  }

  Future<void> _reactEvent(
    LocalUpdateReactMessagesEvent event,
    Emitter<FetchMessagesState> emit,
  ) async {
    final ToggleAppBarBloc toggleBloc = di<ToggleAppBarBloc>();

    // Toggle optimistically in drift + sync; the stream re-renders.
    // Prefer the id carried on the event (the app-bar selection is cleared by
    // InitAppBarEvent right after the tap, so reading it here races to empty).
    final selection = toggleBloc.state.messageSelectionMap.values;
    final sid = event.messageId ??
        (selection.isEmpty
            ? null
            : int.tryParse('${selection.first.messageId}'));
    if (sid == null) return;
    await _chatRepo.react(
      roomLocalId: _roomLocalId,
      serverMessageId: sid,
      reactType: event.reactType,
      reactPath: EndPoints.makeReact,
    );
  }

  Future<void> _localDeleteMessagesEvent(
    LocalDeleteMessagesEvent event,
    Emitter<FetchMessagesState> emit,
  ) async {
    di<ToggleAppBarBloc>().add(const InitAppBarEvent());

    // Mark + sync the deletion through drift via the single robust path
    // (ChatRepository.deleteMessages): it writes the local delete state AND
    // enqueues the server delete on the outbox (idempotent + retried). The
    // for-everyone vs for-me choice is carried on the event, so it is honored
    // here instead of being hard-coded to for-me.
    final ids = event.params.messageIds ?? const [];
    if (ids.isNotEmpty) {
      await _chatRepo.deleteMessages(
        roomLocalId: _roomLocalId,
        serverMessageIds: ids,
        forEveryone: event.forEveryone,
        deletePath: EndPoints.deleteMessage(event.forEveryone ? '' : 'for_me'),
      );
      for (final mid in ids) {
        di<FetchUsersChatBloc>().add(
          RemoveLocalLastMessageEvent(chatId: state.chatId, messageId: mid),
        );
      }
    }
  }

  Future<void> _retrySendMessageEvent(
    RetrySendMessageEvent event,
    Emitter<FetchMessagesState> emit,
  ) async {
    // #5 fix: match by clientUuid (server id is null for failed messages, so
    // the old `m.id == failedMessage.id` always hit the wrong/first row).
    // Call chatRepo.retry so the existing outbox op is re-queued under the
    // SAME client_uuid — no duplication, no new UUID.
    final clientUuid = event.failedMessage.clientUuid;
    if (clientUuid == null || _roomLocalId == 0) return;

    // Drive the whole resend through the repository: it re-stamps the row's
    // client time to now (so it reorders to the bottom with a fresh time),
    // flips it to `pending`, and re-enqueues the outbox op. The drift stream
    // re-emits the reordered list as the single source of truth — so we do NOT
    // mutate `state.data` in place here. The old in-place emit flipped the bubble
    // to `sending` at its FROZEN old position, which then visibly jumped when the
    // stream reordered it (the "disappears and comes back at the old time" bug).
    await _chatRepo.retry(clientUuid);
  }

  Future<void> _closeMessagesEvent(
    CloseMessagesEvent event,
    Emitter<FetchMessagesState> emit,
  ) async {
    // Stop the presence poll for the peer we were watching (it re-targets on the
    // next chat open); avoids an idle ~10s request for the last-opened peer.
    di<UserOnlineBloc>().add(const StopUserPresenceEvent());
    // Drop the scroll listener explicitly on close (not only on RemoveListener):
    // a listener left bound to the shared controller would keep paging the just-
    // closed conversation (and leak across opens).
    if (_scrollCallback != null) {
      state.scrollController.removeListener(_scrollCallback!);
      _scrollCallback = null;
    }
    await _driftSub?.cancel();
    _driftSub = null;
    _olderPages.clear();
    _liveWindow = const [];
    _oldestSeq = null;
    _reachedTop = false;
    // Reset the resolved room id on close. The send path resolves the room from
    // the peer itself now, but leaving a stale id here would let any residual
    // reader (react/delete/retry) target the previously-open room. 0 is the
    // unresolved sentinel those paths already guard on.
    _roomLocalId = 0;
    _serverRoomId = 0;
    emit(state.copyWith(data: [], currentPage: 1));
    try {
      await _realtimeClient.closeChat(
        peerUserId: int.tryParse(state.userId) ?? 0,
      );
    } catch (_) {/* ignore */}
    // Backend close-chat bookkeeping (transport-agnostic REST signal).
    await _closeChatUC(state.chatId);
  }

  Future<void> _finishUploadingVideoEvent(
    FinishUploadingVideoEvent event,
    Emitter<FetchMessagesState> emit,
  ) async {
    // Clear the video bubble's upload progress ring (static keyed by videoId).
    MessageVideoWidgetState.currentTime[event.videoId] = -1;
  }

  @override
  Future<void> close() async {
    await _driftSub?.cancel();
    if (_scrollCallback != null) {
      state.scrollController.removeListener(_scrollCallback!);
      _scrollCallback = null;
    }
    return super.close();
  }
}
