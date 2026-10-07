import 'package:general/src/features/live_room/presentation/live_stage_mode.dart';
import 'dart:async';
import 'package:general/src/features/live_room/presentation/taps/live_taps_controller.dart';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/rtm_handler/rtm_handler.dart';
import 'package:general/src/features/room/room.dart';
import 'package:livekit_client/livekit_client.dart' show Participant;
import 'package:utd_live_room_kit/utd_live_room_kit.dart' as live;
import 'package:utd_video_effects_kit/utd_video_effects_kit.dart' as fx;

import '../../room/presentation/gifts/bloc/fetch_gift_bloc/fetch_gift_bloc.dart';
import '../../room/presentation/gifts/bloc/fetch_gift_bloc/fetch_gift_events.dart';

/// Live (video) room state container — the live room's own singleton, forked
/// off the audio room's [RoomData].
///
/// It OWNS the live-only state: the live kit controller and the live room's RTM
/// (data-channel) wiring. It DELEGATES the genuinely shared room state ([room],
/// [myCoins], [minimizeGiftFamous]) to [RoomData], because the app-wide gift
/// engine (RtmHandler / RoomMessageProcessor / GiftController and the gift blocs)
/// is controller-agnostic and reads/writes `RoomData.instance.*` — those pieces
/// are shared infrastructure, not audio-room chrome. The live room drives that
/// shared engine from its OWN controller's data stream (see [initRtm]).
class LiveRoomData {
  LiveRoomData._();
  static final LiveRoomData instance = LiveRoomData._();

  // ========== Live controller (moved off RoomData) ==========
  final ValueNotifier<live.UTDRoomController?> _controllerNotifier =
  ValueNotifier<live.UTDRoomController?>(null);

  ValueNotifier<live.UTDRoomController?> get liveControllerNotifier =>
      _controllerNotifier;

  live.UTDRoomController? get liveController => _controllerNotifier.value;
  set liveController(live.UTDRoomController? value) =>
      _controllerNotifier.value = value;

  live.UTDChatController? get chatController => liveController?.chatController;

  // ========== Video effects (beauty / filters) ==========
  /// The single video-effects processor for this live session. Owned here so the
  /// beauty UI ([VideoEffectsSheet]) can drive it AND the live kit's
  /// `buildVideoProcessor` factory can hand the SAME instance to every camera
  /// capture (preview, switch, reconnect). Reusable across captures because the
  /// processor's `destroy()` only detaches the native session, it doesn't tear
  /// down the Dart object. Null until first requested; cleared on [reset].
  fx.VideoEffectsProcessor? videoEffects;

  /// Lazily creates (once) and returns the session's effects processor.
  /// [entitled] is forwarded from the kit's server-signed token claim so effects
  /// only run when the customer has activated + paid.
  fx.VideoEffectsProcessor ensureVideoEffects({bool entitled = true}) =>
      videoEffects ??= fx.VideoEffectsProcessor.create(entitled: entitled);

  // ========== Per-stage guest gift counter (المسّات) ==========
  /// Gift value each CURRENTLY-SEATED guest received during THIS stage stint,
  /// keyed by userId. Shown on the guest tile; a guest who leaves the stage
  /// and comes back starts from zero (owner spec). Wired to seat changes in
  /// [watchGuestSeats].
  final ValueNotifier<Map<String, int>> guestStageTouches = ValueNotifier(
    const {},
  );

  Set<String> _seatedGuests = {};
  VoidCallback? _seatsListener;
  live.UTDRoomController? _seatsController;

  /// Adds [amount] to every seated recipient in [recipientIds]. No-op for
  /// recipients who aren't on stage.
  void addGuestStageTouches(Iterable<String> recipientIds, int amount) {
    if (amount <= 0) return;
    final current = Map<String, int>.from(guestStageTouches.value);
    var changed = false;
    for (final id in recipientIds) {
      if (!_seatedGuests.contains(id)) continue;
      current[id] = (current[id] ?? 0) + amount;
      changed = true;
    }
    if (changed) guestStageTouches.value = current;
  }

