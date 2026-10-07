import 'dart:async';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/carom/carom_room_controller.dart';
import 'package:general/src/features/ludo/ludo_room_controller.dart';
import 'package:general/src/core/services/join_timeline.dart';
import 'package:general/src/core/utils/mic_background_helper.dart';
import 'package:general/src/features/room/data/model/user_in_room_model.dart';
import 'package:general/src/features/room/domain/use_case/fetch_users_data_uc.dart';
import 'package:general/src/features/room/domain/use_case/fetch_bad_words_uc.dart';
import 'package:general/src/core/services/bad_words_manager.dart';
import 'package:general/src/features/room/presentation/charisma/bloc/charisma_bloc.dart';
import 'package:general/src/features/room/presentation/component/games/paid_games/games_images_bloc.dart';
import 'package:general/src/features/room/presentation/component/pk/counter_time_pk_widget.dart';
import 'package:general/src/features/room/presentation/super_bomb/bloc/get_super_bombs_bloc/get_super_bombs_bloc.dart';
import 'package:general/src/features/room/presentation/super_bomb/bloc/get_super_bombs_theme_bloc/get_super_bombs_theme_bloc.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:general/src/features/room/presentation/lucky_box/widgets/dialog_lucky_box.dart';
import 'package:general/src/features/room/presentation/music/bloc/music_room_bloc.dart';
import 'package:general/src/features/room/presentation/music/controller/music_controller.dart';
import 'package:general/src/features/room/presentation/youtube/bloc/youtube/youtube_bloc.dart';
import 'package:general/src/features/room/presentation/rtm_handler/rtm_handler.dart';
import 'package:general/src/features/live_room/presentation/live_room_data.dart';
import 'package:general/src/features/room/presentation/youtube/view/youtube_controller.dart';
import 'package:general/src/features/room/room.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

// ---------------------------------------------------------------------------
// Video room Zego credentials (kept for deferred video room migration)
// ---------------------------------------------------------------------------

// ignore: non_constant_identifier_names
int appID = 0;
// ignore: non_constant_identifier_names
String appSign = "";

// ---------------------------------------------------------------------------
// Message constants (unchanged — transport-agnostic)
// ---------------------------------------------------------------------------

const String messageContent = "messageContent";
const String message = "message";
const String userEntro = "userEntro";
const String entroImgIdKey = "entroImgId";
const String userName = "userName";
const String userImge = "userImge";
const String showGifts = "showGifts";
const String sendIdKey = "send_id";
const String receiverIdKey = "receiver_id";
const String giftImgKey = "giftImg";
const String showGiftKey = "showGift";
const String isExpensive = "isExpensive";
const String plural = "plural";
const String numGift = "num_gift";
const String roomGiftsPriceKey = "gift_price";
const String roomModeKey = "roomMode";
const String changeBackground = "changeBackground";
const String startCharisma = "startCharisma";
const String updateCharisma = "updateCharisma";
const String closeCharisma = "closeCharisma";
const String imgBackgroundKey = "imgbackground";
const String roomImgKey = "roomImg";
const String roomIntroKey = "roomIntro";
const String roomNameKey = "room_name";
const String removeChatKey = "removeChat";
const String kicKout = "kickout";
const String topSendGifts = "topSendGifts";
const String ownerId = "owner_id";
const String closeVideo = 'close_video';
const String boxCoinsKey = "boxCoins";
String youtubeApiKey = "AIzaSyBxuDgQCp9CWKZvPmq7oFOsUuUeUAn6M74";
const String showLuckyBoxKey = "showluckybox";
const String hideLuckyBoxKey = "hideluckybox";
const String winnerLuckyBoxKey = "winnerLuckyBox";
const String boxIDKey = "boxId";
const String boxTypeKey = "boxType";
const String ownerBoxNameKey = "ownerBoxName";
const String ownerBoxIdKey = "ownerBoxId";
const String _micStateCacheKey = 'user_mic_state';

// ---------------------------------------------------------------------------
// Custom ValueNotifiers (unchanged — performance pattern)
// ---------------------------------------------------------------------------

/// A [ValueNotifier] that only notifies listeners when the new value
/// differs from the old one, using [==]. This prevents redundant rebuilds
/// for primitive and [Equatable] types.
class EqualityValueNotifier<T> extends ValueNotifier<T> {
  EqualityValueNotifier(super.value);

  @override
  set value(T newValue) {
    if (newValue != super.value) {
      super.value = newValue;
    }
  }
}

/// A [ValueNotifier] specialised for [List] that uses [listEquals]
/// instead of reference equality.
class ListValueNotifier<T> extends ValueNotifier<List<T>> {
  ListValueNotifier(super.value);

  @override
  set value(List<T> newValue) {
    if (!listEquals(super.value, newValue)) {
      super.value = newValue;
    }
  }

  void clearAll() {
    if (super.value.isNotEmpty) {
      super.value = [];
    }
  }
}

// ---------------------------------------------------------------------------
// RoomData singleton (core room state)
// ---------------------------------------------------------------------------

class RoomData {
  RoomData._privateConstructor();

  static final RoomData _instance = RoomData._privateConstructor();

  static RoomData get instance => _instance;

  // ========== UTD Room Controller ==========
  final ValueNotifier<UTDRoomController?> _utdControllerNotifier =
  ValueNotifier<UTDRoomController?>(null);

  ValueNotifier<UTDRoomController?> get utdControllerNotifier =>
      _utdControllerNotifier;

  UTDRoomController? get utdController => _utdControllerNotifier.value;
  set utdController(UTDRoomController? value) =>
      _utdControllerNotifier.value = value;

  UTDChatController? get chatController => utdController?.chatController;

  /// Completer to track when the quit_room API call completes
  /// Used to prevent entering a new room before fully leaving the current one
  Completer<bool>? _exitRoomCompleter;

  /// Returns true if currently in the process of exiting a room
  bool get isExitingRoom =>
      _exitRoomCompleter != null && !_exitRoomCompleter!.isCompleted;

  /// Starts tracking an exit room operation
  void startExitRoom() {
    _exitRoomCompleter = Completer<bool>();
  }

