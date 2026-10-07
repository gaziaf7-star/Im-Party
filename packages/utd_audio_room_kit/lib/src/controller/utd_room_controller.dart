import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import '../api/utd_api_client.dart';
import '../api/token_api.dart';
import '../api/seat_api.dart';
import '../api/speaker_api.dart';
import '../api/ban_api.dart';
import '../api/role_api.dart';
import '../api/comment_api.dart';
import '../models/room_mode.dart';
import '../core/connection_prewarm.dart';
import '../core/room_manager.dart';
import '../core/device_id.dart';
import '../core/device_info.dart';
import '../minimizing/minimize_controller.dart';
import '../minimizing/pip_controller.dart';
import '../models/chat_message.dart';
import '../models/participant_model.dart';
import '../models/seat_model.dart';
import '../theme/utd_room_strings.dart';
import 'chat_controller.dart';
import 'media_controller.dart';
import 'seat_controller.dart';

class UTDRoomController {
  static UTDRoomController? _activeController;

  /// The currently active room controller, if any.
  static UTDRoomController? get activeController => _activeController;

  /// Whether any room is currently active.
  static bool get hasActiveRoom => _activeController?.isConnected == true;

  final UTDRoomManager _roomManager = UTDRoomManager();
  late final UTDSeatController seatController;
  late final UTDMediaController mediaController;
  late final UTDChatController chatController;
  late final UTDMinimizeController minimize;

  /// Android OS-level Picture-in-Picture controller. Active only while in-room
  /// and only when [UTDMinimizeConfig.enableOSPip] is set; no-op on iOS /
  /// Android < 31, where the in-app minimize overlay remains the fallback.
  late final UTDPipController pip;

  /// UTD Stream Engine API client for in-room operations (seats, speakers,
  /// bans, roles) — points at the grey-cloud engine host.
  UTDApiClient? _apiClient;

  /// Separate API client for token generation — points at the edge host, which
  /// differs from the in-room engine host (see [UTDApiClient]).
  UTDApiClient? _tokenClient;
  UTDTokenApi? _tokenApi;
  UTDSeatApi? _seatApi;
  UTDSpeakerApi? _speakerApi;
  UTDBanApi? _banApi;
  UTDRoleApi? _roleApi;
  UTDCommentApi? _commentApi;

  /// Access the seat API for direct seat operations.
  UTDSeatApi? get seatApi => _seatApi;

  /// Access the speaker API for request/invitation operations.
  UTDSpeakerApi? get speakerApi => _speakerApi;

  /// Access the ban API for ban/unban/list operations.
  UTDBanApi? get banApi => _banApi;

  /// Access the role API for change-role / list-by-role operations.
  UTDRoleApi? get roleApi => _roleApi;

  /// Access the comment API for chat lock/unlock operations.
  UTDCommentApi? get commentApi => _commentApi;
  StreamSubscription<Participant>? _participantJoinedSub;
  StreamSubscription<Participant>? _participantLeftSub;
  StreamSubscription<Participant>? _participantAttributesChangedSub;
  StreamSubscription<Participant>? _participantMetadataChangedSub;
  StreamSubscription<List<Participant>>? _activeSpeakersSub;

  /// Set of user IDs currently speaking — updated via RTC events.
  final ValueNotifier<Set<String>> activeSpeakers = ValueNotifier({});

  /// Set of user IDs whose mic is disabled — polled from RTC participants.
  final ValueNotifier<Set<String>> mutedParticipants = ValueNotifier({});

  /// Whether room chat is currently locked (host/admin-only). Driven by the
  /// server: the `_chat_lock` broadcast and the `chat_locked` room-metadata
  /// field, routed through [seatController]. The UI gates the composer on this
  /// plus [isHostOrAdmin] (see [canIComment]); it is never set optimistically.
  final ValueNotifier<bool> commentsLocked = ValueNotifier(false);

  Timer? _speakingPollTimer;

  final StreamController<List<UTDParticipant>> _participantsController =
      StreamController<List<UTDParticipant>>.broadcast();

  /// Stream of all room participants — emits on join/leave.
  Stream<List<UTDParticipant>> get participantsStream =>
      _participantsController.stream;

  /// Stream of occupied seats — emits whenever seat state changes.
  Stream<List<SeatState>> get occupiedSeatsStream =>
      seatController.occupiedSeatsStream;

  /// Stream of speaker events (requests, invitations, approvals, rejections).
  Stream<Map<String, dynamic>> get speakerEventStream =>
      seatController.speakerEventStream;

  final StreamController<UTDRoleChangeEvent> _roleChangeController =
      StreamController<UTDRoleChangeEvent>.broadcast();

  /// Stream of role changes (`_role_change`) for ALL participants. Emits for
  /// promotions/demotions by the owner and for engine auto-corrections.
  Stream<UTDRoleChangeEvent> get roleChangeStream =>
      _roleChangeController.stream;

  Stream<Participant> get participantJoinedStream =>
      _roomManager.participantJoinedStream;

  Stream<Participant> get participantLeftStream =>
      _roomManager.participantLeftStream;

  /// Fired for every `_role_change` (self or others). The affected user is
  /// [UTDRoleChangeEvent.identity] — the RTC event sender is null.
  void Function(UTDRoleChangeEvent event)? onRoleChanged;

  /// Localized strings used for controller-emitted room-chat lines (e.g. the
  /// admin promote/demote announcements). Wired from the host app's
  /// [UTDAudioRoomConfig]; falls back to [UTDRoomStrings.en] when unset.
  UTDRoomStrings? strings;

  /// Fired when the room stays disconnected past the reconnection handler's
  /// force-exit threshold (>60s). The app should tear down the room and
  /// navigate away. Wired from [seatController] in [connect].
  void Function()? onForceExit;

  /// When true (default), a >60s force-exit also frees the local seat
  /// server-side (best-effort) so the departing user isn't left as a ghost
  /// speaker for everyone else. Safe on a true outage — the POST just fails fast
  /// and the server (participant_left webhook + seat reconciler) is the
  /// authoritative backstop.
  bool freeSeatOnForceExit = true;

  /// When true (default), an app kill ([AppLifecycleState.detached]) best-effort
  /// frees the local seat and disconnects. Backgrounding / minimize / OS PiP are
  /// deliberately NOT affected (those are paused/inactive, not detached).
  bool leaveSeatOnAppKill = true;

  /// Applies an incoming role change to the cache and notifies listeners.
  void _handleRoleChange(UTDRoleChangeEvent event) {
    if (event.identity.isEmpty) return;
    // Resolve the role held BEFORE this change, to detect an admin toggle even
    // if the engine omits `previous_role`. Read it before the cache is
    // overwritten below. The broadcast's own `previous_role` is authoritative
    // when present — it is unaffected by the owner's optimistic cache write in
    // [changeRole], whereas the cache fallback would be.
    final priorRole = event.previousRole ?? getParticipantRole(event.identity);
    _roleCache[event.identity] = event.role;
    if (!_roleChangeController.isClosed) {
      _roleChangeController.add(event);
    }
    onRoleChanged?.call(event);
    _announceAdminChange(event, priorRole);
    // Refresh participant-derived UI (seat badges) so the new role shows.
    refreshParticipants();
  }

  /// Posts a local room-chat system line when a user gains or loses the `admin`
  /// role — "<name> became an admin" / "<name> was removed from admins".
  ///
  /// Driven by the broadcast `_role_change` (received by EVERY client), so the
  /// line is consistent for all participants with no extra network message.
  /// Only the admin transition is announced; other role changes
  /// (guest/host/audience) and no-op re-affirmations produce nothing. The
  /// toggle check (was != now) also dedups a repeated event for the same change.
  void _announceAdminChange(UTDRoleChangeEvent event, String? priorRole) {
    final isNowAdmin = event.role == 'admin';
    final wasAdmin = priorRole == 'admin';
    if (isNowAdmin == wasAdmin) return;

    final s = strings ?? UTDRoomStrings.en();
    final name = _displayNameForRoleChange(event.identity);
    final text = isNowAdmin ? s.becameAdmin(name) : s.removedFromAdmins(name);

    chatController.addDisplayMessage(
      UTDChatMessage(
        senderUserId: '',
        senderName: '',
        text: text,
        timestamp: DateTime.now(),
        userData: const {'system': true, 'kind': 'roleChange'},
      ),
    );
  }