  /// Starts tracking seat occupancy on [controller]: a newly seated guest
  /// starts at 0, a guest who left the stage is dropped (so a re-join starts
  /// fresh). Idempotent per controller.
  void watchGuestSeats(live.UTDRoomController controller) {
    if (_seatsController == controller) return;
    _unwatchGuestSeats();
    _seatsController = controller;
    _seatsListener = () {
      final seated = <String>{
        for (final seat in controller.seatController.seats.value)
          if (seat.isOccupied && (seat.occupantUserId?.isNotEmpty ?? false))
            seat.occupantUserId!,
      };
      if (setEquals(seated, _seatedGuests)) return;
      final current = Map<String, int>.from(guestStageTouches.value);
      // Dropped guests lose their stint counter; new guests start at 0.
      current.removeWhere((id, _) => !seated.contains(id));
      for (final id in seated) {
        current.putIfAbsent(id, () => 0);
      }
      _seatedGuests = seated;
      guestStageTouches.value = current;
    };
    controller.seatController.seats.addListener(_seatsListener!);
    _seatsListener!();
  }

  void _unwatchGuestSeats() {
    if (_seatsListener != null) {
      _seatsController?.seatController.seats.removeListener(_seatsListener!);
      _seatsListener = null;
    }
    _seatsController = null;
    _seatedGuests = {};
    guestStageTouches.value = const {};
  }

  // ========== Shared room state (single source = RoomData) ==========
  // The gift engine and RoomStateManager keep these in RoomData; the live UI
  // reaches them through LiveRoomData so live files don't reference RoomData.

  /// The current live room (the enter-room response). Assigned by the foreground
  /// widget's enter-room listener once `EnterRoomSuccesMessageState` arrives, and
  /// cleared on [reset]. Reading [room] before the response throws — code that
  /// can run on the live screen's FIRST frame (the screen/chat/overlay all build
  /// before enter-room completes) must use [roomOrNull] (or its own widget data)
  /// instead, otherwise the first live-room entry per launch crashes.
  EnterRoomModel? _room;
  EnterRoomModel get room => _room!;
  set room(EnterRoomModel value) {
    _room = value;
    // Capacity comes from the room row, so seed it the moment the row arrives.
    stageGuestTiles.value = LiveStageMode.fromRoomMode(value.mode).guestTiles;
    // Seed the follow pill from the enter-room response (true = pill hidden;
    // the default true keeps it hidden until the server state is known).
    followsHost.value = value.isFollowingOwner ?? true;
    if (_adminsCompleter != null && !_adminsCompleter!.isCompleted) {
      _adminsCompleter!.complete(value.admins ?? const []);
    }
  }

  /// Whether the LOCAL user follows the host of the current broadcast.
  /// Seeded from enter_room's `is_following_owner`; flipped to true the moment
  /// the user taps the live "متابعة" pill (LiveFollowHostButton). Defaults to
  /// true so the pill never flashes before the enter-room response lands.
  final ValueNotifier<bool> followsHost = ValueNotifier<bool>(true);

  /// Guest slots the CURRENT broadcast allows, host excluded.
  ///
  /// One source of truth on purpose. The pre-live composer used to write the
  /// chosen mode to `RoomData.instance.room.mode` while the live kit's
  /// `maxGuestTiles` was read from `LiveRoomData`'s room — two different
  /// singletons — so picking "3 Seats" left the kit built with a capacity of
  /// ZERO and the broadcast came out as a plain full-screen live. A notifier
  /// also means the screen actually rebuilds when the host switches mode; a
  /// plain field would have been read once and never again.
  ///
  /// Seeded from `rooms.mode` when the enter-room response lands, and updated
  /// by the composer when the host changes shape.
  final ValueNotifier<int> stageGuestTiles = ValueNotifier<int>(0);

  bool _followAnnounced = false;