  /// Marks the exit room operation as complete
  void completeExitRoom({bool success = true}) {
    if (_exitRoomCompleter != null && !_exitRoomCompleter!.isCompleted) {
      _exitRoomCompleter!.complete(success);
    }
  }

  /// Waits for the current exit room operation to complete if one is in progress
  /// Returns immediately if no exit is in progress
  Future<void> waitForExitRoomComplete() async {
    if (_exitRoomCompleter != null && !_exitRoomCompleter!.isCompleted) {
      await _exitRoomCompleter!.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          // If timeout, reset the completer and allow entry
          _exitRoomCompleter = null;
          return false;
        },
      );
    }
  }

  /// In-room admin membership, keyed by user id. The app backend is the source
  /// of truth: this map is SEEDED from the enter-room admin list
  /// ([EnterRoomModel.admins]) on connect and kept in sync via live
  /// `_role_change` deltas (see [wireRoleSync]/[seedAdminsFromEnterRoom]).
  /// Every UI gate reads this map.
  Map<String, String> adminsInRoom = {};

  /// Bumped whenever admin/role state changes (local action or remote
  /// `_role_change`) so role-dependent widgets rebuild. Just a rebuild signal —
  /// the data lives in [adminsInRoom].
  final ValueNotifier<int> roleVersion = ValueNotifier<int>(0);
  void bumpRoleVersion() => roleVersion.value++;

  StreamSubscription<UTDRoleChangeEvent>? _roleSub;
  VoidCallback? _roleConnListener;

  bool runningCinemaMode = false;
  final EqualityValueNotifier<bool> minimizeGiftFamous =
  EqualityValueNotifier<bool>(false);
  final EqualityValueNotifier<String> myCoins = EqualityValueNotifier<String>(
    '',
  );
  String differentCommentKey = "";

  // Backing field for [room]. Kept (stale) after exit on purpose — mirrors the
  // previous `late` semantics so post-exit readers see the last room, while the
  // setter can detect the ENTER-ROOM response (the one carrying `admins`).
  EnterRoomModel? _room;
  EnterRoomModel get room => _room!;

  /// The room WITHOUT throwing when nothing has been assigned yet. Anything
  /// that can run on a room screen's first frame must use this — [room] throws,
  /// and the pre-navigation stub is not always in place.
  EnterRoomModel? get roomOrNull => _room;
  set room(EnterRoomModel value) {
    _room = value;
    // Only the enter-room response has a non-null admins list — the pre-
    // navigation stub built from the rooms list does not. Resolve the kit's
    // admin source (adminIdsResolver) only on the real one: a stored admin
    // who joined optimistically as `audience` is then self-upgraded through
    // the engine role endpoint (kit upgradeSelfRole), so admins always end
    // with admin powers without gating anyone's join.
    if (value.admins != null) {
      JoinTimeline.mark('enterRoomResp');
      if (_adminsCompleter != null && !_adminsCompleter!.isCompleted) {
        _adminsCompleter!.complete(value.admins!);
      }
    }
  }

  Completer<List<String>>? _adminsCompleter;

  /// True when [RoomStateManager] dispatched [EnterRoomEvent] at TAP TIME
  /// (before pushing the room route) so the response overlaps the route
  /// transition. The screen's setup consumes (and clears) it to skip its
  /// duplicate dispatch.
  bool _enterRoomDispatchedAtTap = false;

  void markEnterRoomDispatchedAtTap() => _enterRoomDispatchedAtTap = true;

  /// Reads AND clears the tap-dispatch flag.
  bool takeEnterRoomDispatchedAtTap() {
    final value = _enterRoomDispatchedAtTap;
    _enterRoomDispatchedAtTap = false;
    return value;
  }

  /// Resolves with the room's backend admin list the moment an enter-room
  /// response with a non-null `admins` lands (immediately if it already did).
  Future<List<String>> get adminsWhenLoaded {
    final loaded = _room;
    if (loaded?.admins != null) return Future.value(loaded!.admins!);
    _adminsCompleter ??= Completer<List<String>>();
    return _adminsCompleter!.future;
  }

  /// The userId (as String) of the user currently controlling the shared
  /// music session (the "DJ"). Null when no music session is active.
  /// Set when a user starts a track, cleared when the music stops or the DJ
  /// leaves. Used to lock playback controls to a single user.
  String? musicControllerUserId;
  final ValueNotifier<List<List<int>>> showCp = ValueNotifier<List<List<int>>>(
    [],
  );

  /// Measured rendered height of [RoomHeader] — the audio-room kit is
  /// closed-source and stacks the seat grid BELOW whatever `headerWidget` is
  /// passed to it (a plain Column, not a Positioned overlay), so the CP heart
  /// overlay (a separate Positioned.fill layer starting at the very top of
  /// the same Stack) needs this exact value as its own top offset to land on
  /// the real seat row instead of floating above it, under the header.
  /// [RoomHeader] measures itself and updates this after each layout.
  final ValueNotifier<double> headerHeight = ValueNotifier<double>(0);
  bool isShowInvitation = false;
  final EqualityValueNotifier<bool> isError = EqualityValueNotifier<bool>(
    false,
  );
  final EqualityValueNotifier<bool> isCharismaVisible =
  EqualityValueNotifier<bool>(false);
  final EqualityValueNotifier<bool> isCommentsClosed =
  EqualityValueNotifier<bool>(false);
  // Real-time room-lock indicator shown next to the room name in the header.
  // Seeded from the enter-room password status, flipped live on lock/unlock
  // (owner action broadcasts `roomPassword` to everyone in the room).
  final EqualityValueNotifier<bool> isRoomLocked = EqualityValueNotifier<bool>(
    false,
  );
  bool cachedMicState = true;

  // ========== RTM Subscription Management ==========
  final List<StreamSubscription<dynamic>> _rtmSubs = [];
  RtmHandler? rtmHandler;
  bool _rtmActive = false;
  VoidCallback? _modeIdListener;

  /// Initializes RTM by subscribing to LiveKit data channel events
  /// via [UTDRoomController].
  ///
  /// Replaces the old Zego RTM subscriptions:
  /// - `getSignalingPlugin().getInRoomTextMessageReceivedEventStream()` → removed (was empty)
  /// - `getInRoomCommandReceivedStream()` → [UTDRoomController.dataStream]
  /// - `getUserJoinStream()` → [UTDRoomManager.participantJoinedStream]
  void initRtm({
    required GiftController giftController,
    required String roomId,
    required String userModelId,
    required bool isHost,
    required TickerProvider tickerProvider,
  }) {
    if (_rtmActive) return;

    rtmHandler = RtmHandler(
      giftController: giftController,
      roomId: roomId,
      userModelId: userModelId,
      isHost: isHost,
      tickerProvider: tickerProvider,
    );
    // Only install a navigator-backed supplier when the navigator is mounted.
    // When it is not, leave it unset so RtmHandler's `??=` fallback supplies a
    // valid context from the incoming message call site instead of crashing on
    // a null check.
    final navState = SafeNavigator.state;
    if (navState != null) {
      rtmHandler!.contextSupplier = () => navState.context;
    }

    // Subscribe to LiveKit data channel messages (replaces Zego getInRoomCommandReceivedStream)
    if (utdController != null) {
      _rtmSubs.add(
        utdController!.dataStream.listen((data) {
          final ctx = navKey.currentState?.context;
          if (ctx == null) return;
          // Data arrives already parsed as Map<String, dynamic> from LiveKit data channel.
          // Pass to rtmHandler for batched processing.
          rtmHandler?.onDataReceived(data, ctx);
        }),
      );

      // Subscribe to participant join events (replaces Zego getUserJoinStream)
      _rtmSubs.add(
        utdController!.participantJoinedStream.listen((participant) {
          onUserJoined(participant);
        }),
      );

      // Subscribe to participant leave events so we can release the shared-music
      // DJ lock if the active DJ leaves without broadcasting a stop.
      _rtmSubs.add(
        utdController!.participantLeftStream.listen((participant) {
          onUserLeft(participant);
        }),
      );
    }

    _rtmActive = true;

    // Charisma totals are server-authoritative: a (re)joiner gets the live seat
    // totals from the enter-room payload (per-seat charisma_total) on entry and
    // from each gift frame thereafter — no client resync request needed.

    // Wire speaker invitation UI callback from the package.
    // The package handles accept/decline + takeSeat + mic internally —
    // the app just needs to show the dialog and return true/false.
    if (utdController != null) {
      utdController!.onInvitationUI = (data) async {
        return await showSpeakerInvitationDialog(data);
      };

      _modeIdListener = () {
        final newModeId = utdController!.seatController.modeId.value;
        if (newModeId != null) {
          handleRoomModeChangeNew(mode_id: newModeId);
        }
      };
      utdController!.seatController.modeId.addListener(_modeIdListener!);
    }
  }

  void disposeRtm() {
    if (_modeIdListener != null) {
      utdController?.seatController.modeId.removeListener(_modeIdListener!);
      _modeIdListener = null;
    }
    for (final sub in _rtmSubs) {
      sub.cancel();
    }
    _rtmSubs.clear();
    rtmHandler?.dispose();
    rtmHandler = null;
    _rtmActive = false;
  }

  // ========== Engine role sync ==========

  /// The controller [wireRoleSync] attached listeners to, so [unwireRoleSync]
  /// detaches from the SAME instance even if [utdController] was reassigned.
  UTDRoomController? _roleSyncController;

  /// Wires admin role sync to [controller]: seeds [adminsInRoom] from the app's
  /// own enter-room admin list ([EnterRoomModel.admins]) and keeps it in sync
  /// via live `_role_change` deltas. Idempotent (safe on minimize-restore).
  void wireRoleSync(UTDRoomController controller) {
    unwireRoleSync();
    _roleSyncController = controller;

    // Initial seed of the admin map from the app backend (enter-room response).
    seedAdminsFromEnterRoom();

    // Live updates: a role change adds/removes admin membership.
    _roleSub = controller.roleChangeStream.listen((e) {
      if (e.identity.isEmpty) return;
      if (e.role == 'admin') {
        adminsInRoom[e.identity] = e.identity;
      } else {
        adminsInRoom.remove(e.identity);
      }
      bumpRoleVersion();
    });

    // On reconnect, re-apply the backend baseline ADDITIVELY so in-session
    // promotions (live `_role_change` deltas already in [adminsInRoom]) survive.
    _roleConnListener = () {
      if (controller.connectionState.value == UTDConnectionState.connected) {
        seedAdminsFromEnterRoom(merge: true);
      }
    };
    controller.connectionState.addListener(_roleConnListener!);
  }

  void unwireRoleSync() {
    _roleSub?.cancel();
    _roleSub = null;
    if (_roleConnListener != null) {
      _roleSyncController?.connectionState.removeListener(_roleConnListener!);
      _roleConnListener = null;
    }
    _roleSyncController = null;
  }

  /// Seeds [adminsInRoom] from the app's enter-room admin list
  /// ([EnterRoomModel.admins]) — the app backend is the source of truth for
  /// admins. Then bumps [roleVersion].
  ///
  /// When [merge] is true (reconnect), the backend baseline is added without
  /// clearing, so live `_role_change` promotions already in [adminsInRoom] are
  /// preserved. When false (initial seed), the map is reset to the baseline.
  void seedAdminsFromEnterRoom({bool merge = false}) {
    try {
      final admins = <String>{
        for (final id in (room.admins ?? const <String>[]))
          if (id.isNotEmpty) id,
      };
      // Fold in the local user's own role so a rejoining admin's gates are
      // correct immediately (their token metadata role reflects the app list).
      final localId = utdController?.localIdentity;
      if (localId != null &&
          utdController?.getParticipantRole(localId) == 'admin') {
        admins.add(localId);
      }
      if (!merge) adminsInRoom.clear();
      adminsInRoom.addEntries(admins.map((id) => MapEntry(id, id)));
      bumpRoleVersion();
    } catch (e) {
      Methods.printLog('seedAdminsFromEnterRoom error: $e');
    }
  }

  Map<int, UserInRoomModel> users = {};

  Map<String, String> roomDataUpdates = {
    'room_intro': '',
    'room_name': '',
    'room_img': '',
    'room_type': '',
  };

  Map<String, dynamic> userGameBanner = {
    'user_image': "",
    'user_name': "",
    'uId': "",
    'coins': "",
    'game_image': "",
  };

  /// Resets all mutable room state. Call on every room exit to prevent
  /// stale values and accumulated listeners across sessions.
  void reset() {
    minimizeGiftFamous.value = false;
    myCoins.value = '';
    isError.value = false;
    isCommentsClosed.value = false;
    isCharismaVisible.value = false;
    isRoomLocked.value = false;
    showCp.value = [];
    isShowInvitation = false;
    runningCinemaMode = false;
    musicControllerUserId = null;
    unwireRoleSync();
    adminsInRoom.clear();
    roleVersion.value = 0;
    _enterRoomDispatchedAtTap = false;
    // Release any pending admin waiters (the kit's post-connect upgrade hook
    // resolves to "not an admin") and start the next room with a fresh
    // completer.
    if (_adminsCompleter != null && !_adminsCompleter!.isCompleted) {
      _adminsCompleter!.complete(const []);
    }
    _adminsCompleter = null;
    final oldController = utdController;
    utdController = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      oldController?.dispose();
    });
    RoomScreenState.seatAvatarKeys.clear();
    RoomScreenState.seatAvatarContexts.clear();
    RoomScreenState.seatAvatarIds.clear();
    userGameBanner = {
      'user_image': "",
      'user_name': "",
      'uId': "",
      'coins': "",
      'game_image': "",
    };
    LuckyBoxVariables.reset();
    di<SetTimerPK>().dispose();
    di<SetTimerLuckyBox>().dispose();
    LudoRoomController.instance.reset();
    CaromRoomController.instance.reset();
    RoomService.instance.reset();
  }
}

