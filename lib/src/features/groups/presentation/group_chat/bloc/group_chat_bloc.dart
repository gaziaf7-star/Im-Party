import 'dart:async';

import 'package:general/src/core/database/app_database.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/realtime/chat_repository.dart';
import 'package:general/src/core/realtime/realtime_client.dart';
import 'package:general/src/core/realtime/realtime_http.dart';
import 'package:general/src/core/realtime/outbox_worker.dart';
import 'package:general/src/features/groups/domain/entities/group_entity.dart';
import 'package:general/src/features/groups/domain/entities/group_enums.dart';
import 'package:general/src/features/groups/domain/entities/group_member_entity.dart';
import 'package:general/src/features/groups/domain/entities/group_params.dart';
import 'package:general/src/features/groups/domain/entities/group_permissions.dart';
import 'package:general/src/features/groups/domain/usecases/group_usecases.dart';

part 'group_chat_event.dart';
part 'group_chat_state.dart';

/// Drives one group chat screen over the drift/realtime stack (Plan 7.6, part B).
///
/// Reads are local-first off [ChatRepository.watchMessages] (drift), so the
/// list survives reconnects + process death and shows optimistic `pending` rows
/// at the top. Sends go through [ChatRepository.sendGroup] → outbox → the group
/// endpoint with `Idempotency-Key=client_uuid`. On open it pulls the REST delta
/// via [ChatRepository.openGroupConversation] (works even without a live
/// Centrifugo server) and subscribes the realtime channel for live fan-out.
///
/// It NEVER touches the 1:1 chat path — group chat is a separate drift seam.
class GroupChatBloc extends Bloc<GroupChatEvent, GroupChatState> {
  final ChatRepository _chatRepository;
  final RealtimeClient _realtimeClient;
  final OutboxWorker _outboxWorker;
  final RealtimeHttp _http;
  final FetchGroupMembersUC _fetchMembers;

  StreamSubscription<List<Message>>? _messagesSub;
  StreamSubscription<RealtimeNonChatEvent>? _realtimeSub;
  int _serverGroupRoomId = 0;
  // Highest read seq already POSTed to the backend, so the durable group read
  // receipt fires only when the high-water-mark genuinely advances — not on
  // every drift emission (_onMessagesUpdated re-adds MarkGroupReadEvent on every
  // non-empty window, which previously POSTed unconditionally). Reset per open.
  int _lastReportedReadSeq = 0;

  /// Older keyset pages already pulled (below the live watch window). Merged
  /// with the live stream window and de-duplicated by client_uuid for render.
  final List<Message> _olderPages = [];

  GroupChatBloc(
    this._chatRepository,
    this._realtimeClient,
    this._outboxWorker,
    this._http,
    this._fetchMembers,
  ) : super(const GroupChatState(group: GroupEntity(id: 0, chatRoomId: 0))) {
    on<OpenGroupChatEvent>(_onOpen);
    on<CloseGroupChatEvent>(_onClose);
    on<GroupMessagesUpdatedEvent>(_onMessagesUpdated);
    on<SendGroupMessageEvent>(_onSend);
    on<RetryGroupMessageEvent>(_onRetry);
    on<LoadOlderGroupMessagesEvent>(_onLoadOlder);
    on<MarkGroupReadEvent>(_onMarkRead);
    on<SetGroupReplyEvent>(_onSetReply);
    on<DeleteGroupMessageEvent>(_onDeleteMessage);
    on<GroupMetaUpdatedEvent>(_onMetaUpdated);

    // Live group-metadata updates (rename / new photo / settings): when one lands
    // for the room currently open, merge it onto state.group so the header (name/
    // avatar) and the post gate (only_admins_post) refresh in-place — no reopen.
    _realtimeSub = _realtimeClient.nonChatEvents.listen((event) {
      if (event.event == 'group_updated' && event.payload is Map) {
        final payload = Map<String, dynamic>.from(event.payload as Map);
        final roomId = payload['chat_room_id'] ?? payload['room_id'];
        final asInt = roomId is int ? roomId : int.tryParse('$roomId');
        // Only the room on screen; ignore updates for other groups.
        if (asInt != null && asInt == _serverGroupRoomId && !isClosed) {
          add(GroupMetaUpdatedEvent(payload));
        }
      }
    });
  }