  /// Called whenever the LOCAL user follows [userId] from ANY in-live entry
  /// point (broadcast-card pill, details-sheet pill, in-room profile). No-op
  /// outside a live session or when [userId] isn't the host. Hides the pill
  /// everywhere and posts ONE "«فلان» followedLive" chat line per session —
  /// the sentinel is localized in LiveMessagesView (same pattern as
  /// likedLive / sharedLive); the guard keeps API retries from spamming.
  void noteHostFollowed(int userId) {
    final ownerId = roomOrNull?.ownerId;
    if (ownerId == null || userId != ownerId) return;
    followsHost.value = true;
    roomOrNull?.isFollowingOwner = true;
    if (_followAnnounced) return;
    final chat = chatController;
    if (chat == null) return;
    _followAnnounced = true;
    final me = MyDataModel.getInstance();
    chat.sendMessage(
      '${me.name ?? ''} followedLive',
      userData: {
        'img': me.profile?.image ?? '',
        'senderId': me.id?.toString() ?? '',
        'senderName': me.name ?? '',
        'type': 'message',
      },
    );
  }

  /// Resolves with the room's backend admin list the moment the enter-room
  /// response lands (immediately if it already did). Used by the live kit's
  /// token step so a room admin joins with an `admin` token instead of an
  /// `audience` one — the engine enforces token-baked permissions, so seeding
  /// adminIds after connect was too late and admins lost their powers on every
  /// broadcast restart (owner report 2026-06-11).
  Completer<List<String>>? _adminsCompleter;
  Future<List<String>> get adminsWhenLoaded {
    final loaded = _room;
    if (loaded != null) return Future.value(loaded.admins ?? const []);
    _adminsCompleter ??= Completer<List<String>>();
    return _adminsCompleter!.future;
  }

  /// Null-safe view of [room] for paths that may run before the enter-room
  /// response (initial frame of the live screen / chat list / side overlay).
  EnterRoomModel? get roomOrNull => _room;

  EqualityValueNotifier<String> get myCoins => RoomData.instance.myCoins;
  EqualityValueNotifier<bool> get minimizeGiftFamous =>
      RoomData.instance.minimizeGiftFamous;

  // ========== RTM (data-channel) wiring — live only ==========
  RtmHandler? rtmHandler;
  final List<StreamSubscription<dynamic>> _rtmSubs = [];
  bool _rtmActive = false;
  final Set<int> _pendingUserFetches = {};

  // Admin/role sync bound to the LIVE controller — mirror of RoomData's role
  // sync, which is typed to the audio kit and can't take a live controller.
  // Writes the SHARED RoomData.adminsInRoom that every admin gate reads.
  StreamSubscription<live.UTDRoleChangeEvent>? _roleSub;
  VoidCallback? _roleConnListener;
  live.UTDRoomController? _roleSyncController;

  /// Subscribes the live controller's data channel + participant streams to the
  /// (shared) gift engine, so incoming gift / lucky-box / entry / PK overlays
  /// fire in the live room. Mirrors [RoomData.initRtm] but bound to the LIVE
  /// controller. Idempotent.
  void initRtm({
    required String roomId,
    required String userModelId,
    required bool isHost,
    required TickerProvider tickerProvider,
  }) {
    final controller = liveController;
    if (_rtmActive || controller == null) return;

    rtmHandler = RtmHandler(
      giftController: GiftController(),
      roomId: roomId,
      userModelId: userModelId,
      isHost: isHost,
      tickerProvider: tickerProvider,
    );
    rtmHandler!.contextSupplier = () => navKey.currentState!.context;

    _rtmSubs.add(
      controller.dataStream.listen((data) {
        final ctx = navKey.currentState?.context;
        if (ctx == null) return;
        rtmHandler?.onDataReceived(data, ctx);
      }),
    );

    _rtmSubs.add(
      controller.roomManager.participantJoinedStream.listen(_onUserJoined),
    );

    // Admin/role sync bound to the LIVE controller. Writes the shared
    // RoomData.adminsInRoom that every admin gate reads.
    _wireRoleSync(controller);

    // Tap-hearts session (التكبيس): per-broadcast counter + pulse batching.
    LiveTapsController.instance.start(roomId);

    _rtmActive = true;
  }

  // ========== Admin/role sync (live controller) ==========