// ---------------------------------------------------------------------------
// Mic state cache (unchanged)
// ---------------------------------------------------------------------------

void loadCachedMicState() {
  RoomData.instance.cachedMicState =
      HiveManager().getData<bool>(KeysManager.ROOMS_BOX, _micStateCacheKey) ??
          true;
}

void saveMicState(bool isEnabled) {
  RoomData.instance.cachedMicState = isEnabled;
  HiveManager().saveData(KeysManager.ROOMS_BOX, _micStateCacheKey, isEnabled);
}

void sendRoomData({required Map<String, dynamic> data, String? userId}) {
  // Wire contract (see RoomMessageProcessor): {"messageContent": {"message": ..}}.
  // Correct callers pass the bare inner map {"message": ..}. Some callers reuse
  // the legacy video-room map shape {"action": .., "messageContent": {..}} (or an
  // already-wrapped {"messageContent": {..}}). Without normalization those get
  // double-wrapped here and the receiver's content['message'] is null, so the
  // message is silently dropped. Unwrap an already-present messageContent so
  // every send site lands on the single correct shape.
  final inner = data['messageContent'];
  final Map<String, dynamic> content =
  inner is Map ? Map<String, dynamic>.from(inner) : data;
  final payload = {"messageContent": content};

  // Route to the ACTIVE room's controller. In a live (video) room the audio
  // `utdController` is null, so without this every shared broadcast (lucky
  // gifts, entry effects, …) would be silently dropped. The live room keeps its
  // own controller in LiveRoomData and exposes the same wire contract via
  // sendLiveRoomData.
  if (di<RoomStateManager>().isInVideoRoom) {
    LiveRoomData.instance.sendLiveRoomData(data: payload, userId: userId);
    return;
  }
  final controller = RoomData.instance.utdController;
  if (controller == null) return;

  if (userId != null) {
    controller.sendTargetedMessage(payload, [userId]);
  } else {
    controller.sendRoomMessage(payload);
  }
}