  Future<void> _onOpen(
    OpenGroupChatEvent event,
    Emitter<GroupChatState> emit,
  ) async {
    await _messagesSub?.cancel();
    _messagesSub = null;

    final group = event.group;
    _serverGroupRoomId = group.chatRoomId;
    _lastReportedReadSeq = 0;
    _olderPages.clear();
    emit(state.copyWith(
      group: group,
      reqState: RequestState.loading,
      messages: const [],
      reachedTop: false,
      clearReply: true,
    ));

    // Guard: a group with no backing chat room (chat_room_id not provisioned yet)
    // must NOT open conversation 0 — that resolves to room 0 and errors. Open the
    // screen empty-but-loaded so the user sees the (empty) chat instead of an
    // error state; member roster still loads below for the header.
    if (group.chatRoomId <= 0) {
      Methods.printLog(
        '[GroupChat] open skipped REST delta — group ${group.id} has no chat_room_id (got ${group.chatRoomId})',
      );
      emit(state.copyWith(
        reqState: RequestState.empty,
        reachedTop: true,
      ));
      unawaited(_loadMembers(group.id));
      return;
    }

    // 1) Local-first: resolve the drift room + pull REST delta (since_seq).
    //    Works offline / without Centrifugo — the stream below renders whatever
    //    is already local, the delta catches it up when the network is up.
    RoomRef ref;
    try {
      ref = await _chatRepository.openGroupConversation(
        serverGroupRoomId: group.chatRoomId,
        serverGroupId: group.id,
        title: group.name,
        avatarUrl: group.avatar,
        myRole: group.myRole.value,
      );
    } catch (_) {
      // The room may already exist locally even if the REST delta failed; fall
      // back to the local row so the user still sees cached history.
      final existing = await _chatRepository.roomByServerId(group.chatRoomId);
      if (existing == null) {
        emit(state.copyWith(reqState: RequestState.error));
        return;
      }
      ref = existing;
    }

    emit(state.copyWith(roomLocalId: ref.localId));

    // Opening the group = read → clear its unread badge in the list immediately.
    await _chatRepository.clearUnread(ref.localId);

    // 2) Bind the reactive newest-first window from drift.
    _messagesSub =
        _chatRepository.watchMessages(ref.localId).listen((messages) {
      // The drift stream can fire after the bloc closed (fast screen exit).
      if (!isClosed) add(GroupMessagesUpdatedEvent(messages));
    });

    // 3) Start the realtime subscription for live fan-out. Guarded: a missing
    //    Centrifugo server (not yet deployed — Phase 8) must not break the chat;
    //    the REST delta + local stream already cover correctness.
    try {
      await _realtimeClient.openGroupChat(
        serverGroupRoomId: group.chatRoomId,
        roomLocalId: ref.localId,
      );
    } catch (_) {/* realtime optional; local-first path stands alone */}

    // 4) Load member roster for read-receipt names (best-effort).
    unawaited(_loadMembers(group.id));

    // 5) Mark read on open. The awaits above (clearUnread/openGroupChat) give
    // the user time to leave the screen — adding after close crashes.
    if (!isClosed) add(const MarkGroupReadEvent());
  }

  Future<void> _onClose(
    CloseGroupChatEvent event,
    Emitter<GroupChatState> emit,
  ) async {
    await _messagesSub?.cancel();
    _messagesSub = null;
    try {
      await _realtimeClient.closeGroupChat(serverGroupRoomId: _serverGroupRoomId);
    } catch (_) {/* ignore */}
  }

  void _onMessagesUpdated(
    GroupMessagesUpdatedEvent event,
    Emitter<GroupChatState> emit,
  ) {
    final merged = _merge(event.messages);
    emit(state.copyWith(
      messages: merged,
      reqState: merged.isEmpty ? RequestState.empty : RequestState.loaded,
    ));
    // New incoming activity while the screen is open → keep read receipt current.
    if (event.messages.isNotEmpty) add(const MarkGroupReadEvent());
  }

  /// Combine the live newest-first watch window with any older keyset pages,
  /// de-duplicated by client_uuid and re-sorted newest-first (pending null-seq
  /// rows stay on top, matching the DAO's ordering).
  List<Message> _merge(List<Message> live) {
    if (_olderPages.isEmpty) return live;
    final byUuid = <String, Message>{};
    for (final m in _olderPages) {
      byUuid[m.clientUuid] = m;
    }
    for (final m in live) {
      byUuid[m.clientUuid] = m; // live wins (freshest state)
    }
    final all = byUuid.values.toList()
      ..sort((a, b) {
        final sa = a.serverSeq;
        final sb = b.serverSeq;
        if (sa == null && sb == null) {
          return b.createdAtClient.compareTo(a.createdAtClient);
        }
        if (sa == null) return -1; // pending first (newest)
        if (sb == null) return 1;
        return sb.compareTo(sa);
      });
    return all;
  }

  Future<void> _onSend(
    SendGroupMessageEvent event,
    Emitter<GroupChatState> emit,
  ) async {
    final body = event.body.trim();
    if (body.isEmpty || state.roomLocalId == 0) return;
    if (!state.permissions.canPost) return;

    final replyUuid = state.replyTo?.clientUuid;
    emit(state.copyWith(clearReply: true));

    await _chatRepository.sendGroup(
      roomLocalId: state.roomLocalId,
      serverGroupId: state.group.id,
      sendPath: EndPoints.groupSendMessage(state.group.id),
      body: body,
      replyToClientUuid: replyUuid,
    );
    // The optimistic row appears off the stream; the outbox drains it.
  }