  /// Wires admin role sync to [controller]: seeds the shared
  /// [RoomData.adminsInRoom] from the app's enter-room admin list, keeps it in
  /// sync via live `_role_change` deltas, and re-seeds on reconnect. Mirror of
  /// `RoomData.wireRoleSync` but bound to the LIVE controller. Idempotent.
  void _wireRoleSync(live.UTDRoomController controller) {
    _unwireRoleSync();
    _roleSyncController = controller;

    // Initial seed of the admin map from the app backend (enter-room response).
    _seedAdmins(controller);

    // Live updates: a role change adds/removes admin membership.
    _roleSub = controller.roleChangeStream.listen((e) {
      if (e.identity.isEmpty) return;
      if (e.role == 'admin') {
        RoomData.instance.adminsInRoom[e.identity] = e.identity;
      } else {
        RoomData.instance.adminsInRoom.remove(e.identity);
      }
      RoomData.instance.bumpRoleVersion();
    });

    // On reconnect, re-apply the backend baseline ADDITIVELY so in-session
    // promotions (live `_role_change` deltas already in adminsInRoom) survive.
    _roleConnListener = () {
      if (controller.isConnected) _seedAdmins(controller, merge: true);
    };
    controller.connectionState.addListener(_roleConnListener!);
  }

  void _unwireRoleSync() {
    _roleSub?.cancel();
    _roleSub = null;
    if (_roleConnListener != null) {
      _roleSyncController?.connectionState.removeListener(_roleConnListener!);
      _roleConnListener = null;
    }
    _roleSyncController = null;
  }

  /// Seeds the shared [RoomData.adminsInRoom] from the app's enter-room admin
  /// list ([EnterRoomModel.admins]) — the app backend is the source of truth.
  /// When [merge] is true (reconnect) the baseline is added without clearing, so
  /// live promotions already in the map survive; when false it is reset.
  void _seedAdmins(live.UTDRoomController controller, {bool merge = false}) {
    try {
      final admins = <String>{
        for (final id in (room.admins ?? const <String>[]))
          if (id.isNotEmpty) id,
      };
      // Fold in the local user's own role so a rejoining admin's gates are
      // correct immediately.
      final localId = controller.roomManager.localParticipant?.identity;
      if (localId != null &&
          controller.getParticipantRole(localId) == 'admin') {
        admins.add(localId);
      }
      if (!merge) RoomData.instance.adminsInRoom.clear();
      RoomData.instance.adminsInRoom.addEntries(
        admins.map((id) => MapEntry(id, id)),
      );
      RoomData.instance.bumpRoleVersion();
    } catch (e) {
      Methods.printLog('live _seedAdmins error: $e');
    }
  }

  void disposeRtm() {
    _unwireRoleSync();
    for (final sub in _rtmSubs) {
      sub.cancel();
    }
    _rtmSubs.clear();
    rtmHandler?.dispose();
    rtmHandler = null;
    _rtmActive = false;
    _pendingUserFetches.clear();
  }

  /// Fetches + caches a newly-joined participant's profile (so avatars/names
  /// resolve), then refreshes the live tiles. No seat/music/youtube logic
  /// (those are audio-room concerns).
  void _onUserJoined(Participant participant) async {
    final userId = int.tryParse(participant.identity);
    if (userId == null || _pendingUserFetches.contains(userId)) return;
    _pendingUserFetches.add(userId);
    try {
      final fetched = await getUsersByIds([userId]);
      for (final entry in fetched.entries) {
        RoomData.instance.users[entry.value.id ?? 0] = entry.value;
        await UsersCache().setUser(entry.value);
      }
      liveController?.refreshParticipants();
    } finally {
      _pendingUserFetches.remove(userId);
    }
  }

  // ========== Room entry (live) ==========