// ---------------------------------------------------------------------------
// Shared-music permission helpers
// ---------------------------------------------------------------------------

/// True if the current user is the room owner or an admin.
bool _isOwnerOrAdmin() {
  final myId = MyDataModel.getInstance().id.toString();
  return myId == RoomData.instance.room.ownerId.toString() ||
      RoomData.instance.adminsInRoom.containsKey(myId);
}

/// Whether the current user may START a new shared-music session.
/// Allowed only for the owner/admin AND only when no DJ session is active
/// (control is locked to whoever started the current session).
bool canStartMusic() =>
    _isOwnerOrAdmin() && RoomData.instance.musicControllerUserId == null;

/// Whether the current user controls the live shared-music session.
/// Only the active DJ (the user who started the music) can control playback.
bool canControlMusic() =>
    RoomData.instance.musicControllerUserId != null &&
        RoomData.instance.musicControllerUserId ==
            MyDataModel.getInstance().id.toString();

/// Kicks a user from the microphone by broadcasting a data channel message.
/// Replaces the old Zego version that used `sendInRoomCommand`.
void kickUserfromMic({required String userId}) {
  sendRoomData(data: {"message": "kickUserfromMic", "user_id": userId});
}

// ---------------------------------------------------------------------------
// Coins & CP (unchanged)
// ---------------------------------------------------------------------------

Future<String> getUserCoins() async {
  try {
    final result = await RoomRemoteDataSourceImp(di()).fetchConfigKey(null);
    final coins = result.data?.userCoin.toString() ?? "0";
    RoomData.instance.myCoins.value = coins;
    return coins;
  } catch (error) {
    Methods.printLog(
      'getUserCoins failed: ${NetworkExceptions.getErrorMessage(NetworkExceptions.getDioException(error))}',
    );
    return RoomData.instance.myCoins.value;
  }
}

void showCp(Map<String, dynamic> resulta) {
  List<List<int>> pairs =
  (resulta["data"] as List)
      .map((inner) => (inner as List).map((e) => e as int).toList())
      .toList();

  RoomData.instance.showCp.value = pairs;
}

void showGameBanner(
    Map<String, dynamic> result,
    Map<String, dynamic> userGameBanner,
    ) {
  userGameBanner['user_image'] = result[messageContent]['uImage'].toString();
  userGameBanner['user_name'] = result[messageContent]['uName'].toString();
  userGameBanner['coins'] = result[messageContent]['coins'].toString();
  userGameBanner['game_image'] = result[messageContent]['gImage'].toString();
  userGameBanner['uId'] = result[messageContent]['uId'].toString();
}

// ---------------------------------------------------------------------------
// Invite to seat — uses package speaker API (_speaker_invitation)
// ---------------------------------------------------------------------------