  /// Best-effort display name for a role-change announcement. The
  /// `_role_change` event carries only the affected [identity], so resolve the
  /// name from the live participants (local or remote), falling back to the
  /// identity when the user isn't connected / has no name.
  String _displayNameForRoleChange(String identity) {
    final local = _roomManager.localParticipant;
    if (local != null && local.identity == identity && local.name.isNotEmpty) {
      return local.name;
    }
    final remote = _roomManager.remoteParticipants
        .where((p) => p.identity == identity)
        .firstOrNull;
    final name = remote?.name;
    if (name != null && name.isNotEmpty) return name;
    return identity;
  }

  /// Applies a comment-lock state change.
  ///
  /// [fromLiveEvent] true for the broadcast `_chat_lock` data message (a real
  /// toggle), false for the `chat_locked` room-metadata sync (initial join /
  /// reconnect / missed-event backstop). State is always updated; only the live
  /// event announces. The metadata path never announces, so it can't race the
  /// live event into a double or suppressed announcement — and a late joiner
  /// (who only ever sees metadata, never the historical data message) syncs
  /// silently.
  void _handleChatLockChange(bool locked, {required bool fromLiveEvent}) {
    commentsLocked.value = locked; // ValueNotifier dedups UI rebuilds.
    if (fromLiveEvent) _announceChatLock(locked);
  }

  /// Posts a local room-chat system line when comments are locked / unlocked,
  /// reusing the same `userData['system']` rendering as the admin announcements.
  void _announceChatLock(bool locked) {
    final s = strings ?? UTDRoomStrings.en();
    final text =
        locked ? s.commentsLockedAnnouncement : s.commentsUnlockedAnnouncement;
    chatController.addDisplayMessage(
      UTDChatMessage(
        senderUserId: '',
        senderName: '',
        text: text,
        timestamp: DateTime.now(),
        userData: const {'system': true, 'kind': 'chatLock'},
      ),
    );
  }

  // ========== Mode Registry ==========
  final Map<String, UTDRoomMode> _modeRegistry = {
    UTDRoomMode.defaultMode.id: UTDRoomMode.defaultMode,
  };

  final ValueNotifier<UTDRoomMode> currentMode =
      ValueNotifier(UTDRoomMode.defaultMode);

  VoidCallback? _modeIdSyncListener;

  /// Wires the modeId → currentMode sync if not already attached, then runs
  /// one immediate sync. The immediate run matters: the pre-connect seat
  /// snapshot ([primeSeats]) can set modeId BEFORE any listener exists, and
  /// ValueNotifier dedups equal writes — so the later identical metadata
  /// apply at connect would never notify, leaving currentMode stuck on the
  /// default layout for the whole session.
  void _ensureModeIdSync() {
    if (_modeIdSyncListener == null) {
      _modeIdSyncListener = () {
        final id = seatController.modeId.value;
        if (id != null) currentMode.value = resolveMode(id);
      };
      seatController.modeId.addListener(_modeIdSyncListener!);
    }
    _modeIdSyncListener!();
  }

  void registerModes(List<UTDRoomMode> modes) {
    for (final mode in modes) {
      _modeRegistry[mode.id] = mode;
    }
  }

  List<UTDRoomMode> get registeredModes => _modeRegistry.values.toList();

  UTDRoomMode resolveMode(String? modeId) {
    if (modeId == null) return UTDRoomMode.defaultMode;
    return _modeRegistry[modeId] ?? UTDRoomMode.defaultMode;
  }

  UTDRoomController() {
    seatController = UTDSeatController(_roomManager);
    mediaController = UTDMediaController(_roomManager);
    chatController = UTDChatController(_roomManager);
    minimize = UTDMinimizeController(this);
    pip = UTDPipController(this);
  }

  ValueNotifier<UTDConnectionState> get connectionState =>
      _roomManager.connectionState;

  bool get isConnected =>
      _roomManager.connectionState.value == UTDConnectionState.connected;

  /// App ID for the UTD Stream Engine (e.g. "9325906999").
  String? _appId;

  /// Publishable app key (no-backend mint credential, sent as X-App-Key).
  String? _appKey;

  /// Per-user bearer minted by the engine; re-applied to rebuilt API clients on initApi so
  /// no-backend credentials survive restore-from-minimize (which re-inits without re-minting).
  String? _lastUserToken;

  /// Get the configured App ID.
  String? get appId => _appId;

  /// Get the configured app key.
  String? get appKey => _appKey;

  /// Initializes the UTD Stream Engine API clients.
  ///
  /// Must be called before [connect] if you want to use the new backend APIs.
  /// Token generation and in-room operations use different hosts:
  /// [tokenBaseUrl] for `generateToken`, [baseUrl] for all seat/speaker/ban/role
  /// operations (see [UTDApiClient] for why they differ).
  /// [baseUrl] — in-room engine host, e.g. "https://engine.udt-stream.com"
  /// [tokenBaseUrl] — token host, e.g. "https://udt-stream.com"
  /// [appKey] — the publishable app key (no backend required): the kit mints tokens directly from
  /// the engine with X-App-Key and uses the per-user bearer it returns for in-room actions. The
  /// server secret never ships.
  void initApi({
    String baseUrl = UTDApiClient.defaultBaseUrl,
    String tokenBaseUrl = UTDApiClient.defaultTokenBaseUrl,
    String? appId,
    required String appKey,
  }) {
    _appId = appId;
    _appKey = appKey;
    // Only the token client carries X-App-Key (for minting); in-room calls authenticate with the
    // per-user bearer applied after the first generateToken.
    _apiClient = UTDApiClient(
      baseUrl: baseUrl,
      appId: appId,
    );
    _tokenClient = UTDApiClient(
      baseUrl: tokenBaseUrl,
      appId: appId,
      appKey: appKey,
    );
    // Token issuance hits the edge host; all in-room ops hit the engine host.
    _tokenApi = UTDTokenApi(_tokenClient!);
    _seatApi = UTDSeatApi(_apiClient!);
    _speakerApi = UTDSpeakerApi(_apiClient!);
    _banApi = UTDBanApi(_apiClient!);
    _roleApi = UTDRoleApi(_apiClient!);
    _commentApi = UTDCommentApi(_apiClient!);
    // Re-apply the per-user bearer to the freshly built clients so no-backend credentials survive
    // a re-init (restore-from-minimize calls initApi() again without re-minting a token).
    if (_lastUserToken != null) _applyUserToken(_lastUserToken!);
    // Fire-and-forget warm-up for the join that typically follows initApi
    // immediately: heat the device-id/device-info caches so the token POST
    // doesn't pay them serially. The token host is deliberately NOT prewarmed
    // here — a HEAD started in the same frame as the token POST steals the
    // pool's single warm socket from it; ahead-of-time prewarm is [warmUp].
    // Skipped when already connected (restore-from-minimize re-inits without a
    // new join).
    if (!isConnected) {
      unawaited(UTDDeviceId.resolve());
      unawaited(UTDDeviceInfoCollector.collect());
    }
    debugPrint('[UTDRoomController] API initialized — engine: $baseUrl, '
        'token: $tokenBaseUrl'
        '${appId != null ? ', appId: $appId' : ''}');
  }

  /// Optional app-side warm-up that makes the NEXT room entry faster. Call it
  /// when entering a room becomes likely (e.g. the rooms lobby opens): it
  /// pre-opens the TLS connection to the token host, heats the device-id and
  /// device-info caches, and pre-warms DNS/TLS to the RTC edge of the last
  /// join — all off the critical path. This is the ONLY token-host prewarm
  /// path: [initApi] deliberately does not prewarm it, so the warmed socket
  /// is reserved for the token POST instead of a same-frame HEAD.
  /// Best-effort: never throws, safe to fire-and-forget, cheap to call
  /// repeatedly (everything is cached).
  static Future<void> warmUp({
    String tokenBaseUrl = UTDApiClient.defaultTokenBaseUrl,
  }) async {
    await Future.wait<void>([
      UTDConnectionPrewarm.prewarmTokenHost(tokenBaseUrl),
      UTDConnectionPrewarm.prewarmRtc(),
      UTDDeviceId.resolve(),
      UTDDeviceInfoCollector.collect(),
    ]);
  }