  /// Live-room entry sequence: announce join + entry effect, and load secondary
  /// data (gift price, background, charisma, music volume). Unlike the audio
  /// room it does NOT take a seat, request mic permission, or enable the mic —
  /// the live host publishes the camera through the kit's "Go Live" flow.
  void onEnterLiveRoomSuccess() {
    // Defense in depth for the connect/enter_room race: the caller
    // (LiveForegroundWidget._handleConnection) only invokes this once the room
    // is assigned, but reading `room` (`_room!`) here was a live fatal — keep
    // this method itself unable to crash on a missing room.
    final enteredRoom = roomOrNull;
    if (enteredRoom == null) {
      Methods.recordNonFatal(
        StateError('onEnterLiveRoomSuccess before enter_room response'),
        StackTrace.current,
        reason: 'live entry sequence skipped — room not assigned yet',
      );
      return;
    }
    GiftController().normalGiftsToShow.clear();

    // Warm the same persistent catalog bloc used by the audio gift sheet.
    // The sheet is presented immediately on tap and renders this cached state;
    // it must not wait to begin the category request after opening.
    if (!di<FetchGiftBloc>().state.reqStateGiftCategory.isLoaded) {
      di<FetchGiftBloc>().add(const FetchGiftCategoryEvent());
    }

    loadSecondaryData(
      roomId: enteredRoom.id.toString(),
      userCoins: '${MyDataModel.getInstance().myStore?.coinsNew}',
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (!di<RoomStateManager>().isInRoom || RoomData.instance.isExitingRoom) {
        return;
      }
      final me = MyDataModel.getInstance();

      chatController?.sendMessage(
        "joinRoom",
        userData: {
          "img": me.profile?.image ?? "",
          "bu": me.bubble ?? "",
          "buId": me.bubbleId.toString(),
          "sL": me.level?.senderImage ?? "",
          "rL": me.level?.receiverImage ?? "",
          "v": me.vip1?.img1 ?? "",
          "c": me.vip1?.colorName ?? "",
          "senderId": me.id?.toString() ?? "",
          "senderName": me.name ?? "",
          'type': 'message',
        },
      );

      final entroData = {
        "message": "userEntro",
        "userId": me.id.toString(),
        "wabbleId": me.wabbleId ?? -1,
        "entroImg": me.intro,
        "entroImgId": me.introId,
        "entroType": me.introType,
        'userName': me.name,
        'userVip': me.vip1?.level ?? 0,
        'userImge': me.profile?.image,
        'vip': ((me.vip1?.level ?? 0) > 0) ? true : false,
      };
      sendLiveRoomData(data: entroData);

      if (me.roomEffects?.showEntring == true) {
        GiftController().userEntro({
          "messageContent": entroData,
        }, GiftController().userIntroData);
      }
    });
  }

  /// Broadcasts a data-channel message via the LIVE controller. Mirrors the
  /// audio `sendRoomData` wire contract: `{"messageContent": {..}}`.
  void sendLiveRoomData({required Map<String, dynamic> data, String? userId}) {
    final controller = liveController;
    if (controller == null) return;
    final inner = data['messageContent'];
    final Map<String, dynamic> content =
    inner is Map ? Map<String, dynamic>.from(inner) : data;
    final payload = {"messageContent": content};
    if (userId != null) {
      controller.sendTargetedMessage(payload, [userId]);
    } else {
      controller.sendRoomMessage(payload);
    }
  }

  /// Tears down live state on room exit. Called from the live exit / teardown
  /// path. Does not touch [RoomData] (audio state).
  void reset() {
    LiveTapsController.instance.stop();
    disposeRtm();
    _unwatchGuestSeats();
    liveController = null;
    videoEffects?.dispose();
    videoEffects = null;
    // Drop the lucky-gift fly targets the live header registered (host avatar +
    // visitor avatars + bar area) so they can't leak into the next room.
    LuckyGiftController.liveAvatarKeys.clear();
    LuckyGiftController.liveHostAvatarKey = null;
    LuckyGiftController.liveVisitorsBarKey = null;
    // Clear the room so the next entry's first frame can't read a previous
    // room's data (rule/intro/admins). Early readers use [roomOrNull].
    _room = null;
    stageGuestTiles.value = 0;
    followsHost.value = true;
    _followAnnounced = false;
    // Release any token step still waiting on admins (it falls back to
    // audience) and start the next room with a fresh completer.
    if (_adminsCompleter != null && !_adminsCompleter!.isCompleted) {
      _adminsCompleter!.complete(const []);
    }
    _adminsCompleter = null;
  }
}