/// Shows the speaker invitation dialog when the backend sends a
/// `_speaker_invitation` data message to the invited user.
///
/// The invitation flow is now driven entirely by the package:
/// 1. Host calls `controller.inviteToSpeak(targetId)` → REST API
/// 2. Backend sends `_speaker_invitation` to the target user
/// 3. This function is called from the speakerEventStream listener
/// 4. On accept: `controller.acceptInvitation(id)` → backend auto-seats user
/// 5. On decline: `controller.declineInvitation(id)`
/// Shows the speaker invitation dialog and returns `true` if user accepted,
/// `false` if declined. The package handles all the logic (accept API call,
/// takeSeat, mic enable) — this function just shows UI.
Future<bool> showSpeakerInvitationDialog(Map<String, dynamic> data) async {
  if (RoomData.instance.isShowInvitation) return false;

  final inviterIdentity = data['inviter_identity'] as String?;
  final seatIndex = (data['seat_index'] as num?)?.toInt();

  // Try to get inviter name/image from cached user data
  final inviterId = int.tryParse(inviterIdentity ?? '');
  final inviterData =
  inviterId != null ? UsersCache().getUser(inviterId) : null;

  RoomData.instance.isShowInvitation = true;

  final ctx = navKey.currentState?.context;
  if (ctx == null) {
    RoomData.instance.isShowInvitation = false;
    return false;
  }

  // Use a Completer to track user's decision
  final completer = Completer<bool>();

  // Live room: the invite is to the STAGE (الجست), not a numbered mic seat.
  final isLiveInvite = di<RoomStateManager>().isInVideoRoom;
  final invitationTitle =
  isLiveInvite
      ? (Methods.getLang() == 'ar'
      ? 'دعاك ${inviterData?.name ?? inviterIdentity ?? ''} للانضمام إلى الجست'
      : '${inviterData?.name ?? inviterIdentity ?? ''} invited you to join the stage')
      : "${StringManager.invitationToMic.tr()} #${seatIndex != null ? seatIndex + 1 : ''}";

  showDialog(
    context: ctx,
    builder:
        (_) => AnimatedDialog(
      title: invitationTitle,
      height: 55.h,
      width: 12.w,
      titleDivider: false,
      fontSize: 18.sp,
      cancelFontSize: 19.sp,
      cancelHeight: 55.h,
      cancelWidth: 12.w,
      isHideConfirm: false,
      cancelText: StringManager.denied.tr(),
      conText: StringManager.accept.tr(),
      borderColor: ColorManager.primary,
      cancelTextColor: ColorManager.primary,
      child: Column(
        children: [
          UserImage(
            image: inviterData?.image ?? "",
            displayName: inviterData?.name ?? inviterIdentity ?? "",
            imageSize: 80.w,
            borderRadius: BorderRadius.circular(40.r),
          ),
          15.hBox,
          TextWidget(
            inviterData?.name ?? inviterIdentity ?? "",
            style: ctx.bodyMedium.w500
                .size(18)
                .colorExt(ColorManager.backConnction),
          ),
          15.hBox,
          TextWidget(
            '${StringManager.invitationToMic.tr()} #${seatIndex != null ? seatIndex + 1 : ''}',
            style: ctx.bodyMedium.w500
                .size(18)
                .colorExt(ColorManager.backConnction),
          ),
        ],
      ),
      onTap: () {
        SafeNavigator.pop();
        if (!completer.isCompleted) completer.complete(true);
      },
    ),
  ).then((_) {
    // Dialog dismissed (cancel button or back button)
    if (!completer.isCompleted) completer.complete(false);
    RoomData.instance.isShowInvitation = false;
  });

  return completer.future;
}

// ---------------------------------------------------------------------------
// Background change (unchanged)
// ---------------------------------------------------------------------------

void changeBackgroundRoom(
    Map<String, dynamic> result,
    Map<String, String> roomDataUpdates,
    ) {
  RoomBackground.imgBackground.value =
      result[messageContent][imgBackgroundKey] ?? "";
  roomDataUpdates['room_img'] = result[messageContent][roomImgKey];
  roomDataUpdates['room_intro'] = result[messageContent][roomIntroKey];
  roomDataUpdates['room_name'] = result[messageContent][roomNameKey];
  roomDataUpdates['room_type'] = result[messageContent]['room_type'] ?? "";
  OwnerOfRoom.isEditRoom.value = OwnerOfRoom.isEditRoom.value + 1;
  Methods.setDataRooms(
    data: {
      "name": RoomData.instance.room.roomName ?? "",
      "ownerId": RoomData.instance.room.ownerId,
      "id": RoomData.instance.room.id,
      "cover": RoomData.instance.room.roomCover,
      "background": result[messageContent][imgBackgroundKey],
      "mode": RoomData.instance.room.mode,
      "uuid": RoomData.instance.room.uuidOwnerRoom,
      "luckyGiftCoins": RoomData.instance.room.luckyGiftCoins,
      "giftPrice": RoomData.instance.room.giftPrice,
      "ownerSpecialId": RoomData.instance.room.ownerSpecialId,
      'ownerIdColors': RoomData.instance.room.ownerImageColor?.color,
    },
    id: RoomData.instance.room.id.toString(),
  );
}

// ---------------------------------------------------------------------------
// Kick out member (unchanged)
// ---------------------------------------------------------------------------

/// Legacy custom-kickout fallback. Moderation now flows through the UTD-Stream
/// kit (engine ban → `_banned` → the kit's own banned dialog + clean leave), so
/// this is only a defensive exit for any stray legacy `kickout` frame.
void kicKoutMember(
    Map<String, dynamic> result,
    String ownerId,
    int roomId,
    String id,
    BuildContext context,
    ) async {
  final ctx = SafeNavigator.context;
  if (ctx == null) return;
  await di<RoomStateManager>().exitRoom(
    ctx,
    callback: () {
      Navigator.popUntil(
        context,
            (route) => route.settings.name == Routes.layout,
      );
    },
  );
}

// ---------------------------------------------------------------------------
// User data fetching (unchanged)
// ---------------------------------------------------------------------------