  /// Apply the per-user bearer returned by the token flow to every in-room API client, so
  /// seat/speaker/ban/role/comment calls authenticate as the verified user.
  void _applyUserToken(String userToken) {
    if (userToken.isEmpty) return;
    _lastUserToken = userToken;
    _apiClient?.updateToken(userToken);
    _tokenClient?.updateToken(userToken);
  }

  /// Pre-connect seat priming: point the seat controller at [roomName] and
  /// seed the grid BEFORE the RTC connect so the room body can render real
  /// occupants while the WSS/ICE establishment is still in flight. When the
  /// token response embedded a [snapshot] it is applied with zero extra round
  /// trips; otherwise a GET /seats fires in parallel with the dial. Safe to
  /// call only after a successful token response (the ban check lives on the
  /// token POST). The metadata read at connect and the `_seat_update` stream
  /// remain authoritative — stale results are generation-guarded inside the
  /// seat controller.
  void primeSeats({
    required String roomName,
    required int seatCount,
    Map<String, dynamic>? snapshot,
  }) {
    final api = _seatApi;
    if (api == null) return;
    seatController.setSeatApi(api, roomName);
    // The sync listener must exist BEFORE the snapshot apply sets modeId, so
    // the pre-connect body renders the right layout (and the dedup-swallowed
    // write bug can't occur — see _ensureModeIdSync).
    _ensureModeIdSync();
    unawaited(
      seatController.prepareSeats(seatCount: seatCount, snapshot: snapshot),
    );
  }

  /// Teardown of a PREVIOUS controller's room, started early (see
  /// [prepareConnect]) so it overlaps the token round trip instead of
  /// serializing ahead of the RTC dial on a room switch.
  Future<void>? _pendingPreviousCleanup;

  /// Starts tearing down any previous room controller NOW so the teardown runs
  /// concurrently with the caller's token fetch; [connect] awaits it before
  /// dialing. Idempotent and cheap when there is nothing to clean up. Note the
  /// (deliberate) semantic on a room switch: the old room starts closing as
  /// soon as the new join begins, even if that join later fails — entering a
  /// new room is an explicit choice to leave the old one.
  void prepareConnect() {
    _pendingPreviousCleanup ??= _cleanupPreviousRoom();
  }

