import 'dart:async';
import 'dart:convert';

import 'package:centrifuge/centrifuge.dart' as centrifuge;
import 'package:drift/drift.dart' show Value;
import 'package:general/src/core/database/app_database.dart' show RoomsCompanion;
import 'package:general/src/core/database/daos/messages_dao.dart';
import 'package:general/src/core/database/daos/rooms_dao.dart';
import 'package:general/src/core/database/daos/sync_state_dao.dart';
import 'package:general/src/core/database/tables/chat_tables.dart'
    show MessageDeleteState, RoomType;
import 'package:general/src/core/index.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:general/src/core/realtime/in_app_chat_notifier.dart';
import 'package:general/src/core/realtime/realtime_config.dart';
import 'package:general/src/core/realtime/realtime_message_mapper.dart';
import 'package:general/src/core/realtime/realtime_token_service.dart';
import 'package:general/src/core/realtime/sync_engine.dart';

/// Centrifugo transport for everything OUTSIDE the room (Plan section 7.4).
///
/// Replaces the legacy realtime receive path. Responsibilities:
///  - open one WebSocket using a connection JWT from [RealtimeTokenService]
///    (the SDK auto-refreshes it via the `getToken` callback before expiry),
///  - subscribe to the user's personal channel `user:#{id}` and, on demand, the
///    1:1 chat channel (subscription token),
///  - write every incoming publication into drift via [MessagesDao] /
///    [RoomsDao] — never straight to the UI; the UI reacts off drift streams,
///  - drive [SyncEngine] when recovery fails (`recovered:false`) or the channel
///    epoch rotates,
///  - manage [AppLifecycleState]: disconnect on background, reconnect on
///    foreground (mobile OSes silently kill backgrounded sockets, which would
///    otherwise present as a dead connection + silent message loss).
///
/// This file is additive: it does not touch the existing legacy realtime path or any UI
/// wiring (that is the next task).
class RealtimeClient with WidgetsBindingObserver {
  RealtimeClient({
    required RealtimeTokenService tokenService,
    required MessagesDao messagesDao,
    required RoomsDao roomsDao,
    required SyncStateDao syncStateDao,
    required SyncEngine syncEngine,
    RealtimeMessageMapper mapper = const RealtimeMessageMapper(),
    String? wssUrl,
  })  : _tokenService = tokenService,
        _messagesDao = messagesDao,
        _roomsDao = roomsDao,
        _syncStateDao = syncStateDao,
        _syncEngine = syncEngine,
        _mapper = mapper,
        _overrideWssUrl = wssUrl;

  final RealtimeTokenService _tokenService;
  final MessagesDao _messagesDao;
  final RoomsDao _roomsDao;
  final SyncStateDao _syncStateDao;
  final SyncEngine _syncEngine;
  final RealtimeMessageMapper _mapper;
  // Tests can pin a URL via the constructor; production reads the live value
  // from `RealtimeConfig` at connect time so a backend-pushed override (via
  // `/config/settings`) takes effect without a rebuild.
  final String? _overrideWssUrl;

  String get _wssUrl {
    if (_overrideWssUrl != null && _overrideWssUrl.isNotEmpty) {
      return _overrideWssUrl;
    }
    final live = RealtimeConfig.wsUrl;
    return live.isNotEmpty ? live : EndPoints.centrifugoWss;
  }

  centrifuge.Client? _client;
  centrifuge.Subscription? _userSub;
  final Map<String, _ChatChannel> _chatChannels = {};
  // In-flight close teardowns per channel key, so a fast reopen can AWAIT a
  // pending close before re-subscribing. Without this, closeChat removes the key
  // from [_chatChannels] synchronously but unsubscribe/removeSubscription run
  // async — a close+reopen race re-runs newSubscription while the SDK registry
  // still holds the channel, which throws "Subscription already exists" and
  // silently loses the live subscription for that conversation.
  final Map<String, Future<void>> _closingChannels = {};
  final List<StreamSubscription<dynamic>> _clientSubs = [];

  // Outside-room banner/counter events (gift / lucky-box / super-boom /
  // close-zego / unread-counter / game-status) ride the SAME socket but are NOT
  // chat messages. They are routed off the publication handlers BEFORE the
  // drift/message path and re-emitted here for the legacy banner consumers
  // (get_my_data_bloc) to drive their existing controllers — gated app-side by
  // `kUseRealtimeBanners` so old builds stay on legacy realtime. Broadcast so it is safe
  // even when nobody is listening (flag off).
  final StreamController<RealtimeNonChatEvent> _nonChatController =
      StreamController<RealtimeNonChatEvent>.broadcast();

  /// Outside-room non-chat events (banners + per-user counters/status) decoded
  /// off the realtime socket. The consumer routes by [RealtimeNonChatEvent.event].
  Stream<RealtimeNonChatEvent> get nonChatEvents => _nonChatController.stream;

  bool _started = false;
  bool _lifecycleBound = false;

  // Deferred-start retry (when MyDataModel isn't populated yet at first call).
  // Cancellable + bounded so a pending retry can never revive the socket after
  // stop()/logout, nor spin forever if the user id never lands.
  Timer? _startRetryTimer;
  int _startRetries = 0;
  static const int _maxStartRetries = 30;

  // Throttle for decode-failure breadcrumbs so a sustained payload-shape
  // regression can't spam the logs/Crashlytics; one signal per window is enough
  // to make a previously-invisible dead-decode visible.
  DateTime? _lastDecodeReportAt;
  static const Duration _decodeReportWindow = Duration(seconds: 30);