Future<Map<int, UserInRoomModel>> getUsersByIds(List<int> userIds) async {
  final Map<int, UserInRoomModel> result = {};
  final remainingIds = <int>[];

  for (final id in userIds) {
    final cachedUser = UsersCache().getUser(id);
    if (cachedUser != null) {
      result[id] = cachedUser;
    } else {
      remainingIds.add(id);
    }
  }

  if (remainingIds.isNotEmpty) {
    // Firestore (room_users) was a middle cache between Hive and the backend.
    // It is disabled on this project and only ever fell through to the backend,
    // so it is removed: go straight from the Hive cache to the authoritative
    // backend /users/details. Instant in-room display comes from the UTD-Stream
    // seat attributes the kit already carries (no extra round-trip).
    final List<int> idsToFetchFromBackend = remainingIds;

    if (idsToFetchFromBackend.isNotEmpty) {
      try {
        // Call the use case directly instead of dispatching a bloc event
        // and waiting on the stream — eliminates the subscription leak,
        // race condition, and potential indefinite hang.
        final apiResult = await di<FetchUsersDataUc>()
            .call(idsToFetchFromBackend.map((e) => e.toString()).toList())
            .timeout(const Duration(seconds: 5));

        switch (apiResult) {
          case Right(value: final response):
            final backendUsers =
            (response.data ?? [])
                .map((entry) => UserInRoomModel.fromUserEntity(entry))
                .toList();

            for (final data in backendUsers) {
              result[data.id ?? -1] = data;
            }
            await Future.wait(
              backendUsers.map((data) => UsersCache().setUser(data)),
            );
          case Left(value: final error):
            Methods.printLog(
              'Error fetching users from backend: ${NetworkExceptions.getErrorMessage(error)}',
            );
        }
      } catch (e) {
        Methods.printLog('Error fetching users from backend: $e');
      }
    }
  }

  return result;
}

// ---------------------------------------------------------------------------
// Room entry success — replaces Zego with UTD Kit
// ---------------------------------------------------------------------------

void onEnterRoomSuccess() {
  GiftController().normalGiftsToShow.clear();
  // Fetch bad words from server when entering a room
  _fetchBadWords();
  Future.delayed(const Duration(seconds: 1), () async {
    // Guard: abort if the user exited the room during the delay
    if (!di<RoomStateManager>().isInRoom || RoomData.instance.isExitingRoom) {
      return;
    }

    // Send join message via data channel
    RoomData.instance.chatController?.sendMessage(
      "joinRoom",
      userData: {
        "img": MyDataModel.getInstance().profile?.image ?? "",
        "bu": MyDataModel.getInstance().bubble ?? "",
        "buId": MyDataModel.getInstance().bubbleId.toString(),
        "sL": MyDataModel.getInstance().level?.senderImage ?? "",
        "rL": MyDataModel.getInstance().level?.receiverImage ?? "",
        "v": MyDataModel.getInstance().vip1?.img1 ?? "",
        "c": MyDataModel.getInstance().vip1?.colorName ?? "",
        "senderId": MyDataModel.getInstance().id?.toString() ?? "",
        "senderName": MyDataModel.getInstance().name ?? "",
        'type': 'message',
      },
    );

    // Send user entro via data channel
    final entroData = {
      "message": "userEntro",
      "userId": MyDataModel.getInstance().id.toString(),
      "wabbleId": MyDataModel.getInstance().wabbleId ?? -1,
      "entroImg": MyDataModel.getInstance().intro,
      "entroImgId": MyDataModel.getInstance().introId,
      "entroType": MyDataModel.getInstance().introType,
      'userName': MyDataModel.getInstance().name,
      'userVip': MyDataModel.getInstance().vip1?.level ?? 0,
      'userImge': MyDataModel.getInstance().profile?.image,
      'vip': ((MyDataModel.getInstance().vip1?.level ?? 0) > 0) ? true : false,
    };
    sendRoomData(data: entroData);

    if (MyDataModel.getInstance().roomEffects?.showEntring == true) {
      GiftController().userEntro({
        "messageContent": entroData,
      }, GiftController().userIntroData);
    }

    if (MyDataModel.getInstance().id == RoomData.instance.room.ownerId) {
      final status = await Permission.microphone.status;
      if (status.isDenied) {
        await Methods.requestPermission(Permission.microphone);
      }

      final micDialogCtx = SafeNavigator.context;
      if (micDialogCtx != null) {
        await MicBackgroundHelper.showMicBackgroundDialogIfNeeded(micDialogCtx);
      }

      // Take seat 0 via UTD Kit seat controller
      final controller = RoomData.instance.utdController;
      if (controller != null) {
        try {
          // Guard the owner seat/mic initialization with an overall timeout so a
          // hung connect/seat operation can never freeze the user in the room.
          await controller.seatController
              .takeSeat(0, MyDataModel.getInstance().id.toString())
              .timeout(const Duration(seconds: 30));

          // Enable mic after a short delay. Publishing the mic track can throw
          // a realtime-engine exception (TrackPublishException / NegotiationError
          // / TimeoutException) when the media server is slow; this runs detached
          // so an unhandled throw would escape to the zone guard and read as a
          // crash. Guard it and record non-fatal.
          Future.delayed(const Duration(milliseconds: 500), () async {
            try {
              await controller.mediaController.setMicrophoneEnabled(
                RoomData.instance.cachedMicState,
              );
            } catch (e, s) {
              Methods.recordNonFatal(
                e,
                s,
                reason: 'owner seat setMicrophoneEnabled',
              );
            }
          });
        } on TimeoutException catch (e) {
          Methods.printLog('Owner seat initialization timed out: $e');
          // Bail out gracefully so the user is not stuck on a frozen room.
          final ctx = navKey.currentContext;
          if (ctx != null) {
            await di<RoomStateManager>().exitRoom(ctx);
          }
        } catch (e) {
          Methods.printLog('Owner seat initialization failed: $e');
        }
      }
    }
  });
}

/// Fetches bad words from the server and loads them into BadWordsManager.
/// Only calls the API once per app lifecycle — subsequent room entries
/// skip the fetch since BadWordsManager is a singleton.
Future<void> _fetchBadWords() async {
  if (BadWordsManager.instance.isLoaded) return;
  try {
    final result = await di<FetchBadWordsUC>().call();
    switch (result) {
      case Right(value: final response):
        BadWordsManager.instance.setBadWords(response.data ?? []);
      case Left(value: final error):
        Methods.printLog(
          '❌ Failed to fetch bad words: ${NetworkExceptions.getErrorMessage(error)}',
        );
    }
  } catch (e) {
    Methods.printLog('❌ Error fetching bad words: $e');
  }
}