  Future<void> _onRetry(
    RetryGroupMessageEvent event,
    Emitter<GroupChatState> emit,
  ) async {
    await _chatRepository.retry(event.clientUuid);
  }

  Future<void> _onLoadOlder(
    LoadOlderGroupMessagesEvent event,
    Emitter<GroupChatState> emit,
  ) async {
    if (state.isLoadingOlder || state.reachedTop || state.roomLocalId == 0) {
      return;
    }
    // Oldest confirmed seq currently held (skip pending null-seq rows).
    final oldestSeq = state.messages
        .map((m) => m.serverSeq)
        .whereType<int>()
        .fold<int?>(null, (min, s) => min == null || s < min ? s : min);
    if (oldestSeq == null) return;

    emit(state.copyWith(isLoadingOlder: true));
    final older = await _chatRepository.olderPage(
      roomLocalId: state.roomLocalId,
      beforeServerSeq: oldestSeq,
    );
    if (older.isNotEmpty) {
      _olderPages.addAll(older);
    }
    emit(state.copyWith(
      isLoadingOlder: false,
      reachedTop: older.isEmpty,
      messages: _merge(state.messages),
    ));
  }

  Future<void> _onMarkRead(
    MarkGroupReadEvent event,
    Emitter<GroupChatState> emit,
  ) async {
    if (state.roomLocalId == 0) return;
    final newestSeq = state.messages
        .map((m) => m.serverSeq)
        .whereType<int>()
        .fold<int>(0, (max, s) => s > max ? s : max);
    if (newestSeq <= 0) return;

    await _chatRepository.markRead(
      roomLocalId: state.roomLocalId,
      upToSeq: newestSeq,
    );

    // Guard the durable server receipt so it fires ONLY when the read high-
    // water-mark actually advances. _onMessagesUpdated re-adds MarkGroupReadEvent
    // on every non-empty drift emission (status/reaction/receipt ticks too), so
    // POSTing unconditionally hammered the endpoint with the same seq.
    if (newestSeq <= _lastReportedReadSeq) return;
    _lastReportedReadSeq = newestSeq;
    // Best-effort server receipt; failure is non-fatal (local read stands).
    // The backend validator expects `last_read_seq` (not `up_to_seq`) — using
    // the wrong key threw a 422/500 on every mark-read, which surfaced as a
    // noisy 500 in the Flutter logs even though the local read still worked.
    try {
      await _http.post(
        EndPoints.groupReadUpTo(state.group.id),
        data: {'last_read_seq': newestSeq},
      );
    } catch (_) {/* ignore */}
  }

  void _onSetReply(SetGroupReplyEvent event, Emitter<GroupChatState> emit) {
    emit(state.copyWith(replyTo: event.replyTo, clearReply: event.replyTo == null));
  }

  void _onMetaUpdated(
    GroupMetaUpdatedEvent event,
    Emitter<GroupChatState> emit,
  ) {
    final p = event.payload;
    final g = state.group;
    emit(state.copyWith(
      group: g.copyWith(
        name: p['name']?.toString(),
        avatar: (p['avatar'] ?? p['image'])?.toString(),
        privacy: p['privacy'] != null
            ? GroupPrivacy.fromString(p['privacy'].toString())
            : null,
        joinPolicy: p['join_policy'] != null
            ? GroupJoinPolicy.fromString(p['join_policy'].toString())
            : null,
        onlyAdminsPost: p['only_admins_post'] is bool
            ? p['only_admins_post'] as bool
            : (p['only_admins_post'] != null
                ? (p['only_admins_post'].toString() == 'true' ||
                    p['only_admins_post'].toString() == '1')
                : null),
        membersCount: _payloadInt(p['members_count']),
        maxMembers: _payloadInt(p['max_members']),
      ),
    ));
  }

  static int? _payloadInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  Future<void> _onDeleteMessage(
    DeleteGroupMessageEvent event,
    Emitter<GroupChatState> emit,
  ) async {
    if (state.roomLocalId == 0) return;
    // Only confirmed (server-id'd) messages can be deleted for everyone — a still
    // -pending row has no server id to address. Marks the local row deletedForAll
    // optimistically (tombstone shows off the drift stream) + enqueues the gated
    // server delete; the fan-out hides it for the other members live.
    await _chatRepository.deleteGroupMessages(
      roomLocalId: state.roomLocalId,
      serverMessageIds: [event.serverMessageId],
      deletePath: EndPoints.groupDeleteMessages(state.group.id),
    );
  }

  Future<void> _loadMembers(int groupId) async {
    final result = await _fetchMembers(GroupMembersParams(groupId: groupId));
    result.fold(
      (_) {},
      (right) {
        if (isClosed) return;
        emit(state.copyWith(members: right.data ?? const []));
      },
    );
  }

  /// Public hook used by the screen to nudge the outbox (e.g. on resume).
  void drainOutbox() => _outboxWorker.drainOnce();

  @override
  Future<void> close() {
    _messagesSub?.cancel();
    _realtimeSub?.cancel();
    return super.close();
  }
}