  Future<void> connect({
    required String url,
    required String token,
    int seatCount = 9,
    bool enableMicOnJoin = false,
    bool useSpeaker = true,
    Map<String, String> userAttributes = const {},
    String? roomName,
  }) async {
    // Disarm the previous session's reconnection force-exit while THIS connect
    // owns the failure handling: with the outer per-attempt timeout at 25s, a
    // worst-case retry sequence can outlast the handler's 60s exit threshold,
    // which would tear down a join that is still progressing. initSeats
    // re-arms a fresh handler after connect succeeds.
    seatController.suspendReconnectionHandling();

    final pendingCleanup = _pendingPreviousCleanup;
    _pendingPreviousCleanup = null;
    // Bounded: the new Room instance is independent of the old one, and the
    // server's participant_left webhook backstops an unclean close — a slow
    // teardown must not eat the join budget.
    await (pendingCleanup ?? _cleanupPreviousRoom()).timeout(
      const Duration(seconds: 2),
      onTimeout: () {
        debugPrint(
            '[UTDRoomController] previous-room cleanup still running after 2s '
            '— continuing with connect');
      },
    );

    // Same-instance reconnect (admin token re-issue fallback, room switch on
    // one controller): _cleanupPreviousRoom only handles a DIFFERENT previous
    // controller, so explicitly tear down our own still-live RTC session
    // before dialing the new one — otherwise the old Room is orphaned while
    // connected and keeps playing room audio after exit.
    if (_roomManager.room != null) {
      // Drain any in-flight mic publish BEFORE disconnecting (mirrors leave()):
      // audioSetup now runs unawaited for every join, so a publish can still be
      // in flight here — disconnect() disposes local tracks, and a publish
      // caught mid-flight hits addTransceiver with a disposed track.
      await mediaController.cancelPendingPublish();
      await _roomManager.disconnect().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          debugPrint(
              '[UTDRoomController] same-instance disconnect still running '
              'after 2s — continuing with connect');
        },
      );
    }

    // Re-entrancy guard: if connect() is called again on this same instance
    // without an intervening leave(), cancel the previous participant
    // subscriptions and remove the modeId listener first, otherwise they leak
    // and every participant/currentMode event fires twice.
    _participantJoinedSub?.cancel();
    _participantLeftSub?.cancel();
    _participantAttributesChangedSub?.cancel();
    _participantMetadataChangedSub?.cancel();
    _activeSpeakersSub?.cancel();
    _participantJoinedSub = null;
    _participantLeftSub = null;
    _participantAttributesChangedSub = null;
    _participantMetadataChangedSub = null;
    _activeSpeakersSub = null;
    // ActiveSpeakersChangedEvent only fires on speaker-set changes, so a
    // silent new room would never correct a stale set — reset it here.
    if (activeSpeakers.value.isNotEmpty) activeSpeakers.value = const {};
    if (_modeIdSyncListener != null) {
      seatController.modeId.removeListener(_modeIdSyncListener!);
      _modeIdSyncListener = null;
    }

    _banHandled = false;
    _roleCache.clear();
    // Reset comment-lock state for the new session; the room metadata read in
    // initSeats below restores the authoritative value for this room.
    commentsLocked.value = false;
    await _roomManager.connect(url, token);
    _activeController = this;

    // Active speakers are event-driven: the server's speaker update lands in
    // the same event-loop turn instead of waiting on a poll tick. Subscribed
    // before any post-connect await so no event is dropped while the host
    // path's audio setup runs.
    _activeSpeakersSub = _roomManager.activeSpeakersStream.listen((speakers) {
      if (_disposed) return;
      final speaking = <String>{
        for (final p in speakers) p.identity.toString(),
      };
      if (!setEquals(activeSpeakers.value, speaking)) {
        activeSpeakers.value = speaking;
      }
    });

    // Route ban signals (data message + server removal) to the single funnel.
    seatController.onBanned =
        (data) => _emitBanned(UTDBanNotice.fromData(data));
    _roomManager.onParticipantRemoved =
        () => _emitBanned(const UTDBanNotice.fromDisconnect());

    // Single-active-session takeover: a `_kicked` (`signed_in_elsewhere`) data
    // message rides the SAME exit funnel (de-duped via _banHandled), so the
    // participantRemoved that follows it won't double-fire as a ban. Arriving
    // first (reliable data, sent before removeParticipant) it shows the correct
    // "signed in on another device" message instead of a generic removal.
    seatController.onKicked =
        (data) => _emitBanned(UTDBanNotice.fromKicked(data['reason'] as String?));

    // Route `_role_change` data messages into the role cache + stream.
    seatController.onRoleChanged =
        (data) => _handleRoleChange(UTDRoleChangeEvent.fromData(data));

    // Comment lock: enforce the chat gate, and track the lock state from both
    // the live `_chat_lock` broadcast (announces) and the `chat_locked` room
    // metadata (silent sync — covers a late joiner / a missed event).
    chatController.canSendChat = () => canIComment;
    chatController.canReceiveChatFrom =
        (senderId) => !commentsLocked.value || _isPrivileged(senderId);
    seatController.onChatLockEvent =
        (locked) => _handleChatLockChange(locked, fromLiveEvent: true);
    seatController.onChatLockMetadata =
        (locked) => _handleChatLockChange(locked, fromLiveEvent: false);

    // Surface the reconnection handler's force-exit (>60s disconnect) to the app.
    // Free our seat first (best-effort) so we don't linger as a ghost speaker;
    // the bubbled onForceExit then tears the room down and navigates away.
    seatController.onForceExit = () {
      if (freeSeatOnForceExit) _leaveSeatBestEffort();
      onForceExit?.call();
    };

    // Configure seat API with room name if available
    if (_seatApi != null && roomName != null) {
      seatController.setSeatApi(_seatApi!, roomName);
    } else if (_seatApi != null && _roomManager.room?.name != null) {
      seatController.setSeatApi(_seatApi!, _roomManager.room!.name!);
    }

    // Sync currentMode whenever seatController.modeId changes. Must be wired
    // BEFORE initSeats (which reads room metadata synchronously and may set
    // modeId.value immediately) and must run an initial sync, because a
    // pre-connect snapshot (primeSeats) may have set modeId already.
    _ensureModeIdSync();

    seatController.initSeats(seatCount);

    // Wire the invitation handler so _speaker_invitation events
    // trigger the full accept/decline + takeSeat + mic flow
    seatController
        .setInvitationHandler((data) => handleIncomingInvitation(data));

    chatController.startListening();
    // Listen for RTC mute/unmute events so the controls-bar mic icon
    // reflects host/admin server-side mutes, not just local toggles.
    mediaController.startListening();

    // Post-connect audio/identity setup. None of it is required for receiving
    // audio, so for non-publishing joins (audience/admin, enableMicOnJoin
    // false — 99% of entries) it runs UNAWAITED off the join critical path.
    // The host path stays awaited to preserve the mic-publish → BT-routing
    // ordering (publishing is when MODE_IN_COMMUNICATION matters most).
    Future<void> audioSetup() async {
      try {
        // When the room wants loud output, prefer a connected Bluetooth headset
        // over the phone speaker (privacy). Plain speaker-on ignores Bluetooth.
        // applyBluetoothAudioRouting re-applies the Android audio config with
        // forceHandleAudioRouting:true AFTER the RTC engine's connect set
        // MODE_IN_COMMUNICATION (which otherwise disables routing) — this is
        // what makes BT actually work.
        if (useSpeaker) {
          await mediaController.applyBluetoothAudioRouting();
        } else {
          await mediaController.setSpeakerOn(false);
        }
        if (enableMicOnJoin) {
          await mediaController.setMicrophoneEnabled(true);
          // Publishing the local mic track is when MODE_IN_COMMUNICATION
          // matters most — re-apply BT routing so the captured audio also
          // routes to the headset, not the phone mic/speaker.
          if (useSpeaker) {
            await mediaController.applyBluetoothAudioRouting();
          }
        }

        // Cosmetic fields (avatar, frame, color name) are published ONLY as
        // RTC participant *attributes* — never participant metadata. The
        // server owns metadata (role/_device/...); a client self-writing
        // metadata would let a peer spoof role/VIP in broadcast metadata (M2).
        if (userAttributes.isNotEmpty) {
          // These keys ARE the app's cosmetic set (the app publishes nothing but
          // cosmetics as participant attributes). Register them so a mid-session
          // change to any of them repaints occupied seats + reaches late joiners.
          seatController.registerCosmeticKeys(userAttributes.keys);
          try {
            await _roomManager.localParticipant?.setAttributes(userAttributes);
          } catch (e) {
            debugPrint(
                '[UTDRoomController] setAttributes failed (non-fatal): $e');
          }
        }
      } catch (e) {
        debugPrint(
            '[UTDRoomController] post-connect audio setup failed (non-fatal): $e');
      }
    }

    // Unawaited for EVERY join. The BT → mic-publish → BT → attributes
    // ordering lives inside the closure (sequential awaits) and is preserved
    // identically when it runs unawaited — awaiting it here only delayed the
    // caller's UI, which for hosts meant the room body hid behind mic capture
    // (and, on first use, behind the OS permission dialog: up to the 10s
    // mediaOpTimeout of skeleton). A leave() during setup is already handled
    // by the media controller's op-epoch / cancelPendingPublish machinery.
    unawaited(audioSetup());

    _participantJoinedSub = _roomManager.participantJoinedStream.listen((p) {
      if (_disposed || _participantsController.isClosed) return;
      debugPrint(
          '👤 [VISITORS] participantJoined: ${p.identity} — total: ${participants.length}');
      _emitParticipants();
    });
    _participantLeftSub = _roomManager.participantLeftStream.listen((p) {
      if (_disposed || _participantsController.isClosed) return;
      // Backend handles seat cleanup via participant_left webhook.
      // We just update the participant list locally.
      // Drop any role-cache overlay for the departed user so a stale role
      // can't outlive them (the cache otherwise wins over live metadata).
      _roleCache.remove(p.identity.toString());
      debugPrint(
          '👤 [VISITORS] participantLeft: ${p.identity} — total: ${participants.length}');
      _emitParticipants();
    });
    _participantAttributesChangedSub =
        _roomManager.participantAttributesChangedStream.listen((p) {
      if (_disposed || _participantsController.isClosed) return;
      debugPrint('👤 [VISITORS] participantAttributesChanged: ${p.identity}');
      _emitParticipants();
    });
    _participantMetadataChangedSub =
        _roomManager.participantMetadataChangedStream.listen((p) {
      if (_disposed || _participantsController.isClosed) return;
      // The engine rewrites `role` in metadata on a role change — refresh so
      // seat badges reflect it even if a `_role_change` message was missed.
      debugPrint('👤 [VISITORS] participantMetadataChanged: ${p.identity}');
      _emitParticipants();
    });
    debugPrint('👤 [VISITORS] initial participants: ${participants.length}');
    _emitParticipants();

    // Start polling mic mute state from RTC participants
    _startSpeakingPoll();

    // Observe app lifecycle so an app kill (detached) frees the seat + disconnects.
    // Owned by the controller (not the room widget) so it keeps working while the
    // room is minimized — the widget is disposed in that state, the controller isn't.
    _registerLifecycleWatcher();
  }

  /// Polls RTC participant mic state every 300ms and updates
  /// [mutedParticipants] plus the local controls-bar mic icon.
  /// [activeSpeakers] is event-driven (see the activeSpeakersStream
  /// subscription in [connect]), not written here.
  void _startSpeakingPoll() {
    _speakingPollTimer?.cancel();
    _speakingPollTimer = Timer.periodic(
      const Duration(milliseconds: 300),
      (_) {
        // Guard: bail if the controller was disposed or the room disconnected
        if (_disposed) return;

        final local = _roomManager.localParticipant;
        final remote = _roomManager.remoteParticipants;
        final all = <Participant>[if (local != null) local, ...remote];

        try {
          final muted = <String>{};
          for (final p in all) {
            if (!p.isMicrophoneEnabled()) {
              muted.add(p.identity.toString());
            }
          }
          if (!setEquals(mutedParticipants.value, muted)) {
            mutedParticipants.value = muted;
          }

          // Backstop: keep the controls-bar mic icon (mediaController.isMicEnabled)
          // in sync with the local mic's real state in case a TrackMuted/Unmuted
          // event was missed (e.g. a host mute that landed during reconnect).
          // The event-driven sync in UTDMediaController handles the common case
          // instantly; this just guarantees eventual consistency.
          if (local != null) {
            final localMicOn = local.isMicrophoneEnabled();
            if (mediaController.isMicEnabled.value != localMicOn) {
              mediaController.isMicEnabled.value = localMicOn;
            }
          }
        } catch (e) {
          // Suppress "Participant disposed" errors that occur when participants
          // are cleaned up by the RTC engine while a poll tick fires. This is a harmless
          // race condition — the timer is cancelled on the next dispose() call.
          if (e.toString().contains('Participant disposed')) {
            debugPrint(
                '[UTDRoomController] Suppressed disposed participant access in poll: $e');
          } else {
            rethrow;
          }
        }
      },
    );
  }

  Future<void> _cleanupPreviousRoom() async {
    final previous = _activeController;
    if (previous == null || previous == this) return;
    // The switch is committed (see [prepareConnect]): release the slot
    // synchronously, BEFORE any await, so a newer controller registering
    // itself mid-teardown can't be clobbered when this resumes.
    _activeController = null;

    debugPrint(
        '[UTDRoomController] Cleaning up previous room before connecting');
    try {
      if (previous.minimize.isMinimizing) {
        previous.minimize.dismiss();
      }
      await previous.pip.disarm();
      if (previous.isConnected) {
        await previous.leave();
      }
    } catch (e) {
      debugPrint('[UTDRoomController] Previous room cleanup error: $e');
    }
  }

  Future<void> leave() async {
    if (_activeController == this) _activeController = null;
    _unregisterLifecycleWatcher();
    // Authoritative teardown: make sure the minimize overlay state machine is
    // reset to idle. Some app exit paths (e.g. exitRoom while minimized) call
    // leave() without first going through minimize.close()/dismiss(), which
    // would otherwise leave the singleton machine stuck in `minimizing` and
    // every app-wide isMinimizing guard believing a room is still open.
    if (minimize.isMinimizing) minimize.dismiss();
    // Stop OS PiP auto-enter — once out of the room, backgrounding must not
    // trigger a system PiP window (enforces the "in-room only" requirement).
    await pip.disarm();
    _roleCache.clear();
    _speakingPollTimer?.cancel();
    _speakingPollTimer = null;
    _participantJoinedSub?.cancel();
    _participantJoinedSub = null;
    _participantLeftSub?.cancel();
    _participantLeftSub = null;
    _participantAttributesChangedSub?.cancel();
    _participantAttributesChangedSub = null;
    _participantMetadataChangedSub?.cancel();
    _participantMetadataChangedSub = null;
    _activeSpeakersSub?.cancel();
    _activeSpeakersSub = null;
    // ActiveSpeakersChangedEvent only fires on speaker-set changes, so a
    // stale set would otherwise persist into the next session's seat ring.
    if (activeSpeakers.value.isNotEmpty) activeSpeakers.value = const {};
    seatController.stopListening();
    chatController.stopListening();
    mediaController.stopListening();
    // Drain any in-flight mic publish BEFORE disconnecting: room.disconnect()
    // disposes the local tracks, and a publish caught mid-flight then hits the
    // SDK's addTransceiver with a disposed (null) track — the top live fatal.
    await mediaController.cancelPendingPublish();
    await _roomManager.disconnect();
  }

  /// Best-effort free of the local user's seat via the UTD Stream API. Fire-and-
  /// forget with a short timeout so it never blocks teardown; on a true outage the
  /// POST fails fast and the server (participant_left webhook + seat reconciler)
  /// frees the seat authoritatively. No-op when we don't currently hold a seat.
  void _leaveSeatBestEffort() {
    final id = localIdentity;
    if (id == null) return;
    if (seatController.getSeatIndexByUserId(id) < 0) return;
    unawaited(
      seatController
          .leaveSeat(id)
          .timeout(const Duration(seconds: 2), onTimeout: () => false)
          .catchError((_) => false),
    );
  }

  // --- App lifecycle (auto-leave on app kill) -------------------------------

  _UTDAppLifecycleWatcher? _lifecycleWatcher;

  void _registerLifecycleWatcher() {
    if (_lifecycleWatcher != null) return;
    final watcher = _UTDAppLifecycleWatcher(_onAppDetached);
    _lifecycleWatcher = watcher;
    WidgetsBinding.instance.addObserver(watcher);
  }

  void _unregisterLifecycleWatcher() {
    final watcher = _lifecycleWatcher;
    if (watcher == null) return;
    _lifecycleWatcher = null;
    WidgetsBinding.instance.removeObserver(watcher);
  }

  /// Fired when the OS reports the app is detaching (process kill). Best-effort:
  /// `detached` is delivered mainly on Android task-removal and is not guaranteed
  /// before an iOS swipe-kill, so the server seat reconciler is the real backstop.
  void _onAppDetached() {
    if (!leaveSeatOnAppKill) return;
    _leaveSeatBestEffort();
    unawaited(_roomManager.disconnect());
  }

  Future<void> sendChatMessage(String text) async {
    await chatController.sendMessage(text);
  }

  Future<void> sendRoomMessage(Map<String, dynamic> data) async {
    await _roomManager.sendData(data);
  }

  Future<void> sendTargetedMessage(
    Map<String, dynamic> data,
    List<String> identities,
  ) async {
    await _roomManager.sendData(data, destinationIdentities: identities);
  }

  /// Re-publish the local participant's cosmetic attributes mid-session (avatar,
  /// frame, frame geometry, color name changed in Profile or the Mall). LiveKit
  /// fans the change to everyone currently in the room AND to anyone who joins
  /// later, so seats stay fresh without leaving and re-entering. The passed map
  /// is merged onto the existing attributes so non-cosmetic keys are preserved.
  ///
  /// Cosmetic fields are published ONLY as RTC participant *attributes*, never
  /// participant metadata (the server owns metadata: role/_device/…). See the
  /// post-connect setAttributes in [connect]'s audioSetup for the same rule.
  /// Live profile change of another room member (see
  /// [SeatController.applyRemoteCosmeticOverride]).
  void applyRemoteCosmeticOverride(String identity, Map<String, String> attrs) =>
      seatController.applyRemoteCosmeticOverride(identity, attrs);

  Future<void> updateSelfAttributes(Map<String, String> attrs) async {
    final local = _roomManager.localParticipant;
    if (local == null || attrs.isEmpty) return;
    // Any key the app re-publishes is by definition a cosmetic — keep the seat
    // controller's live-authoritative set in sync so this change wins over the
    // stale `_seats` snapshot for local + remote seats.
    seatController.registerCosmeticKeys(attrs.keys);
    // Repaint the local user's own seat IMMEDIATELY. setAttributes below only
    // sends the change to the SFU and awaits an ack — it does NOT update
    // local.attributes, and the server does not necessarily echo the update back
    // to the sender, so the local seat would otherwise keep the stale cosmetics
    // until the user rejoins. This optimistic override closes that gap; the
    // eventual echo (if any) is then a no-op.
    seatController.applyLocalCosmeticOverride(local.identity, attrs);
    final merged = <String, String>{...local.attributes, ...attrs};
    try {
      await local.setAttributes(merged);
    } catch (e) {
      debugPrint('[UTDRoomController] updateSelfAttributes failed: $e');
    }
  }

  Stream<Map<String, dynamic>> get dataStream => _roomManager.dataStream;

  /// Cached identity→role map for the default seat grid's badges. Recomputed
  /// only when participants/roles actually change (the single [_emitParticipants]
  /// funnel), NOT on every 300ms speaking-poll grid rebuild — so the per-seat
  /// badge lookup costs nothing per tick instead of re-`jsonDecode`ing every
  /// participant's metadata. Mirrors the [participantRoles] getter's result.
  final ValueNotifier<Map<String, String>> participantRolesNotifier =
      ValueNotifier<Map<String, String>>(const <String, String>{});

  void refreshParticipants() {
    if (_disposed || _participantsController.isClosed) return;
    _emitParticipants();
  }

  /// Single funnel for participant-list + role-badge updates. Called from every
  /// participant event (join/leave/attributes/metadata), role changes, and the
  /// initial seed — so [participantRolesNotifier] stays in sync without the seat
  /// grid recomputing roles on each speaking-poll tick.
  void _emitParticipants() {
    if (_disposed || _participantsController.isClosed) return;
    participantRolesNotifier.value = participantRoles;
    _participantsController.add(participants);
  }

  List<UTDParticipant> get participants {
    final local = _roomManager.localParticipant;
    final remote = _roomManager.remoteParticipants;
    final all = <Participant>[if (local != null) local, ...remote];
    final result = <UTDParticipant>[];
    for (final p in all) {
      try {
        result.add(_toUTDParticipant(p));
      } catch (e) {
        // A participant can be disposed by the SDK between snapshotting the
        // list and reading its tracks (leave/teardown race). Skip it — it is
        // gone from the room anyway.
        debugPrint('[UTDRoomController] skipped disposed participant: $e');
      }
    }
    return result;
  }

  static UTDParticipant _toUTDParticipant(Participant p) {
    return UTDParticipant(
      id: p.identity.toString(),
      name: p.name,
      isMicEnabled: p.isMicrophoneEnabled(),
      isSpeaking: p.isSpeaking,
      attributes: Map<String, String>.from(p.attributes),
    );
  }

  /// Overlay of identity→role applied from `_role_change` messages and from
  /// the initial list-by-role seed. Takes precedence over `participant.metadata`
  /// because (a) `_role_change` is server-sent (the event `participant` is null)
  /// and may arrive before metadata propagates, and (b) it lets callers reflect
  /// roles for users who are not currently connected. Cleared on (re)connect.
  final Map<String, String> _roleCache = {};

  /// Gets the participant's role — from the [_roleCache] overlay first, then
  /// from their RTC metadata.
  String? getParticipantRole(String identity) {
    final cached = _roleCache[identity];
    if (cached != null) return cached;
    try {
      Participant? p;
      if (_roomManager.localParticipant?.identity == identity) {
        p = _roomManager.localParticipant;
      } else {
        p = _roomManager.remoteParticipants
            .where((rp) => rp.identity == identity)
            .firstOrNull;
      }
      if (p == null) return null;
      final meta = jsonDecode(p.metadata ?? '{}') as Map<String, dynamic>;
      return meta['role'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Gets the local participant's role.
  String? get localRole {
    final identity = _roomManager.localParticipant?.identity;
    if (identity == null) return null;
    return getParticipantRole(identity);
  }

  /// The local participant's identity, or `null` before connect. Convenience for
  /// the built-in default UI (seat sheet, controls bar, member list), which
  /// references the local identity repeatedly.
  String? get localIdentity => _roomManager.localParticipant?.identity;

  /// The seat index the local user currently occupies, or `-1` if not seated.
  int get localSeatIndex =>
      seatController.getSeatIndexByUserId(localIdentity ?? '');

  /// Whether the local participant is a host or admin.
  bool get isHostOrAdmin {
    final role = localRole;
    return role == 'host' || role == 'admin';
  }

  /// Whether the local user may currently send chat: always when comments are
  /// unlocked, otherwise only host/admin. The composer gates on this.
  bool get canIComment => !commentsLocked.value || isHostOrAdmin;

  /// Whether [identity]'s role is privileged (host or admin) — host/admin chat
  /// is still rendered while comments are locked.
  bool _isPrivileged(String identity) {
    final role = getParticipantRole(identity);
    return role == 'host' || role == 'admin';
  }

  /// Returns a map of all participant identities to their roles.
  /// Used by the seat grid to display role badges.
  Map<String, String> get participantRoles {
    final roles = <String, String>{};
    final local = _roomManager.localParticipant;
    final remote = _roomManager.remoteParticipants;
    final all = <Participant>[if (local != null) local, ...remote];

    for (final p in all) {
      try {
        final meta = jsonDecode(p.metadata ?? '{}') as Map<String, dynamic>;
        final role = meta['role'] as String?;
        if (role != null) {
          roles[p.identity.toString()] = role;
        }
      } catch (_) {}
    }
    // The `_role_change` overlay wins over metadata (see [_roleCache]).
    roles.addAll(_roleCache);
    return roles;
  }

  Future<UTDTokenResponse> generateToken({
    required String identity,
    required String roomName,
    required String roomOwnerId,
    String type = 'audio_room',
    String? name,
    String role = 'audience',
    int? seatCount,
    String? seatMode,
    int? hostSeat,
    String? modeId,
    String? deviceModel,
    String? os,
    String? osVersion,
    String? appVersion,
    String? deviceId,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) async {
    if (_tokenApi == null) {
      throw StateError('initApi() must be called before generateToken()');
    }
    // Resolve the stable per-install device id (single-active-session
    // enforcement) and auto-collect device facts (dashboard per-participant
    // view) when the host app didn't pass them. The two are independent
    // platform lookups — start both before awaiting either so a cold cache
    // costs one hop on the join path, not two. Explicit args still win;
    // neither ever throws.
    final deviceIdFuture =
        deviceId != null ? Future<String>.value(deviceId) : UTDDeviceId.resolve();
    final infoFuture = UTDDeviceInfoCollector.collect();
    final resolvedDeviceId = await deviceIdFuture;
    // Device facts are dashboard cosmetics — never let a cold platform channel
    // hold the token POST hostage. deviceId stays awaited (single-active-
    // session enforcement needs it); the info lookup keeps running and lands
    // in the collector's cache for the next join.
    final info = await infoFuture.timeout(
      const Duration(milliseconds: 150),
      onTimeout: () => const UTDDeviceInfo(),
    );

    final res = await _tokenApi!.generateToken(
      identity: identity,
      roomName: roomName,
      type: type,
      roomOwnerId: roomOwnerId,
      name: name,
      role: role,
      seatCount: seatCount,
      seatMode: seatMode,
      hostSeat: hostSeat,
      modeId: modeId,
      deviceModel: deviceModel ?? info.deviceModel,
      os: os ?? info.os,
      osVersion: osVersion ?? info.osVersion,
      appVersion: appVersion ?? info.appVersion,
      deviceId: resolvedDeviceId,
      imageUrl: imageUrl,
      metadata: metadata,
    );
    // The in-room clients carry no secret, so authenticate them with the per-user bearer the
    // engine just minted.
    _applyUserToken(res.userToken);
    // Remember the RTC edge URL (stable per project+region) so the NEXT join
    // can pre-warm DNS/TLS to it in parallel with its token request.
    UTDConnectionPrewarm.rememberRtcUrl(res.url);
    return res;
  }

  // ---------------------------------------------------------------------------
  // Speaker Request helpers (convenience wrappers around speakerApi)
  // ---------------------------------------------------------------------------

  /// The room ID used for speaker API calls.
  /// Prefers [seatController.roomId] (set via connect roomName param),
  /// falls back to the RTC room name.
  String? get _speakerRoomId => seatController.roomId ?? _roomManager.room?.name;

  /// Request to speak (audience in request mode).
  ///
  /// Pass [seatIndex] when the user asked for one particular tile so the host's
  /// approval seats them there instead of wherever happens to be free.
  Future<Map<String, dynamic>?> requestToSpeak({int? seatIndex}) async {
    if (_speakerApi == null) return null;
    final roomId = _speakerRoomId;
    final identity = _roomManager.localParticipant?.identity;
    if (roomId == null || identity == null) return null;

    try {
      return await _speakerApi!.requestToSpeak(
        roomName: roomId,
        identity: identity,
        seatIndex: seatIndex,
      );
    } catch (e) {
      debugPrint('[UTDRoomController] requestToSpeak error: $e');
      return null;
    }
  }

  /// Cancel speaker request.
  Future<bool> cancelSpeakerRequest() async {
    if (_speakerApi == null) return false;
    final roomId = _speakerRoomId;
    final identity = _roomManager.localParticipant?.identity;
    if (roomId == null || identity == null) return false;

    try {
      await _speakerApi!.cancelRequest(
        roomName: roomId,
        identity: identity,
      );
      return true;
    } catch (e) {
      debugPrint('[UTDRoomController] cancelSpeakerRequest error: $e');
      return false;
    }
  }

  /// Approve a speaker request (host/admin).
  Future<Map<String, dynamic>?> approveSpeakerRequest(int requestId) async {
    if (_speakerApi == null) return null;
    final roomId = _speakerRoomId;
    final identity = _roomManager.localParticipant?.identity;
    if (roomId == null || identity == null) return null;

    try {
      // Newer engines return the synced seat `state` — apply it so the
      // approving admin sees the requester seated without waiting for the
      // `_seat_update` broadcast (generation/room-guarded; no-op otherwise).
      final gen = seatController.applyGeneration;
      final res = await _speakerApi!.approveRequest(
        roomName: roomId,
        requestId: requestId,
        identity: identity,
      );
      seatController.applyMutationResponse(res, gen: gen, roomId: roomId);
      return res;
    } catch (e) {
      debugPrint('[UTDRoomController] approveSpeakerRequest error: $e');
      return null;
    }
  }

  /// Reject a speaker request (host/admin).
  Future<bool> rejectSpeakerRequest(int requestId) async {
    if (_speakerApi == null) return false;
    final roomId = _speakerRoomId;
    final identity = _roomManager.localParticipant?.identity;
    if (roomId == null || identity == null) return false;

    try {
      await _speakerApi!.rejectRequest(
        roomName: roomId,
        requestId: requestId,
        identity: identity,
      );
      return true;
    } catch (e) {
      debugPrint('[UTDRoomController] rejectSpeakerRequest error: $e');
      return false;
    }
  }

  /// Invite a user to speak (host/admin).
  ///
  /// [seatIndex] — optional target seat index. If provided, the invited user
  /// will be seated on this specific seat when they accept.
  Future<Map<String, dynamic>?> inviteToSpeak(
    String targetIdentity, {
    int? seatIndex,
  }) async {
    if (_speakerApi == null) return null;
    final roomId = _speakerRoomId;
    final identity = _roomManager.localParticipant?.identity;
    if (roomId == null || identity == null) return null;

    try {
      return await _speakerApi!.inviteToSpeak(
        roomName: roomId,
        identity: identity,
        targetIdentity: targetIdentity,
        seatIndex: seatIndex,
      );
    } catch (e) {
      debugPrint('[UTDRoomController] inviteToSpeak error: $e');
      return null;
    }
  }

  /// Accept a speaker invitation.
  Future<Map<String, dynamic>?> acceptInvitation(int invitationId) async {
    if (_speakerApi == null) return null;
    final roomId = _speakerRoomId;
    final identity = _roomManager.localParticipant?.identity;
    if (roomId == null || identity == null) return null;

    try {
      // Newer engines return the synced seat `state` — apply it so the
      // accepting guest renders their own seat without waiting for the
      // `_seat_update` broadcast (generation/room-guarded; no-op otherwise).
      final gen = seatController.applyGeneration;
      final res = await _speakerApi!.acceptInvitation(
        roomName: roomId,
        invitationId: invitationId,
        identity: identity,
      );
      seatController.applyMutationResponse(res, gen: gen, roomId: roomId);
      return res;
    } catch (e) {
      debugPrint('[UTDRoomController] acceptInvitation error: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Ban helpers (convenience wrappers around banApi)
  // ---------------------------------------------------------------------------

  /// Ban a user. Room-scoped by default; pass [global] `true` for a project-wide
  /// ban. [durationSeconds] null => permanent. Returns `true` on success.
  Future<bool> banUser(
    String identity, {
    String? reason,
    int? durationSeconds,
    bool global = false,
  }) async {
    if (_banApi == null) return false;
    final roomName = global ? null : _speakerRoomId;
    if (!global && roomName == null) return false;
    try {
      await _banApi!.banUser(
        identity: identity,
        roomName: roomName,
        reason: reason,
        durationSeconds: durationSeconds,
      );
      return true;
    } catch (e) {
      debugPrint('[UTDRoomController] banUser error: $e');
      return false;
    }
  }

  /// Remove a ban. Pass [global] `true` to lift a project-wide ban (sends no
  /// `room_name`). For a room-scoped ban, pass the ban's own [roomName] (the
  /// bans list is account-wide, so it may belong to a different room than the
  /// current one); when omitted it defaults to the current room. Returns `true`
  /// on success.
  Future<bool> unbanUser(
    String identity, {
    bool global = false,
    String? roomName,
  }) async {
    if (_banApi == null) return false;
    final effectiveRoom = global ? null : (roomName ?? _speakerRoomId);
    try {
      await _banApi!.unbanUser(identity: identity, roomName: effectiveRoom);
      return true;
    } catch (e) {
      debugPrint('[UTDRoomController] unbanUser error: $e');
      return false;
    }
  }

  /// List the project's active bans (paginated). Returns `null` on error.
  Future<UTDBanListPage?> listBans({int page = 1, int perPage = 20}) async {
    if (_banApi == null) return null;
    try {
      return await _banApi!.listBans(page: page, perPage: perPage);
    } catch (e) {
      debugPrint('[UTDRoomController] listBans error: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Role helpers (convenience wrappers around roleApi)
  // ---------------------------------------------------------------------------

  /// Changes [targetIdentity]'s [role]. Owner-only (the server enforces this and
  /// returns `403` for anyone else — gate the UI to the owner too).
  ///
  /// The actor is the local participant and the room is the current room.
  /// Returns the result on success; **throws** on REST error so the caller can
  /// map `403/404/409/422` to a user-facing message.
  Future<UTDRoleChangeResult> changeRole({
    required String targetIdentity,
    required String role,
  }) async {
    if (_roleApi == null) {
      throw StateError('initApi() must be called before changeRole()');
    }
    final roomName = _speakerRoomId;
    final actor = _roomManager.localParticipant?.identity;
    if (roomName == null || actor == null) {
      throw StateError('Room/actor not ready for changeRole()');
    }
    final result = await _roleApi!.changeRole(
      roomName: roomName,
      targetIdentity: targetIdentity,
      actorIdentity: actor,
      role: role,
    );
    // Optimistic — the broadcast `_role_change` confirms shortly after.
    if (result.identity.isNotEmpty) {
      _roleCache[result.identity] = result.role;
    }
    return result;
  }

  /// Self-upgrade to `admin` after an optimistic audience join: the app's
  /// enter-room response resolved AFTER connect and listed the local user as
  /// an admin. Calls the engine role endpoint with the room OWNER as the
  /// actor (the same client-asserted trust model as the token endpoint). The
  /// engine updates RTC permissions + metadata and broadcasts
  /// `_role_change`, which feeds [_roleCache]/[roleChangeStream] — so real
  /// moderation powers are granted, not just a local badge.
  ///
  /// Retries ×3 with 1s backoff: the engine `participants` row is
  /// webhook-created and may lag connect by a moment. A `409` (already in
  /// role) counts as success. Aborts if the controller is disposed, the room
  /// disconnects, or the room changed (room switch). Returns `true` when the
  /// admin role is in effect.
  Future<bool> upgradeSelfRole({
    required String ownerId,
    required String selfId,
  }) async {
    if (_roleApi == null) return false;
    final roomName = _speakerRoomId;
    if (roomName == null) return false;

    for (var attempt = 0; attempt < 3; attempt++) {
      if (attempt > 0) {
        await Future.delayed(const Duration(seconds: 1));
      }
      if (_disposed || !isConnected || _speakerRoomId != roomName) {
        return false;
      }
      try {
        final result = await _roleApi!.changeRole(
          roomName: roomName,
          targetIdentity: selfId,
          actorIdentity: ownerId,
          role: 'admin',
        );
        if (result.identity.isNotEmpty) {
          _roleCache[result.identity] = result.role;
        }
        refreshParticipants();
        return true;
      } on DioException catch (e) {
        if (e.response?.statusCode == 409) {
          // Already in role — the goal state is reached.
          _roleCache[selfId] = 'admin';
          refreshParticipants();
          return true;
        }
        debugPrint(
            '[UTDRoomController] upgradeSelfRole attempt ${attempt + 1} failed: '
            '${e.response?.statusCode ?? e.type}');
      } catch (e) {
        debugPrint(
            '[UTDRoomController] upgradeSelfRole attempt ${attempt + 1} failed: $e');
      }
    }
    return false;
  }

  /// Lists participants holding [role] (paginated). Returns `null` on error.
  Future<UTDRoleListPage?> listByRole(
    String role, {
    int page = 1,
    int perPage = 20,
  }) async {
    if (_roleApi == null) return null;
    final roomName = _speakerRoomId;
    if (roomName == null) return null;
    try {
      return await _roleApi!.listByRole(
        roomName: roomName,
        role: role,
        page: page,
        perPage: perPage,
      );
    } catch (e) {
      debugPrint('[UTDRoomController] listByRole error: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Comment lock helpers (convenience wrappers around commentApi)
  // ---------------------------------------------------------------------------

  /// Lock room chat so only host/admin can send (host/admin-only action).
  /// Returns `true` on success. State is NOT flipped optimistically — the
  /// server's `_chat_lock` broadcast + `chat_locked` metadata update
  /// [commentsLocked] on every device (including this one).
  Future<bool> lockComments() => setCommentsLocked(true);

  /// Unlock room chat for everyone (host/admin-only action). See [lockComments].
  Future<bool> unlockComments() => setCommentsLocked(false);

  /// Lock ([locked] true) or unlock room chat. Host/admin-only; the server
  /// returns `403` for anyone else, so gate the UI to host/admin too. Returns
  /// `true` on success, `false` on any error.
  Future<bool> setCommentsLocked(bool locked) async {
    if (_commentApi == null) return false;
    final roomName = _speakerRoomId;
    final identity = _roomManager.localParticipant?.identity;
    if (roomName == null || identity == null) return false;
    try {
      if (locked) {
        await _commentApi!.lock(roomName: roomName, identity: identity);
      } else {
        await _commentApi!.unlock(roomName: roomName, identity: identity);
      }
      return true;
    } catch (e) {
      debugPrint('[UTDRoomController] setCommentsLocked error: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Invitation handling — full flow managed by the package
  // ---------------------------------------------------------------------------

  /// Fired exactly once when the LOCAL user is banned, from any source:
  /// - a `_banned` data message (richest: reason + expiry),
  /// - `DisconnectReason.participantRemoved` (fallback, reason unknown),
  /// - a token `403 User is banned` on (re)join.
  ///
  /// The [UTDAudioRoom] widget wires this internally to show the banned dialog
  /// and leave the room. De-duplicated via [_emitBanned].
  void Function(UTDBanNotice notice)? onBanned;

  /// Guards against firing [onBanned] more than once (e.g. the `_banned`
  /// message and the participant-removed disconnect that follows it).
  bool _banHandled = false;

  void _emitBanned(UTDBanNotice notice) {
    if (_banHandled) return;
    _banHandled = true;
    onBanned?.call(notice);
  }

  /// Surfaces a token `403 User is banned` as a ban notice. Called by the
  /// widget when [generateToken] throws [UTDBannedException].
  void notifyBannedFromToken() {
    _emitBanned(const UTDBanNotice.fromTokenForbidden());
  }

  /// Callback that the app sets to show an invitation UI to the user.
  /// Should return `true` if the user accepts, `false` if they decline.
  /// The package calls this when a `_speaker_invitation` event is received.
  ///
  /// The data map contains:
  /// - `invitation_id` (int)
  /// - `inviter_identity` (String)
  /// - `target_identity` (String)
  /// - `seat_index` (int?) — the specific seat the user is invited to
  ///
  /// Example usage from the app:
  /// ```dart
  /// controller.onInvitationUI = (data) async {
  ///   return await showMyInvitationDialog(data); // returns true/false
  /// };
  /// ```
  Future<bool> Function(Map<String, dynamic> data)? onInvitationUI;

  /// Navigator key for showing default dialogs.
  /// Must be set by the app if using the default invitation dialog.
  /// Example: `controller.navigatorKey = navKey;`
  GlobalKey<NavigatorState>? navigatorKey;

  /// Shows the default invitation dialog built into the package.
  /// Used when [onInvitationUI] is not set by the app.
  /// Returns `true` if accepted, `false` if declined.
  Future<bool> _showDefaultInvitationDialog(Map<String, dynamic> data) async {
    final ctx = navigatorKey?.currentState?.context;
    if (ctx == null) return false;

    final inviterIdentity = data['inviter_identity'] as String?;
    final seatIndex = (data['seat_index'] as num?)?.toInt();
    final seatDisplay = seatIndex != null ? '${seatIndex + 1}' : '?';

    final completer = Completer<bool>();

    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.mic, color: Colors.blue, size: 24),
            SizedBox(width: 8),
            Text('Speaker Invitation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Admin ${inviterIdentity ?? ''} invited you to sit on seat #$seatDisplay',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            // Secondary Arabic line: this dialog is the package's own fallback
            // and has no localization, so it only renders when the ambient
            // locale is Arabic instead of on every language.
            if (Localizations.maybeLocaleOf(dialogCtx)?.languageCode ==
                'ar') ...[
              const SizedBox(height: 8),
              Text(
                'المشرف ${inviterIdentity ?? ''} دعاك للجلوس على الكرسي رقم $seatDisplay',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              if (!completer.isCompleted) completer.complete(false);
            },
            child: const Text('Decline', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              if (!completer.isCompleted) completer.complete(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    ).then((_) {
      if (!completer.isCompleted) completer.complete(false);
    });

    return completer.future;
  }

  /// Called internally when a `_speaker_invitation` event arrives.
  /// Handles the full invitation flow:
  /// 1. Calls [onInvitationUI] (or default dialog) to let the app show UI
  /// 2. If accepted → calls acceptInvitation API
  /// 3. If backend didn't auto-seat → falls back to takeSeat
  /// 4. Enables microphone
  /// 5. If declined → calls declineInvitation API
  Future<void> handleIncomingInvitation(Map<String, dynamic> data) async {
    final invitationId = (data['invitation_id'] as num?)?.toInt();
    final seatIndex = (data['seat_index'] as num?)?.toInt();
    if (invitationId == null) return;

    // Ask the app to show UI and get user's decision.
    // If onInvitationUI is set, use it. Otherwise, use the default dialog.
    final bool accepted;
    if (onInvitationUI != null) {
      accepted = await onInvitationUI!.call(data);
    } else {
      accepted = await _showDefaultInvitationDialog(data);
    }

    if (accepted) {
      try {
        // Accept via API — backend should auto-seat user on seatIndex
        final result = await acceptInvitation(invitationId);
        debugPrint(
            '[UTDRoomController] handleIncomingInvitation — accept result: $result');

        // Check if backend seated the user
        final seatedAt = (result?['seat_index'] as num?)?.toInt();
        if (seatedAt == null && seatIndex != null) {
          // Backend didn't auto-seat — fallback to takeSeat
          debugPrint(
              '[UTDRoomController] handleIncomingInvitation — fallback takeSeat($seatIndex)');
          final identity = _roomManager.localParticipant?.identity;
          if (identity != null) {
            await seatController.takeSeat(seatIndex, identity);
          }
        }

        // Enable microphone after a short delay. Guard against the room being
        // left/disposed during the delay — a late publish on a torn-down room
        // is the addTransceiver track-is-null fatal.
        Future.delayed(const Duration(milliseconds: 500), () async {
          if (_disposed || !isConnected) return;
          await mediaController.setMicrophoneEnabled(true);
          // Re-apply BT routing now that a local mic track is being published.
          await mediaController.applyBluetoothAudioRouting();
        });
      } catch (e) {
        debugPrint(
            '[UTDRoomController] handleIncomingInvitation — accept error: $e');
        // Fallback: try to take seat directly
        if (seatIndex != null) {
          final identity = _roomManager.localParticipant?.identity;
          if (identity != null) {
            try {
              await seatController.takeSeat(seatIndex, identity);
              Future.delayed(const Duration(milliseconds: 500), () async {
                if (_disposed || !isConnected) return;
                await mediaController.setMicrophoneEnabled(true);
                await mediaController.applyBluetoothAudioRouting();
              });
            } catch (_) {}
          }
        }
      }
    } else {
      // User declined
      await declineInvitation(invitationId);
    }
  }

  /// Decline a speaker invitation.
  Future<bool> declineInvitation(int invitationId) async {
    if (_speakerApi == null) return false;
    final roomId = _speakerRoomId;
    final identity = _roomManager.localParticipant?.identity;
    if (roomId == null || identity == null) return false;

    try {
      await _speakerApi!.declineInvitation(
        roomName: roomId,
        invitationId: invitationId,
        identity: identity,
      );
      return true;
    } catch (e) {
      debugPrint('[UTDRoomController] declineInvitation error: $e');
      return false;
    }
  }

  bool _disposed = false;

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _unregisterLifecycleWatcher();
    if (_activeController == this) _activeController = null;
    debugPrint(
        '🚪 [EXIT] UTDRoomController.dispose() — releasing all resources...');

    _speakingPollTimer?.cancel();
    _speakingPollTimer = null;
    _participantJoinedSub?.cancel();
    _participantLeftSub?.cancel();
    _participantAttributesChangedSub?.cancel();
    _participantMetadataChangedSub?.cancel();
    _activeSpeakersSub?.cancel();
    _activeSpeakersSub = null;
    _participantsController.close();
    _roleChangeController.close();
    onRoleChanged = null;
    _roleCache.clear();
    if (_modeIdSyncListener != null) {
      seatController.modeId.removeListener(_modeIdSyncListener!);
      _modeIdSyncListener = null;
    }
    pip.dispose();
    activeSpeakers.dispose();
    mutedParticipants.dispose();
    commentsLocked.dispose();
    participantRolesNotifier.dispose();
    currentMode.dispose();
    seatController.dispose();
    mediaController.dispose();
    chatController.dispose();
    _roomManager.dispose();
    _apiClient?.dispose();
    _tokenClient?.dispose();
    _apiClient = null;
    _tokenClient = null;
    _tokenApi = null;
    _seatApi = null;
    _speakerApi = null;
    _banApi = null;
    _roleApi = null;
    _commentApi = null;
    onBanned = null;
    debugPrint(
        '🚪 [EXIT] UTDRoomController.dispose() — done, all resources released');
  }
}

/// Minimal [WidgetsBindingObserver] that fires [onDetached] when the app process
/// is being torn down. Owned by [UTDRoomController] so lifecycle observation
/// survives a room minimize (where the room widget — and its own observers — are
/// disposed, but the controller lives on for the floating overlay).
class _UTDAppLifecycleWatcher with WidgetsBindingObserver {
  _UTDAppLifecycleWatcher(this.onDetached);

  final VoidCallback onDetached;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only `detached` (process kill) acts. paused/inactive/hidden are normal
    // backgrounding (incl. minimize / OS PiP) and must keep the user in the room.
    if (state == AppLifecycleState.detached) onDetached();
  }
}