// ---------------------------------------------------------------------------
// User join handling — replaces UTDParticipant with LiveKit Participant
// ---------------------------------------------------------------------------

// Tracks user IDs currently being fetched to prevent concurrent onUserJoined
// calls from double-removing and double-fetching the same user data.
final Set<int> _pendingUserFetches = {};

/// Clear pending user fetch tracking. Call on room exit to prevent
/// stale IDs from blocking fetches in the next room session.
void clearPendingUserFetches() {
  _pendingUserFetches.clear();
}

/// Called when a participant joins the room.
/// Accepts a LiveKit [Participant] (replaces old `List<UTDParticipant>`).
void onUserJoined(Participant participant) async {
  final participantId = participant.identity;

  if (MyDataModel.getInstance().id == RoomData.instance.room.ownerId) {
    if (MyDataModel.getInstance().id.toString() != participantId &&
        di<YoutubeBloc>().controller != null &&
        RoomData.instance.room.mode == '5') {
      double duration = await di<YoutubeBloc>().controller!.currentTime;
      String status =
      di<YoutubeBloc>().controller!.value.playerState == PlayerState.playing
          ? "play"
          : "pause";
      String url = di<YoutubeBloc>().controller?.metadata.videoId ?? "";
      sendRoomData(
        data: {
          "message": 'playVideoForOneUser',
          "url": url,
          "duration": duration,
          "status": status,
        },
        userId: participantId,
      );
    }
  }

  // If I'm the active music DJ and a song is playing, sync the newly-joined
  // user so they hear the current track from the current position. Delayed so
  // the joiner's data-channel listener is ready to receive it.
  if (RoomData.instance.musicControllerUserId ==
      MyDataModel.getInstance().id.toString() &&
      di<MusicRoomBloc>().isAudioActuallyPlaying &&
      MyDataModel.getInstance().id.toString() != participantId) {
    Future.delayed(const Duration(seconds: 2), () {
      if (RoomData.instance.musicControllerUserId !=
          MyDataModel.getInstance().id.toString() ||
          !di<MusicRoomBloc>().isAudioActuallyPlaying) {
        return;
      }
      final payload = MusicController().buildMusicSyncPayload(MusicAction.play)
        ..['message'] = 'playMusicForOneUser';
      Methods.printLog('🎵 [music] syncing late joiner $participantId');
      sendRoomData(data: payload, userId: participantId);
    });
  }

  // Charisma is server-authoritative: a late joiner gets the live seat totals
  // from the enter-room payload and from each gift frame thereafter — there is
  // no client-side resync request/response.

  final userId = int.tryParse(participantId);
  if (userId == null) return;

  final userIds = [userId];

  // Skip IDs already being fetched — prevents a second concurrent call from
  // clearing the cache for the same user while the first fetch is in flight.
  if (_pendingUserFetches.contains(userId)) return;

  _pendingUserFetches.addAll(userIds);
  try {
    final fetchedUsers = await getUsersByIds(userIds);

    for (final entry in fetchedUsers.entries) {
      final uId = entry.value.id ?? 0;
      RoomData.instance.users[uId] = entry.value;
      await UsersCache().setUser(entry.value);
    }

    RoomData.instance.utdController?.refreshParticipants();
  } finally {
    _pendingUserFetches.removeAll(userIds);
  }
}

/// Called when a participant leaves the room. If the departing user is the
/// active shared-music DJ, release the lock and stop receiver playback.
///
/// The DJ normally broadcasts a stop (`destroyMusic`) when they end a session,
/// but an unclean leave (app killed, network drop, or exiting while paused)
/// sends nothing — without this every other client keeps [musicControllerUserId]
/// pinned to the departed DJ, so `canStartMusic()` stays false and nobody can
/// start a new music session.
void onUserLeft(Participant participant) {
  final leftId = participant.identity;
  if (RoomData.instance.musicControllerUserId != leftId) return;

  Methods.printLog('🎵 [music] active DJ $leftId left — releasing music lock');
  final bloc = di<MusicRoomBloc>();
  if (!bloc.isClosed && !bloc.isDisposed) {
    // Mirror the destroyMusic receiver path: stops the player AND clears
    // musicControllerUserId (see MusicAction.kill in _applyRemoteMusic).
    bloc.add(
      const ApplyRemoteMusicEvent(
        action: MusicAction.kill,
        songUrl: '',
        volume: 0,
        positionMs: 0,
        controllerId: '',
      ),
    );
  } else {
    // Bloc already gone — at least clear the lock so a new DJ can start.
    RoomData.instance.musicControllerUserId = null;
  }
}

// ---------------------------------------------------------------------------
// Users cache (unchanged)
// ---------------------------------------------------------------------------

class UsersCache {
  static final UsersCache _instance = UsersCache._internal();

  factory UsersCache() => _instance;
  UsersCache._internal();

  UserInRoomModel? getUser(int id) {
    final rawMap = HiveManager.instance.getData<Map>(
      KeysManager.ROOM_USERS_BOX,
      id.toString(),
    );

    if (rawMap == null) return null;

    final map = Map<String, dynamic>.from(rawMap);

    return UserInRoomModel.fromMap(map);
  }

  Future<void> setUser(UserInRoomModel user) async {
    // Never cache a user with an invalid id (0/null). A failed lookup defaults to
    // id 0, and caching under key "0" poisons it — later id-0 reads then return
    // this stale user as someone else's profile.
    if (user.id == null || user.id! <= 0) return;
    final key = user.id.toString();
    final box = await HiveManager.instance.openBox(KeysManager.ROOM_USERS_BOX);

    if (box.containsKey(key)) {
      await box.delete(key); // explicitly remove old data
    }

    await HiveManager.instance.saveData<Map<String, dynamic>>(
      KeysManager.ROOM_USERS_BOX,
      key,
      user.toMap(),
    );
  }

  Future<void> removeUser(int id) async {
    await HiveManager.instance.deleteData(
      KeysManager.ROOM_USERS_BOX,
      id.toString(),
    );
  }
}