  /// Start the realtime layer for the signed-in user. Idempotent.
  Future<void> start() async {
    final userId = MyDataModel.getInstance().id;
    Methods.printLog('[Realtime] start() called _started=$_started userId=$userId');
    if (_started) return;
    if (userId == null || userId == 0) {
      // User not loaded yet (layout can mount before MyDataModel is populated);
      // retry shortly instead of giving up permanently — but bounded and
      // cancellable so it can't outlive a stop() or loop forever.
      _startRetryTimer?.cancel();
      if (_startRetries >= _maxStartRetries) {
        Methods.printLog('[Realtime] start() giving up — user never became ready');
        return;
      }
      _startRetries++;
      Methods.printLog('[Realtime] start() deferred — user not ready, retrying in 2s ($_startRetries/$_maxStartRetries)');
      _startRetryTimer = Timer(const Duration(seconds: 2), start);
      return;
    }
    // The realtime WS URL comes from /config/settings (RealtimeConfig.wsUrl),
    // populated asynchronously AFTER login. start() can win that race (its 2s
    // deferred retry fires before the settings HTTP response returns), so guard
    // on a non-empty URL too — otherwise the client latches _started=true and
    // builds a dead empty-URL socket that never reconnects once the real URL
    // arrives (server then shows 0 connected clients).
    if (_wssUrl.isEmpty) {
      _startRetryTimer?.cancel();
      if (_startRetries >= _maxStartRetries) {
        Methods.printLog('[Realtime] start() giving up — realtime URL never arrived');
        return;
      }
      _startRetries++;
      Methods.printLog('[Realtime] start() deferred — realtime URL not ready, retry in 2s ($_startRetries/$_maxStartRetries)');
      _startRetryTimer = Timer(const Duration(seconds: 2), start);
      return;
    }

    // User + URL ready: drop any pending deferred retry and reset the counter.
    _startRetryTimer?.cancel();
    _startRetryTimer = null;
    _startRetries = 0;
    _started = true;

    if (!_lifecycleBound) {
      WidgetsBinding.instance.addObserver(this);
      _lifecycleBound = true;
    }

    final client = centrifuge.createClient(
      _wssUrl,
      centrifuge.ClientConfig(
        getToken: (_) async {
          try {
            return await _tokenService.connectionToken();
          } catch (e, st) {
            _reportRealtimeFailure('getConnectionToken', e, st);
            rethrow; // let the SDK retry on its schedule
          }
        },
      ),
    );
    _client = client;

    // Diagnostic logging for the realtime bring-up (temporary).
    Methods.printLog('[Realtime] start() user=$userId url=$_wssUrl');
    _clientSubs.add(client.connecting.listen((e) => Methods.printLog('[Realtime] connecting: $e')));
    _clientSubs.add(client.connected.listen((e) {
      Methods.printLog('[Realtime] CONNECTED: $e');
      // Catch the chats list up on every (re)connect. user:#{id} recovery
      // replays missed publications when history is available, but recovery can
      // be unavailable (epoch rotation / history eviction past the retention
      // window); a rooms-list sync is the authoritative fallback so groups and
      // closed DMs that changed during the gap still surface. The engine guards
      // against overlapping syncs, so firing it here is safe.
      unawaited(_syncEngine.syncRoomsList());
    }));
    _clientSubs.add(client.disconnected.listen((e) => Methods.printLog('[Realtime] DISCONNECTED: $e')));
    _clientSubs.add(client.error.listen((e) {
      Methods.printLog('[Realtime] ERROR: $e');
      // Transport aborts (SocketException errno 103, WebSocketChannelException)
      // are normal, recoverable reconnect blips that the SDK retries on its own
      // schedule — log a breadcrumb so the lead-up to a real crash stays
      // visible, but do NOT record them as non-fatal crashes (pure dashboard
      // noise). Genuine config/auth breakage (ConnectError/RefreshError/server
      // Error) still gets reported.
      if (e.error is centrifuge.TransportError) {
        Methods.logBreadcrumb('[Realtime] transport error (recoverable): ${e.error} url=$_wssUrl');
        return;
      }
      // Surface real socket-level errors in Crashlytics — currently silently
      // swallowed, so dead connections show up only as "messages aren't
      // arriving" with no signal in the dashboard.
      _reportRealtimeFailure('client.error', e);
    }));

    // Server-side (auto-subscribed) publications deliver on the client-level
    // stream. The connection JWT's `channels` claim now carries ONLY the public
    // banner channels (WAVE-1); user:#{id} is NOT in the JWT — the client creates
    // that subscription itself in _subscribeUserChannel (authorized by `sub`).
    _clientSubs.add(client.publication.listen(_onServerPublication));

    // If the synchronous bring-up throws (token/network), roll `_started` back
    // and tear down the half-open client so a later start() can retry — without
    // this, `_started` latched true permanently and the realtime layer stayed
    // dead for the rest of the session (user:#{id} is the only path for groups
    // and closed DMs).
    try {
      await _subscribeUserChannel(userId);
      await _safeConnect();
    } catch (e, st) {
      _started = false;
      _reportRealtimeFailure('start.bringUp', e, st);
      await stop();
      rethrow;
    }
  }

  /// Tear everything down (logout / dispose).
  Future<void> stop() async {
    _started = false;
    // Kill any pending deferred-start retry so it can't revive the socket after
    // a logout/teardown.
    _startRetryTimer?.cancel();
    _startRetryTimer = null;
    if (_lifecycleBound) {
      WidgetsBinding.instance.removeObserver(this);
      _lifecycleBound = false;
    }
    for (final sub in _clientSubs) {
      await sub.cancel();
    }
    _clientSubs.clear();
    for (final ch in _chatChannels.values) {
      await ch.dispose();
    }
    _chatChannels.clear();
    final userSub = _userSub;
    if (userSub != null) {
      await userSub.unsubscribe();
    }
    _userSub = null;
    await _client?.disconnect();
    _client = null;
  }

  // --- AppLifecycle (mandatory) ---------------------------------------------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_started) return;
    if (state == AppLifecycleState.resumed) {
      unawaited(_safeConnect());
      // Foreground catch-up: even if the socket reconnects without recovery, a
      // rooms-list sync pulls anything that changed while backgrounded (groups +
      // closed DMs ride only user:#{id}, which the OS may have killed silently).
      unawaited(_syncEngine.syncRoomsList());
    } else {
      // paused / inactive / hidden / detached -> release the socket so the OS
      // doesn't leave us with a half-dead connection.
      unawaited(_client?.disconnect());
    }
  }

  // --- 1:1 chat channels -----------------------------------------------------

  /// Subscribe to a peer's 1:1 chat channel. Call when a conversation opens.
  /// [roomLocalId] + [serverRoomId] tie publications + recovery back to drift.
  Future<void> openChat({
    required int peerUserId,
    required int roomLocalId,
    required int serverRoomId,
  }) async {
    final client = _client;
    if (client == null) return;

    final key = 'peer:$peerUserId';
    if (_chatChannels.containsKey(key)) return;
    final name = _chatChannelName(peerUserId);

    // Serialize against any in-flight close for the same key, then reconcile
    // against the SDK registry (the single source of truth) so newSubscription
    // can never throw "Subscription already exists" on a fast close+reopen.
    final sub = await _newSubscriptionReconciled(
      client,
      key,
      name,
      centrifuge.SubscriptionConfig(
        getToken: (_) async {
          try {
            return await _tokenService.subscriptionToken(
              peerUserId: peerUserId,
            );
          } catch (e, st) {
            _reportRealtimeFailure(
              'getSubscriptionToken/peer:$peerUserId',
              e,
              st,
            );
            // A definitive server refusal (403 blocked/self, 422 unknown peer)
            // can never succeed by retrying — rethrowing it left the SDK in an
            // endless backoff loop hammering /centrifugo/subscription for as
            // long as the conversation stayed open (~50% of the 2,248x403/24h
            // measured in production were <30s repeats from the same client).
            // UnauthorizedException makes the SDK fail the subscription
            // permanently instead.
            final status = e is DioException ? e.response?.statusCode : null;
            if (status == 403 || status == 422) {
              throw centrifuge.UnauthorizedException(
                'subscription refused ($status) for peer:$peerUserId',
              );
            }
            rethrow; // transient (network/5xx): let the SDK retry on schedule
          }
        },
        recoverable: true,
        positioned: true,
      ),
    );
    if (sub == null) return;

    final channel = _ChatChannel(
      subscription: sub,
      roomLocalId: roomLocalId,
      serverRoomId: serverRoomId,
    );
    _chatChannels[key] = channel;

    channel.add(sub.publication.listen(
      (event) => _onChatPublication(channel, event),
    ));
    channel.add(sub.subscribed.listen(
      (event) => _onChatSubscribed(channel, event),
    ));

    // The user is now viewing this 1:1 conversation: suppress in-app banners
    // for messages from this peer while it is on screen.
    InAppChatNotifier.instance.setActivePeer(peerUserId);

    await sub.subscribe();
  }

  /// Unsubscribe from a peer's chat channel (conversation closed).
  Future<void> closeChat({required int peerUserId}) async {
    // Targeted clear: only drop the marker if it still points at THIS peer, so a
    // fast A→B switch (B already set active) is not wiped by A's close.
    InAppChatNotifier.instance.clearActivePeerIfMatches(peerUserId);
    final key = 'peer:$peerUserId';
    final channel = _chatChannels.remove(key);
    if (channel == null) return;
    await _teardownChannel(
      key: key,
      channel: channel,
      channelName: _chatChannelName(peerUserId),
    );
  }

  // --- group chat channels ---------------------------------------------------

  /// Subscribe to a group's channel when its chat opens. Group MESSAGES arrive
  /// via the personal `user:#{id}` fan-out (handled by [_onUserPublication]);
  /// this channel carries presence / typing / live history-recovery signals and
  /// drives [SyncEngine] on (re)subscribe so an opened group catches up over
  /// REST even if it missed publications while backgrounded.
  Future<void> openGroupChat({
    required int serverGroupRoomId,
    required int roomLocalId,
  }) async {
    final client = _client;
    if (client == null) return;

    final key = 'group:$serverGroupRoomId';
    if (_chatChannels.containsKey(key)) return;
    final name = _groupChannelName(serverGroupRoomId);

    // Same close+reopen reconciliation as the 1:1 path.
    final sub = await _newSubscriptionReconciled(
      client,
      key,
      name,
      centrifuge.SubscriptionConfig(
        recoverable: true,
        positioned: true,
      ),
    );
    if (sub == null) return;

    final channel = _ChatChannel(
      subscription: sub,
      roomLocalId: roomLocalId,
      serverRoomId: serverGroupRoomId,
    );
    _chatChannels[key] = channel;

    channel.add(sub.publication.listen(
      (event) => _onChatPublication(channel, event),
    ));
    channel.add(sub.subscribed.listen(
      (event) => _onChatSubscribed(channel, event),
    ));

    // The user is now viewing this group: suppress in-app banners for it.
    InAppChatNotifier.instance.setActiveGroup(serverGroupRoomId);

    await sub.subscribe();
  }

  /// Unsubscribe from a group's channel (group chat closed).
  Future<void> closeGroupChat({required int serverGroupRoomId}) async {
    // Targeted clear: only drop the marker if it still points at THIS group, so
    // a fast A→B switch (B already set active) is not wiped by A's close.
    InAppChatNotifier.instance.clearActiveGroupIfMatches(serverGroupRoomId);
    final key = 'group:$serverGroupRoomId';
    final channel = _chatChannels.remove(key);
    if (channel == null) return;
    await _teardownChannel(
      key: key,
      channel: channel,
      channelName: _groupChannelName(serverGroupRoomId),
    );
  }

  String _groupChannelName(int serverGroupRoomId) =>
      'groups:room.$serverGroupRoomId';

  /// Create a new subscription for [key]/[name] after fully reconciling against
  /// any in-flight close AND the SDK subscription registry, so newSubscription
  /// can never throw "Subscription already exists" on a fast close+reopen.
  /// Returns null (and records a breadcrumb) if creation still fails, so the
  /// loss is no longer silent. Caller wires the listeners + subscribes.
  Future<centrifuge.Subscription?> _newSubscriptionReconciled(
    centrifuge.Client client,
    String key,
    String name,
    centrifuge.SubscriptionConfig config,
  ) async {
    // 1) Await any pending close for the same key (its registry removal must
    //    complete before we re-create the subscription).
    final pending = _closingChannels[key];
    if (pending != null) {
      try {
        await pending;
      } catch (_) {/* a failed teardown still clears below */}
    }
    // 2) Defensively drop any leftover registry entry — the in-flight check can
    //    miss by a frame if the close wasn't registered yet, so the registry is
    //    the actual safety net that makes open idempotent.
    final stale = client.getSubscription(name);
    if (stale != null) {
      try {
        await client.removeSubscription(stale);
      } catch (_) {/* best-effort; newSubscription guarded below */}
    }
    try {
      return client.newSubscription(name, config);
    } catch (e, st) {
      // Previously swallowed in the caller's catch — surface it so a recurring
      // subscribe failure is visible instead of presenting as "sometimes chat
      // doesn't update live".
      _reportRealtimeFailure('newSubscription/$key', e, st);
      return null;
    }
  }

  /// Tear down a chat/group channel and register the teardown future in
  /// [_closingChannels] so a fast reopen for the same key can await it before
  /// re-subscribing. Removed from the map on completion.
  Future<void> _teardownChannel({
    required String key,
    required _ChatChannel channel,
    required String channelName,
  }) async {
    final fut = () async {
      await channel.dispose();
      final client = _client;
      if (client == null) return;
      final sub = client.getSubscription(channelName);
      if (sub != null) {
        // removeSubscription() unsubscribes internally; no separate unsubscribe.
        await client.removeSubscription(sub);
      }
    }();
    _closingChannels[key] = fut;
    try {
      await fut;
    } finally {
      // Only clear if this exact future is still the registered one (a newer
      // open/close cycle may have replaced it).
      if (identical(_closingChannels[key], fut)) {
        _closingChannels.remove(key);
      }
    }
  }

  // --- internals -------------------------------------------------------------

  Future<void> _subscribeUserChannel(int userId) async {
    final client = _client;
    if (client == null) return;
    // Recoverable + positioned so Centrifugo replays publications missed during a
    // reconnect gap (background->foreground / network blip). user:#{id} is the
    // ONLY realtime path for groups and closed DMs, so without recovery those
    // messages + unread counters published during the gap are lost permanently.
    // The live 'user' namespace has history + force_recovery enabled.
    final sub = client.newSubscription(
      'user:#$userId',
      centrifuge.SubscriptionConfig(
        recoverable: true,
        positioned: true,
      ),
    );
    _userSub = sub;
    _clientSubs.add(sub.publication.listen(_onUserPublication));
    await sub.subscribe();
  }

  Future<void> _safeConnect() async {
    try {
      // Force a fresh connection JWT on every explicit (re)connect. The SDK
      // caches the last token and reuses it on connect() — getToken only runs
      // when the cached token is empty or a 109 was already received — so a
      // foreground resume after a long background gap dialed out with a dead
      // token and was refused with code 109 (token expired), cutting realtime
      // (chat/banners) until the SDK's retry cycle refetched. Clearing the
      // cached token routes the connect through the getToken callback, which
      // always POSTs /centrifugo/token for a live JWT.
      _client?.setToken('');
      await _client?.connect();
    } catch (e, stack) {
      Methods.printLog('[Realtime] connect() threw: $e');
      // The SDK reconnects on its own schedule, but record the throw so an
      // outage is visible — silent reconnection loops hide config breakage.
      _reportRealtimeFailure('connect', e, stack);
    }
  }

  /// Non-fatal Crashlytics breadcrumb + report for realtime failures (token,
  /// socket, connect). Wrapped so logging never throws back into the SDK.
  void _reportRealtimeFailure(String stage, Object error, [StackTrace? stack]) {
    try {
      Methods.logBreadcrumb('[Realtime] $stage failed: $error url=$_wssUrl');
      FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        reason: 'realtime/$stage',
        fatal: false,
      );
    } catch (_) {/* never throw from logging */}
  }

  /// Genuine chat-message events that create/update message rows. Every other
  /// event on these channels (open_chat, getChatUsersBloc, ...) carries room
  /// metadata or a signal — NOT a message — and must never be parsed as one, or
  /// it inserts a phantom empty row and bumps the room to the top with a stale
  /// preview (the regression seen after payload-unwrapping was fixed).
  static const _messageEvents = {
    'update-conversation-list',
    'getGroupMessageBloc',
  };

  /// Outside-room banner/counter events (Phase 9 legacy realtime → Centrifugo migration,
  /// WAVE 1 + WAVE 2). These are NON-message signals: when one is seen on ANY
  /// publication handler it is re-emitted on [nonChatEvents] and the handler
  /// short-circuits, so it can NEVER be parsed as a chat message (no phantom
  /// drift row, no room bump). The legacy banner consumers (get_my_data_bloc)
  /// drive their existing controllers off [nonChatEvents], gated by
  /// `kUseRealtimeBanners`.
  ///
  /// WAVE 2 (lucky-gift / games / room-comment) keeps the backend `broadcastAs`
  /// event name verbatim (`win.lucky.gift.event` / `game.win.event` /
  /// `room.comment.event`); their `payload` is the `{messageContent: {...}}` Map
  /// the legacy realtime consumers already read via `data[messageContent]`, so
  /// forwarding the unwrapped Map keeps payload parity.
  static const _nonChatEvents = {
    // WAVE 1
    'gift_banner',
    'superLuckBox',
    'end_room_boom',
    'zego_feature',
    'UnreadCounterIndividual',
    'status-user',
    // WAVE 2
    'win.lucky.gift.event',
    'game.win.event',
    'room.comment.event',
    // In-room boom winner reveal (migrated off legacy realtime presence
    // `room.boom.rewards.{id}` → Centrifugo). Payload carries `winners`; the
    // get_my_data consumer routes it to BoomWinnerHandler, which self-filters by
    // the signed-in user id, so a shared banner channel is safe.
    'room_boom_rewards',
    // Rocket room-reward mini-game (Phase 2 realtime). Backend sends these
    // with `action_type` as the discriminator inside the payload itself (not
    // as the envelope's `_event`/broadcastAs name); the backend team confirmed
    // the broadcastAs name matches `action_type` verbatim, same WAVE-2 shape
    // as win.lucky.gift.event etc. The get_my_data consumer routes all four to
    // RocketRealtimeController, which re-dispatches on the payload's own
    // `action_type` field.
    'rocket_progress_updated',
    'rocket_launched',
    'rocket_session_reset',
    'rocket_session_expired',
    // Room Support (weekly room-reward/partner) mini-feature. Same WAVE-2
    // action_type-discriminated shape; the get_my_data consumer routes it to
    // RoomSupportRealtimeController.
    'room_support_updated',
    // Backend `user_profile_updated` (name / photo / cover changed). Same
    // `live.stream.event` envelope, action_type inside the payload.
    'live.stream.event',
  };

  /// If [json] is a WAVE-1 outside-room banner/counter event, forward its
  /// payload on [nonChatEvents] and return true to short-circuit the calling
  /// publication handler before the chat/message path. The forwarded payload is
  /// the unwrapped object as the legacy realtime consumers expect it: a flat Map
  /// for most events, the raw List for `superLuckBox` (consumer takes .first).
  bool _routeNonChatEvent(Map<String, dynamic> json) {
    final ev = json['_event'];
    if (ev is! String || !_nonChatEvents.contains(ev)) return false;
    // List-payload events (superLuckBox) are decoded into {_event, payload}; all
    // others carry the unwrapped Map directly (with `_event` injected, which the
    // consumers ignore).
    final dynamic payload = json.containsKey('payload') ? json['payload'] : json;
    _nonChatController.add(RealtimeNonChatEvent(event: ev, payload: payload));
    return true;
  }

  bool _isStatusUpdate(Map<String, dynamic> json) =>
      json['_event'] == 'status_update' || json['type'] == 'status_update';

  /// A teardown signal published when a group is deleted server-side. It is NOT a
  /// message (creates no row); it instructs the client to drop the group's drift
  /// room so the offline-first chats list loses it live, for every member.
  bool _isGroupDeleted(Map<String, dynamic> json) =>
      json['_event'] == 'group_deleted' || json['type'] == 'group_deleted';

  /// A group metadata update (name/avatar/privacy/join_policy/only_admins_post)
  /// published to every member. NOT a message: it updates the drift room header
  /// in-place (so the unified chats list + open group header refresh live) and is
  /// re-emitted on [nonChatEvents] so the in-memory groups tab can upsert it.
  bool _isGroupUpdated(Map<String, dynamic> json) =>
      json['_event'] == 'group_updated' || json['type'] == 'group_updated';

  /// A peer delete-for-everyone published on the conversation + the recipient's
  /// personal channel. NOT a message: it carries only the affected server message
  /// id(s) and flips existing rows to deletedForAll. Never inserts a row.
  bool _isDeleteEvent(Map<String, dynamic> json) =>
      json['_event'] == 'delete-message';

  /// A peer reaction toggle published on the conversation + personal channel. NOT
  /// a message: it carries a full message object whose `id` identifies an existing
  /// row whose cached reactions are replaced. Never inserts a row.
  bool _isReactEvent(Map<String, dynamic> json) =>
      json['_event'] == 'react-event';

  /// A publication is a message only for known message events. A missing event
  /// name (un-enveloped/direct publish) is still treated as a message so legacy
  /// shapes keep working.
  bool _isMessageEvent(Map<String, dynamic> json) {
    final ev = json['_event'];
    return ev == null || _messageEvents.contains(ev);
  }

  /// Group membership/role system events (delivered as `kind:'system'` rows
  /// inside `getGroupMessageBloc`). When one of these targets the SIGNED-IN user
  /// it changes their standing in the room — their `myRole` (promote/demote/
  /// owner_transferred) or their very membership (kick/self-leave) — none of
  /// which the system-event row itself updates on `rooms`. Detected so the room
  /// header can be refreshed (and, on removal, the open chat closed) the moment
  /// the event lands, instead of staying stale until a full app refresh.
  static const _roleSystemEvents = {
    'member_promoted',
    'member_demoted',
    'owner_transferred',
  };
  static const _membershipExitEvents = {
    'member_kicked',
    'member_left',
  };

  /// If [json] is a membership/role system event that targets the current user,
  /// refresh the chats list (so `myRole`/`memberCount` stop being stale) and, on
  /// removal from the room (kicked / self-leave), close the open group chat so
  /// the user can't keep posting into a room they no longer belong to.
  ///
  /// Side-effect only: the canonical system-event row was already applied by the
  /// caller. The rooms-list sync is single-flight (`_roomsListInFlight`), so
  /// firing it here is cheap even if several membership events arrive together.
  void _applyMembershipSystemEvent(
    Map<String, dynamic> json,
    int serverRoomId,
  ) {
    final ev = json['system_event']?.toString();
    if (ev == null) return;
    final isRole = _roleSystemEvents.contains(ev);
    final isExit = _membershipExitEvents.contains(ev);
    if (!isRole && !isExit) return;
    if (!_membershipEventTargetsMe(json, ev)) return;

    unawaited(_syncEngine.syncRoomsList());
    if (isExit) {
      InAppChatNotifier.instance.closeActiveGroupIfMatches(serverRoomId);
    }
  }

  /// Whether a membership/role system event names the signed-in user. The actor
  /// rides the row's top-level `user_id`; the AFFECTED member lives in
  /// `system_meta` — `user_id` for kick/promote/demote/leave, and both `from`
  /// (demoted ex-owner) and `to` (new owner) for `owner_transferred`.
  bool _membershipEventTargetsMe(Map<String, dynamic> json, String event) {
    final me = MyDataModel.getInstance().id;
    if (me == null || me == 0) return false;
    final meta = json['system_meta'];
    if (meta is! Map) return false;
    if (event == 'owner_transferred') {
      return _asInt(meta['from']) == me || _asInt(meta['to']) == me;
    }
    return _asInt(meta['user_id']) == me;
  }

  /// Route every NON-message control signal that can ride either the per-room
  /// chat channel OR the user/server channel: WAVE banners, status receipts,
  /// group-deleted teardown, peer delete-for-everyone, and reaction toggles.
  /// Returns true when the event was consumed (caller must NOT treat it as a
  /// message). Factored out so the two publication paths can never diverge —
  /// the previous split left `group_deleted` handled only on the user/server
  /// path, so a group deleted while its chat was open was dropped silently.
  bool _routeControlEvent(Map<String, dynamic> json) {
    if (_routeNonChatEvent(json)) return true;
    if (_isStatusUpdate(json)) {
      unawaited(_applyStatusUpdate(json));
      return true;
    }
    if (_isGroupDeleted(json)) {
      unawaited(_applyGroupDeleted(json));
      return true;
    }
    if (_isGroupUpdated(json)) {
      unawaited(_applyGroupUpdated(json));
      return true;
    }
    if (_isDeleteEvent(json)) {
      unawaited(_applyDeleteMessage(json));
      return true;
    }
    if (_isReactEvent(json)) {
      unawaited(_applyReactEvent(json));
      return true;
    }
    return false;
  }

  void _onChatPublication(
    _ChatChannel channel,
    centrifuge.PublicationEvent event,
  ) {
    final json = _decode(event.data);
    if (json == null) return;
    if (_routeControlEvent(json)) return;
    if (!_isMessageEvent(json)) return;
    unawaited(_applyChatMessageAndFillGap(channel, json));
  }

  /// Apply an open-conversation publication, then fill any seq gap. The local max
  /// is captured BEFORE applying and awaited in order, so a publication that
  /// itself jumps the seq cannot mask its own hole (the previous code applied the
  /// row and ran the gap check concurrently, so the gate read the post-apply max
  /// and never back-filled).
  Future<void> _applyChatMessageAndFillGap(
    _ChatChannel channel,
    Map<String, dynamic> json,
  ) async {
    final beforeMax = await _messagesDao.maxServerSeq(channel.roomLocalId) ?? 0;
    await _applyMessage(json, channel.roomLocalId, channel.serverRoomId);
    await _maybeFillGap(channel, json, beforeMax);
  }

  void _onUserPublication(centrifuge.PublicationEvent event) {
    // user:#{id} carries counters/status/notifications + (for groups, later)
    // fan-out chat messages. For now route any message-shaped payload to drift;
    // non-message payloads are ignored here and handled by their own consumers.
    _routeOutsideRoomPublication(event.data);
  }

  void _onServerPublication(centrifuge.ServerPublicationEvent event) {
    _routeOutsideRoomPublication(event.data);
  }

  /// The shared outside-room receive pipeline used by both the user channel
  /// (`user:#{id}`) and the server-side (auto-subscribed) publications: decode
  /// the `{event,payload}` envelope, then route. A WAVE-1 banner/counter event is
  /// re-emitted on [nonChatEvents] and short-circuits BEFORE the message/drift
  /// path; status/group-deleted signals are applied; only genuine message events
  /// create drift rows. Kept as one method so the routing contract is identical
  /// on every path it serves (and directly testable in isolation).
  void _routeOutsideRoomPublication(List<int> data) {
    final json = _decode(data);
    if (json == null) return;
    if (_routeControlEvent(json)) return;
    if (!_isMessageEvent(json)) return;
    final serverRoomId = _mapper.serverRoomId(json);
    if (serverRoomId == null) return;
    unawaited(_applyMessageByServerRoomAndFillGap(json, serverRoomId));
  }

  /// Apply an outside-room message, then detect+fill a seq gap for the same room.
  /// Group/closed-DM messages ride user:#{id}/server channels (NOT a _ChatChannel
  /// with positioned recovery), so [_onChatPublication]'s [_maybeFillGap] never
  /// runs for them — a skipped publication leaves a permanent hole. Resolve the
  /// room the message landed in and run the (single-flight, hole-gated) gap fill
  /// against its real local id.
  Future<void> _applyMessageByServerRoomAndFillGap(
    Map<String, dynamic> json,
    int serverRoomId,
  ) async {
    // Capture the local max BEFORE applying so a publication that jumps the seq
    // does not mask its own hole. If the room doesn't exist locally yet, the
    // pre-apply max is 0 (nothing local) and any seq>1 legitimately back-fills.
    final existing = await _roomsDao.findByServerRoomId(serverRoomId);
    final beforeMax = existing == null
        ? 0
        : (await _messagesDao.maxServerSeq(existing.localId) ?? 0);
    final roomLocalId = await _applyMessageByServerRoom(json, serverRoomId);
    if (roomLocalId == null) return;
    final seq = _asInt(json['server_seq']);
    if (seq == null) return;
    await _syncEngine.fillGap(
      roomLocalId: roomLocalId,
      serverRoomId: serverRoomId,
      expectedAfterSeq: seq,
      beforeMax: beforeMax,
    );
  }

  /// Test seam: feed a raw Centrifugo publication payload (the bytes the SDK
  /// delivers as `PublicationEvent.data`) through the exact outside-room routing
  /// pipeline the live `user:#{id}` / server-side handlers use. Lets the WAVE-1
  /// banner/counter routing be asserted without constructing SDK event objects.
  @visibleForTesting
  void debugRouteOutsideRoomPublication(List<int> data) =>
      _routeOutsideRoomPublication(data);

  /// Test seam: run the exact rooms-list catch-up the `client.connected` listener
  /// fires on every (re)connect, without standing up a live socket. Asserts the
  /// reconnect invariant — a reconnect must resync the chats list so groups and
  /// closed DMs that changed during the gap still surface even if Centrifugo
  /// recovery was unavailable.
  @visibleForTesting
  void debugReconnectCatchUp() => unawaited(_syncEngine.syncRoomsList());

  /// Apply a read receipt published on the SENDER's personal channel: the peer
  /// read everything I sent in this room up to `up_to_seq`. Flip MY messages
  /// (senderId==me) with server_seq <= up_to_seq to read+'seen'. Ignored when the
  /// room isn't known locally or the payload is missing fields.
  Future<void> _applyStatusUpdate(Map<String, dynamic> json) async {
    if (json['status'] != 'seen' && json['status'] != 'read') return;
    final serverRoomId = _asInt(json['chat_room_id']);
    final upToSeq = _asInt(json['up_to_seq']);
    final myUserId = MyDataModel.getInstance().id;
    if (serverRoomId == null || upToSeq == null) return;
    if (myUserId == null || myUserId == 0) return;
    final room = await _roomsDao.findByServerRoomId(serverRoomId);
    if (room == null) return;
    await _messagesDao.markMineSeenUpToSeq(
      roomId: room.localId,
      upToSeq: upToSeq,
      myUserId: myUserId,
    );
    // The chats-list tick is now read from the room's denormalized preview (the
    // list no longer joins `messages`), so refresh it when MY last message flips
    // to 'seen'. No-op for the ordering — only the tick columns are re-stamped.
    await _roomsDao.refreshLastMessagePreview(room.localId);
  }

  /// Apply a group-deleted teardown: drop the group's drift room so it leaves the
  /// offline-first chats list immediately. Keyed by the same server_room_id the
  /// group was opened with. A no-op when the room was never materialized locally.
  Future<void> _applyGroupDeleted(Map<String, dynamic> json) async {
    final serverRoomId =
        _asInt(json['chat_room_id'] ?? json['room_id'] ?? json['server_room_id']);
    if (serverRoomId == null) return;
    await _roomsDao.deleteRoomByServerRoomId(serverRoomId);
  }

  /// Apply a group-metadata update: refresh the drift room's title/avatar in-place
  /// (keyed by server_room_id) so the unified offline-first chats list + an open
  /// group header reflect the rename/new photo live, then re-emit the raw payload
  /// on [nonChatEvents] so the in-memory groups tab (GroupsListBloc) and the open
  /// GroupChatBloc can merge the new meta onto their entity. A no-op for the room
  /// part when the room was never materialized locally; the stream still fires so
  /// the groups tab updates regardless.
  Future<void> _applyGroupUpdated(Map<String, dynamic> json) async {
    final serverRoomId =
        _asInt(json['chat_room_id'] ?? json['room_id'] ?? json['server_room_id']);
    if (serverRoomId != null) {
      final room = await _roomsDao.findByServerRoomId(serverRoomId);
      if (room != null) {
        final name = json['name']?.toString();
        final avatar = (json['avatar'] ?? json['image'])?.toString();
        await _roomsDao.updateRoom(
          room.localId,
          RoomsCompanion(
            title: (name == null || name.isEmpty)
                ? const Value.absent()
                : Value(name),
            avatarUrl: (avatar == null)
                ? const Value.absent()
                : Value(avatar),
          ),
        );
      }
    }
    // Re-emit so the groups tab / open group chat refresh their entity in-place.
    _nonChatController.add(
      RealtimeNonChatEvent(event: 'group_updated', payload: json),
    );
  }

  /// Apply a peer delete-for-everyone: flip the affected existing rows (matched by
  /// server message id) to deletedForAll so the offline-first conversation hides
  /// them live. The payload carries only `message_id` (a list, legacy strings),
  /// no room — the server message id is globally unique, so no room resolution is
  /// needed. Never inserts a row; a no-op when none of the ids are stored locally.
  Future<void> _applyDeleteMessage(Map<String, dynamic> json) async {
    final ids = _serverMessageIds(json['message_id']);
    if (ids.isEmpty) return;
    // Resolve the affected rooms BEFORE the rows are flipped so a deleted last
    // message refreshes the list preview (which is now read from the room's
    // denormalized columns, not a `messages` join).
    final affectedRooms = <int>{};
    for (final id in ids) {
      final m = await _messagesDao.findByServerMessageId(id);
      if (m != null) affectedRooms.add(m.roomId);
    }
    await _messagesDao.setDeleteStateByServerIds(
      ids,
      MessageDeleteState.deletedForAll,
    );
    for (final roomLocalId in affectedRooms) {
      await _roomsDao.refreshLastMessagePreview(roomLocalId);
    }
  }

  /// Apply a peer reaction toggle: replace the cached reactions on the existing
  /// row identified by the payload's server message `id`, normalized through the
  /// mapper so it matches REST/sync shape. Never inserts a row; a no-op when the
  /// message isn't stored locally or carries no id.
  Future<void> _applyReactEvent(Map<String, dynamic> json) async {
    final serverMessageId = _asInt(json['id'] ?? json['server_message_id']);
    if (serverMessageId == null) return;
    final reactsJson = _mapper.reactsJson(json['reacts'] ?? json['reactions']);
    await _messagesDao.setReactsByServerId(serverMessageId, reactsJson);
    // No preview refresh here: reactions are not rendered in the list preview,
    // so re-stamping the room would only re-fire the list stream for nothing.
  }

  /// Normalize the `delete-message` payload's `message_id` into server message
  /// ids. Legacy legacy realtime sends a list of strings; tolerate a single value and
  /// int/num too. Unparseable entries are dropped.
  static List<int> _serverMessageIds(dynamic raw) {
    final out = <int>[];
    if (raw is List) {
      for (final e in raw) {
        final id = _asInt(e);
        if (id != null) out.add(id);
      }
    } else {
      final id = _asInt(raw);
      if (id != null) out.add(id);
    }
    return out;
  }

  Future<void> _onChatSubscribed(
    _ChatChannel channel,
    centrifuge.SubscribedEvent event,
  ) async {
    // The channel can be opened before its room id is resolved (a 1:1 opened
    // from a profile/picker subscribes on the deterministic peer channel name,
    // which doesn't need the room id). Don't drive a server-room sync against an
    // unresolved id (it would hit /api/v1/rooms/0/messages → 404); the open path
    // resolves the id and the rooms-list sync materializes it.
    if (channel.serverRoomId <= 0) return;
    await _syncEngine.onSubscribed(
      roomLocalId: channel.roomLocalId,
      serverRoomId: channel.serverRoomId,
      recovered: event.recovered,
      epoch: event.streamPosition?.epoch,
    );
  }

  Future<void> _maybeFillGap(
    _ChatChannel channel,
    Map<String, dynamic> json,
    int beforeMax,
  ) async {
    final seq = _asInt(json['server_seq']);
    if (seq == null) return;
    await _syncEngine.fillGap(
      roomLocalId: channel.roomLocalId,
      serverRoomId: channel.serverRoomId,
      expectedAfterSeq: seq,
      beforeMax: beforeMax,
    );
  }

  Future<void> _applyMessage(
    Map<String, dynamic> json,
    int roomLocalId,
    int serverRoomId,
  ) async {
    final companion = _mapper.toCompanion(json, roomLocalId: roomLocalId);
    if (companion == null) return;
    if (json['type'] == 'img') {
      debugPrint(
          '[ChatImage] realtime push id=${json['id']} keys=${json.keys.toList()} albums=${json['albums']} -> attachmentJson=${companion.attachmentJson.value}');
    }
    final localId = await _messagesDao.upsertFromServer(companion);

    // A group membership/role change about ME (promote/demote/kick/leave/owner
    // transfer) lands as a system row that never updates my standing on the room.
    // Refresh the header (and close the chat if I'm removed) as a side effect of
    // applying it; both group-receive paths funnel through here.
    _applyMembershipSystemEvent(json, serverRoomId);

    // Foreground heads-up + sound for genuinely incoming messages. The notifier
    // dedups re-applied rows and suppresses the on-screen conversation, so this
    // is safe to call from every receive path (server/user/chat publications).
    if (_isIncoming(json)) {
      InAppChatNotifier.instance.notifyIncoming(
        json: json,
        serverRoomId: serverRoomId,
      );
    }

    final seq = companion.serverSeq.present ? companion.serverSeq.value : null;
    if (seq != null) {
      // Suppress the unread bump for the conversation the user is CURRENTLY
      // viewing: bumping then relying on the screen's follow-up markRead to undo
      // it flickers the badge (transient miscount). The notifier already tracks
      // the active 1:1 peer / group room, so reuse it (no new wiring).
      final incoming = _isIncoming(json);
      final senderId = _asInt(json['user_id'] ?? json['sender_id']);
      final notifier = InAppChatNotifier.instance;
      final isActiveConversation = (notifier.activeGroupRoomId == serverRoomId &&
              notifier.activeGroupRoomId != null) ||
          (notifier.activePeerUserId != null &&
              notifier.activePeerUserId == senderId);
      await _roomsDao.applyIncomingMessageMeta(
        roomLocalId: roomLocalId,
        lastMessageLocalId: localId,
        serverSeq: seq,
        serverCreatedAt: companion.serverCreatedAt.present
            ? (companion.serverCreatedAt.value ??
                DateTime.now().millisecondsSinceEpoch)
            : DateTime.now().millisecondsSinceEpoch,
        incrementUnread: incoming && !isActiveConversation,
      );
      await _syncStateDao.setCursor(
        roomId: roomLocalId,
        lastKnownSeq: seq,
        nowMs: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  /// Returns the local id of the room the message was applied to, or null when
  /// the room could neither be resolved nor created (so callers can skip any
  /// follow-up keyed on it, e.g. gap fill).
  Future<int?> _applyMessageByServerRoom(
    Map<String, dynamic> json,
    int serverRoomId,
  ) async {
    var room = await _roomsDao.findByServerRoomId(serverRoomId);
    if (room == null) {
      // First message of a brand-new conversation (1:1 or group) can arrive over
      // user:#{id} fan-out BEFORE the rooms list is synced. Dropping it here lost
      // that message (e.g. a group's first message never showing). Create the
      // room on the fly from the message so it lands in drift now; a follow-up
      // rooms-list sync backfills the authoritative header (real title/avatar and
      // the correct dm/group type), upserting onto this same server_room_id row.
      final localId =
          await _roomsDao.upsertByServerRoomId(_newRoomCompanion(json, serverRoomId));
      _backfillRoomsList();
      room = await _roomsDao.findByLocalId(localId);
      if (room == null) return null;
    }
    await _applyMessage(json, room.localId, serverRoomId);
    return room.localId;
  }

  /// Minimal room row for a conversation whose first message arrived before the
  /// rooms list synced. The broadcast payload now carries the sender identity
  /// (`user`: name/image, for DM) and — for groups — the conversation identity
  /// (`group`: id/name/image), so the new list row shows a real title + avatar
  /// immediately instead of a blank placeholder. The follow-up rooms-list sync
  /// (_backfillRoomsList) still reconciles the authoritative header onto this
  /// same server_room_id afterwards.
  RoomsCompanion _newRoomCompanion(Map<String, dynamic> json, int serverRoomId) {
    final group = json['group'];
    final isGroup = group is Map ||
        json['is_group'] == true ||
        json['is_group']?.toString() == 'true' ||
        json['is_group']?.toString() == '1';

    // updatedAt is a transient placeholder for list ordering until _applyMessage
    // bumps it to the message's real server timestamp via applyIncomingMessageMeta.
    final updatedAt = Value(DateTime.now().millisecondsSinceEpoch);

    if (isGroup) {
      final groupName = (group is Map ? group['name'] : null)?.toString();
      final groupImage =
          (group is Map ? (group['image'] ?? group['avatar']) : null)?.toString();
      final groupId = group is Map ? _asInt(group['id']) : null;
      return RoomsCompanion(
        serverRoomId: Value(serverRoomId),
        type: const Value(RoomType.group),
        groupId: groupId == null ? const Value.absent() : Value(groupId),
        title: (groupName != null && groupName.trim().isNotEmpty)
            ? Value(groupName.trim())
            : const Value.absent(),
        avatarUrl: (groupImage != null && groupImage.isNotEmpty)
            ? Value(groupImage)
            : const Value.absent(),
        updatedAt: updatedAt,
      );
    }

    final senderId = _asInt(json['user_id'] ?? json['sender_id']);
    final peerUserId = _isIncoming(json) ? senderId : null;
    final user = json['user'];
    final senderName =
        (user is Map ? (user['name'] ?? user['user_name']) : null)?.toString();
    final senderImage =
        (user is Map ? (user['user_image'] ?? user['image']) : null)?.toString();
    return RoomsCompanion(
      serverRoomId: Value(serverRoomId),
      type: const Value(RoomType.dm),
      peerUserId: peerUserId == null ? const Value.absent() : Value(peerUserId),
      title: (senderName != null && senderName.trim().isNotEmpty)
          ? Value(senderName.trim())
          : const Value.absent(),
      avatarUrl: (senderImage != null && senderImage.isNotEmpty)
          ? Value(senderImage)
          : const Value.absent(),
      updatedAt: updatedAt,
    );
  }

  /// Pull the authoritative conversation headers once after a room was created
  /// from an incoming message, so its real title/avatar/type land in drift. The
  /// engine guards against overlapping syncs, so this is safe to call freely.
  void _backfillRoomsList() {
    unawaited(_syncEngine.syncRoomsList());
  }

  bool _isIncoming(Map<String, dynamic> json) {
    final senderId = _asInt(json['user_id'] ?? json['sender_id']);
    final me = MyDataModel.getInstance().id;
    return senderId != null && me != null && senderId != me;
  }

  String _chatChannelName(int peerUserId) {
    final me = MyDataModel.getInstance().id ?? 0;
    final a = me < peerUserId ? me : peerUserId;
    final b = me < peerUserId ? peerUserId : me;
    return 'chat:dm.${a}_$b';
  }

  Map<String, dynamic>? _decode(List<int> data) {
    try {
      final decoded = jsonDecode(utf8.decode(data));
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);
      // The backend (CentrifugoBroadcaster) wraps every publication as
      // {event, payload}, where `payload` is the actual message/status object
      // (the same shape REST returns). Every handler below reads the message
      // fields at the top level (chat_room_id, id, user_id, server_seq, type...),
      // so the envelope MUST be unwrapped here — otherwise serverRoomId/toCompanion
      // read nulls and silently drop every realtime message (messages then only
      // appear via REST sync on open, never live). Fall back to the map as-is for
      // any un-enveloped publication.
      final payload = map['payload'];
      if (payload is Map) {
        final p = Map<String, dynamic>.from(payload);
        // Preserve the envelope event name so handlers can route by it (only
        // genuine message events create rows; open_chat/getChatUsersBloc/etc.
        // must not be parsed as messages). Stored under a reserved key the
        // message mapper ignores.
        final ev = map['event'];
        if (ev != null && p['_event'] == null) p['_event'] = ev;
        return p;
      }
      if (payload is List) {
        // Some outside-room banners (e.g. super-lucky-box) carry a JSON ARRAY as
        // payload. The flat-Map unwrap above would lose both the event name and
        // the list, so wrap it: the non-chat router reads `_event` and forwards
        // the `payload` list to its consumer (which takes .first). This is never
        // a message shape, so it can't reach the drift/message path.
        final ev = map['event'];
        if (ev == null) return null;
        return {'_event': ev, 'payload': payload};
      }
      return map;
    } catch (e) {
      // A malformed/unexpected-encoding publication used to vanish here with no
      // trace — the same invisible-failure class as the historic `{event,payload}`
      // envelope bug. Emit a throttled, PII-safe breadcrumb (byte length +
      // exception type only, NEVER the decoded content) so a payload-shape
      // regression is diagnosable instead of presenting as silent message loss.
      final now = DateTime.now();
      final last = _lastDecodeReportAt;
      if (last == null || now.difference(last) >= _decodeReportWindow) {
        _lastDecodeReportAt = now;
        try {
          Methods.logBreadcrumb(
            '[Realtime] decode failed: bytes=${data.length} err=${e.runtimeType}',
          );
        } catch (_) {/* never throw from logging */}
      }
      return null;
    }
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }
}

/// An outside-room non-chat realtime event (banner / per-user counter / status)
/// re-emitted off the shared socket for the legacy banner consumers. [payload]
/// is kept in its native shape: a Map for most events, a List for `superLuckBox`.
class RealtimeNonChatEvent {
  const RealtimeNonChatEvent({required this.event, required this.payload});

  final String event;
  final dynamic payload;
}

/// Per-conversation subscription bookkeeping.
class _ChatChannel {
  _ChatChannel({
    required this.subscription,
    required this.roomLocalId,
    required this.serverRoomId,
  });

  final centrifuge.Subscription subscription;
  final int roomLocalId;
  final int serverRoomId;
  final List<StreamSubscription<dynamic>> _subs = [];

  void add(StreamSubscription<dynamic> sub) => _subs.add(sub);

  Future<void> dispose() async {
    for (final sub in _subs) {
      await sub.cancel();
    }
    _subs.clear();
  }
}