// ---------------------------------------------------------------------------
// Room setup (unchanged except removed Zego dependency)
// ---------------------------------------------------------------------------

void setupRoomAndUser({
  required bool isLocked,
  required String roomId,
  required BuildContext context,
}) {
  YouTubeController.isCinemaMode.value = RoomData.instance.room.mode == '5';

  // Skip enter_room API if restoring from minimize — the room is already active.
  // On first entry utdController is null (set later by onControllerReady),
  // so this only triggers on minimize restore where the controller persists.
  final stateManager = di<RoomStateManager>();
  final isMinimizeRestore =
      RoomData.instance.utdController != null &&
          stateManager.isInRoom &&
          stateManager.currentRoomId?.toString() == roomId;

  if (isMinimizeRestore) {
    return;
  }

  // Consume the tap-dispatch flag in all paths so it can never leak into a
  // later, unrelated entry.
  final dispatchedAtTap = RoomData.instance.takeEnterRoomDispatchedAtTap();

  if (isLocked == false) {
    // Skip the duplicate dispatch when the tap-time enter_room is already in
    // flight. Exception: if it ALREADY failed (a very fast failure can beat
    // this screen's listeners), re-dispatch so the error is delivered to the
    // now-mounted listeners and the normal error/exit flow runs.
    final tapDispatchInFlight =
        dispatchedAtTap &&
            di<RoomHandlerBloc>().state is! EnterRoomErrorMessageState;
    if (!tapDispatchInFlight) {
      di<RoomHandlerBloc>().add(
        EnterRoomEvent(
          isVip: MyDataModel.getInstance().vip1?.level ?? 0,
          roomId: roomId,
          roomPassword: "",
          context,
        ),
      );
    }
  } else {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      di<RoomHandlerBloc>().add(
        EmitCachedRoomDataEvent(RoomData.instance.room),
      );
    });
  }

  final user = UserInRoomModel.fromMyData(MyDataModel.getInstance());

  RoomData.instance.users[MyDataModel.getInstance().id ?? -1] = user;

  // (Firestore room_users mirror removed — the Hive cache + backend are the
  // only stores now.)
  UsersCache().setUser(user);
}

// ---------------------------------------------------------------------------
// Secondary data loading
// ---------------------------------------------------------------------------

void loadSecondaryData({required String roomId, required String? userCoins}) {
  RoomBackground.imgBackground.value =
      RoomData.instance.room.roomBackground ?? "";

  if (HiveManager().getData<bool>(
    KeysManager.ROOMS_BOX,
    KeysManager.MINIMIZE_GIFT_KEY,
  ) !=
      null) {
    RoomData.instance.minimizeGiftFamous.value =
    HiveManager().getData<bool>(
      KeysManager.ROOMS_BOX,
      KeysManager.MINIMIZE_GIFT_KEY,
    )!;
  }
  di<GiftBloc>().add(
    UpdateRoomGiftsPriceEvent(price: '${RoomData.instance.room.giftPrice}'),
  );
  RoomData.instance.myCoins.value = userCoins ?? '';

  di<CharismaBloc>().add(const FetchCharismaLevelsEvent());
  final boomThemeStale = ConstantsManager.isBoomThemeStale;
  if (boomThemeStale ||
      !di<GetSuperBombsThemeBloc>().state.themesState.isLoaded) {
    // Stale means the panel published new art: go to the network and let the
    // bloc overwrite the Hive copy. Otherwise keep the cache-first path.
    di<GetSuperBombsThemeBloc>().add(
      GetRoomBoomThemesEvent(getFromCache: !boomThemeStale),
    );
    ConstantsManager.isBoomThemeStale = false;
  }
  if (!di<GamesImagesBloc>().state.state.isLoaded) {
    di<GamesImagesBloc>().add(const FetchGamesImagesEvent());
  }
  // Pre-warm super-boom winner animations at room entry (the real consumption
  // context): a boom can end and render its overlay without the user ever
  // opening SuperBombDialog, so warming only on dialog-open left fresh
  // installs / post-asset-update entries with a cold cache and a first-play
  // stutter. Guarded so it fetches once.
  if (!di<GetSuperBombsBloc>().state.videoState.isLoaded) {
    di<GetSuperBombsBloc>().add(GetSuperBoomVideosEvent());
  }

  Future.delayed(const Duration(seconds: 3), () {
    // Shared music is server-backed now, so we no longer preload a local
    // playlist on entry — just restore the cached volume.
    if (!di<MusicRoomBloc>().state.isSongPlaying) {
      MusicController.getCachedVolume().then((cachedVol) {
        di<MusicRoomBloc>().add(SetVolumeRoomEvent(cachedVol));
      });
    }
  });

  Future.delayed(const Duration(seconds: 5), () {
    di<CharismaBloc>().add(GetCharismaExtraDataEvent(roomId: roomId));
  });

  // Admin membership is seeded from the engine (see RoomData.wireRoleSync),
  // not from the app-backend `room.admins` list.
}

// ---------------------------------------------------------------------------
// Room mode change — backend handles via _mode_change event
// ---------------------------------------------------------------------------

void handleRoomModeChangeNew({required String mode_id}) {
  RoomData.instance.room.mode = mode_id;
  YouTubeController.isCinemaMode.value = mode_id == '5';

  Methods.setDataRooms(
    data: {
      "name": RoomData.instance.room.roomName ?? "",
      "ownerId": RoomData.instance.room.ownerId,
      "id": RoomData.instance.room.id,
      "cover": RoomData.instance.room.roomCover,
      "background": RoomData.instance.room.roomBackground,
      "mode": mode_id,
      "uuid": RoomData.instance.room.uuidOwnerRoom,
      "luckyGiftCoins": RoomData.instance.room.luckyGiftCoins,
      "giftPrice": RoomData.instance.room.giftPrice,
      "ownerSpecialId": RoomData.instance.room.ownerSpecialId,
      'ownerIdColors': RoomData.instance.room.ownerImageColor?.color,
    },
    id: RoomData.instance.room.id.toString(),
  ).catchError((e) {
    if (kDebugMode) {
      debugPrint('handleRoomModeChangeNew: cache persist failed: $e');
    }
  });
}


