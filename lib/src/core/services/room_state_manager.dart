import 'dart:async';
import 'dart:developer';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/room/presentation/component/enter_room_pass/enter_room_password.dart';
import 'package:general/src/features/room/presentation/component/messages/lucky_gift_sound_manager.dart';
import 'package:general/src/features/room/room.dart';
import 'package:general/src/features/room/presentation/component/room_header/exit_room/session_summary_dialog.dart';
import 'package:general/src/features/live_room/presentation/live_room_data.dart';
import 'package:general/src/features/games/domain/entities/game_entity.dart';
import 'package:general/src/core/services/join_timeline.dart';
import 'package:general/src/core/services/room_cleanup_helper.dart';
import 'package:general/src/core/services/room_background_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

enum RoomStateType {
  none,
  livePreview,
  audioActive,
  audioPiP,
  videoActive,
  videoMinimized,
  videoPiP,
}

class RoomEntryRequest {
  final BuildContext context;
  final RoomEntity roomData;
  final bool isLive;
  final bool? isGame;
  final GameDataEntity? gameDataEntity;
  final bool isPasswordVerified;

  RoomEntryRequest({
    required this.context,
    required this.roomData,
    required this.isLive,
    this.isGame,
    this.gameDataEntity,
    this.isPasswordVerified = false,
  });

  int? get roomId => roomData.id;
  int? get ownerId => roomData.ownerId;

  /// Effective live flag: callers historically hardcode `isLive: false`, so the
  /// authoritative signal is the room record's own `is_live`. OR them so a live
  /// room routes to the live screen without touching every call site.
  bool get isLiveRoom => isLive || roomData.streamType == "live";

  bool get hasPassword =>
      !isPasswordVerified &&
      roomData.passwordStatus == true &&
      roomData.ownerId != MyDataModel.getInstance().id;
}

class RoomNavigationResult {
  final bool success;
  final String? errorMessage;
  final RoomStateType resultingState;

  RoomNavigationResult({
    required this.success,
    this.errorMessage,
    this.resultingState = RoomStateType.none,
  });

  factory RoomNavigationResult.success(RoomStateType state) {
    return RoomNavigationResult(success: true, resultingState: state);
  }

  factory RoomNavigationResult.failure(String message) {
    return RoomNavigationResult(success: false, errorMessage: message);
  }

  factory RoomNavigationResult.sameRoom() {
    return RoomNavigationResult(
      success: true,
      resultingState: RoomStateType.audioActive,
    );
  }
}

class RoomStateManager {
  static final RoomStateManager _instance = RoomStateManager._internal();
  factory RoomStateManager() => _instance;
  RoomStateManager._internal();

  final ValueNotifier<RoomStateType> stateNotifier =
      ValueNotifier(RoomStateType.none);

  final RoomCleanupHelper _cleanupHelper = RoomCleanupHelper();

  int? _currentRoomId;
  bool _isCurrentRoomLive = false;
  Completer<void>? _operationLock;
  Future<void> Function()? _previewTeardownCallback;

  // ========== Live Preview Management ==========

  void registerPreviewEngine(Future<void> Function() teardown) {
    _previewTeardownCallback = teardown;
    stateNotifier.value = RoomStateType.livePreview;
  }

  void unregisterPreviewEngine() {
    _previewTeardownCallback = null;
    if (stateNotifier.value == RoomStateType.livePreview) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (stateNotifier.value == RoomStateType.livePreview) {
          stateNotifier.value = RoomStateType.none;
        }
      });
    }
  }

  bool get isPreviewActive => stateNotifier.value == RoomStateType.livePreview;

  Future<void> teardownPreviewIfActive() async {
    if (_previewTeardownCallback != null) {
      final callback = _previewTeardownCallback!;
      _previewTeardownCallback = null;
      if (stateNotifier.value == RoomStateType.livePreview) {
        stateNotifier.value = RoomStateType.none;
      }
      await callback();
    }
  }

  // ========== Getters ==========

  RoomStateType get currentState => stateNotifier.value;

  bool get isInRoom =>
      stateNotifier.value != RoomStateType.none &&
      stateNotifier.value != RoomStateType.livePreview;

  bool get isMinimized =>
      stateNotifier.value == RoomStateType.videoMinimized;

  bool get isActive =>
      stateNotifier.value == RoomStateType.audioActive ||
      stateNotifier.value == RoomStateType.videoActive;

  bool get isInPiP =>
      stateNotifier.value == RoomStateType.audioPiP ||
      stateNotifier.value == RoomStateType.videoPiP;

  bool get isInAudioRoom =>
      stateNotifier.value == RoomStateType.audioActive ||
      stateNotifier.value == RoomStateType.audioPiP;

  bool get isInVideoRoom =>
      stateNotifier.value == RoomStateType.videoActive ||
      stateNotifier.value == RoomStateType.videoMinimized ||
      stateNotifier.value == RoomStateType.videoPiP;

  int? get currentRoomId => _currentRoomId;

  bool get isOperationInProgress =>
      _operationLock != null && !_operationLock!.isCompleted;

  // ========== Main Navigation ==========

  Future<RoomNavigationResult> navigateToRoom(RoomEntryRequest request) async {
    log('[RoomStateManager] navigateToRoom called for room ${request.roomId}',
        name: 'room_nav');

    if (!HomePage.isConnectToInternet) {
      final message = StringManager.unableToConnect.tr();
      _showError(request.context, message);
      return RoomNavigationResult.failure(message);
    }

    // Ban/kick re-entry is enforced ENTIRELY by the UTD-Stream engine: a banned
    // user's token request returns 403 on (re)join and the kit surfaces it via
    // its banned dialog, then leaves cleanly. No client-side pre-check (which
    // would otherwise wrongly keep blocking after an admin unban).

    // Instant tap feedback — BEFORE the silent operation-lock wait below,
    // which can hold the tap with zero UI for seconds. (Password entries get
    // their dialog instead of a loading toast.)
    JoinTimeline.start('${request.roomId}');
    if (!request.hasPassword) {
      Methods.showToast(request.context, isLoading: true);
    }

    await _waitForOperationComplete();
    _operationLock = Completer<void>();

    try {
      if (request.hasPassword) {
        _releaseOperationLock();
        _showPasswordDialog(request);
        return RoomNavigationResult.success(RoomStateType.none);
      }

      return await _processRoomNavigation(request);
    } catch (e, s) {
      log('[RoomStateManager] Error in navigateToRoom: $e\n$s',
          name: 'room_nav');
      _releaseOperationLock();
      return RoomNavigationResult.failure(e.toString());
    }
  }

  Future<RoomNavigationResult> _processRoomNavigation(
      RoomEntryRequest request) async {
    if (isInPiP) {
      _releaseOperationLock();
      return RoomNavigationResult.failure(
          'Cannot switch rooms while in PiP mode');
    }

    final isSameRoom = _currentRoomId?.toString() == request.roomId?.toString();

    if (isInRoom && isSameRoom) {
      return await _handleSameRoomNavigation(request);
    }

    if (isInRoom && !isSameRoom) {
      return await _handleRoomSwitch(request);
    }

    return await _enterRoom(request);
  }

  Future<RoomNavigationResult> _handleSameRoomNavigation(
      RoomEntryRequest request) async {
    // Video minimize — handled by RoomStateManager
    if (isMinimized) {
      await _restoreFromMinimize(_isCurrentRoomLive);
      _releaseOperationLock();
      return RoomNavigationResult.success(RoomStateType.videoActive);
    }

    // Audio minimize — handled by the audio UTD package's minimize controller.
    final utdMinimized =
        RoomData.instance.utdController?.minimize.isMinimizing ?? false;
    if (utdMinimized) {
      RoomData.instance.utdController?.minimize.restoreWithNavigator();
      _releaseOperationLock();
      return RoomNavigationResult.success(RoomStateType.audioActive);
    }

    // Live minimize — handled by the live kit's own minimize controller (its
    // own state machine, separate from the audio one above). Re-entering the
    // same minimized live room (e.g. from the home/exit-panel list) restores it.
    final liveMinimized =
        LiveRoomData.instance.liveController?.minimize.isMinimizing ?? false;
    if (liveMinimized) {
      LiveRoomData.instance.liveController?.minimize.restoreWithNavigator();
      _releaseOperationLock();
      return RoomNavigationResult.success(RoomStateType.videoActive);
    }

    _releaseOperationLock();
    return RoomNavigationResult.sameRoom();
  }

  Future<RoomNavigationResult> _handleRoomSwitch(
      RoomEntryRequest request) async {
    final ctx = navKey.currentState?.context;
    if (ctx == null) {
      _releaseOperationLock();
      return RoomNavigationResult.failure('No valid context');
    }

    final oldRoomId = _currentRoomId ?? 0;
    final oldController = RoomData.instance.utdController;

    // Immediately dismiss any minimize widgets before cleanup
    stateNotifier.value = RoomStateType.none;
    if (oldController?.minimize.isMinimizing ?? false) {
      oldController!.minimize.dismiss();
    }

    // Pre-cleanup (marks exit, stops RTM, clears gifts). The lucky-gift end
    // call is network-bound and is deferred on the switch path — the state
    // resets inside preCleanup still run synchronously before the new entry.
    await _cleanupHelper.preCleanup(deferLuckyGiftEnd: true);

    // Critical cleanup (Firebase, legacy realtime, room data reset) — must complete
    await _cleanupHelper.runCriticalCleanup(oldRoomId);
    RoomData.instance.completeExitRoom();

    // Leave old room before entering new one so the server clears the seat.
    // Leave via whichever controller is active; live teardown runs right after.
    try {
      await oldController?.leave();
    } catch (e) {
      log('[RoomStateManager] Old room teardown error: $e', name: 'room_nav');
    }
    await _teardownLiveController();

    // Non-critical BLoC resets can run in the background
    _cleanupHelper.runDeferredCleanup();

    return await _enterRoom(request);
  }

  Future<RoomNavigationResult> _enterRoom(RoomEntryRequest request) async {
    try {
      await teardownPreviewIfActive();

      final ctx = navKey.currentState?.context;
      if (ctx == null) {
        _releaseOperationLock();
        return RoomNavigationResult.failure('No valid context');
      }

      LuckyGiftSoundManager.instance.initialize();
      _prepareRoomData(request);

      // Tap-time enter_room dispatch: the network round-trip overlaps the
      // ~300ms route transition, so admins are usually known by token time
      // (fewer role upgrades) and the room data lands sooner. The room
      // screen's setup consumes the flag and skips its duplicate dispatch.
      // Password-verified entries are excluded: their enter_room already ran
      // with the password (re-sending with "" would be rejected) and the
      // screen keeps its EmitCachedRoomDataEvent path.
      if (!request.isPasswordVerified) {
        RoomData.instance.markEnterRoomDispatchedAtTap();
        JoinTimeline.mark('enterRoomReq');
        di<RoomHandlerBloc>().add(
          EnterRoomEvent(
            ctx,
            isVip: MyDataModel.getInstance().vip1?.level ?? 0,
            roomId: request.roomData.id.toString(),
            roomPassword: "",
          ),
        );
      }

      _navigateToRoomScreen(request);
      JoinTimeline.mark('navigate');

      _currentRoomId = request.roomId;
      _isCurrentRoomLive = request.isLiveRoom;
      stateNotifier.value = request.isLiveRoom
          ? RoomStateType.videoActive
          : RoomStateType.audioActive;

      // Start native keep-alive + persist credentials so app-kill cleanup
      // (quit_room) and background audio work. Best-effort; never blocks entry.
      RoomBackgroundService.start(
        roomId: (request.roomId ?? 0).toString(),
        isLive: request.isLiveRoom,
      );

      // Keep the screen awake while inside a room. Best-effort; never blocks entry.
      try {
        WakelockPlus.enable();
      } catch (e) {
        log('[RoomStateManager] Wakelock enable failed: $e', name: 'room_nav');
      }

      _releaseOperationLock();
      return RoomNavigationResult.success(stateNotifier.value);
    } catch (e, s) {
      log('[RoomStateManager] Error entering room: $e\n$s', name: 'room_nav');
      _resetState();
      _releaseOperationLock();
      return RoomNavigationResult.failure(e.toString());
    }
  }

  // ========== Exit ==========

  Future<void> exitRoom(
    BuildContext context, {
    VoidCallback? callback,
  }) async {
    if (_currentRoomId == null) {
      callback?.call();
      return;
    }

    await _waitForOperationComplete();
    _operationLock = Completer<void>();

    try {
      final roomId = _currentRoomId ?? 0;

      // Read ownership BEFORE any cleanup: runCriticalCleanup replaces
      // RoomData.instance.room with an empty model, so after it there is no way
      // left to tell whether this user was the host.
      final isHost =
          RoomData.instance.room.ownerId == MyDataModel.getInstance().id;

      // Same reason: the participant list is only available before
      // runCriticalCleanup tears the controller down. `.participants`
      // includes the local participant, so >1 means someone besides the
      // host currently exiting is still in the room. Only one of the two
      // controllers is ever set, matching whichever room type this is.
      final participantCount = RoomData.instance.utdController?.participants
              .length ??
          LiveRoomData.instance.liveController?.participants.length ??
          1;
      final hasOtherParticipants = participantCount > 1;

      // Stop native keep-alive + clear persisted credentials so a clean in-app
      // exit does not leave stale data for the app-kill cleanup to re-fire.
      RoomBackgroundService.stop();

      // Release the screen wakelock on room exit. Best-effort; never throws.
      try {
        WakelockPlus.disable();
      } catch (e) {
        log('[RoomStateManager] Wakelock disable failed: $e', name: 'room_nav');
      }

      await _cleanupHelper.preCleanup();

      await _cleanupHelper.cleanupAudio();
      await _teardownLiveController();

      await _cleanupHelper.runCriticalCleanup(roomId);
      _cleanupHelper.runDeferredCleanup();
      RoomData.instance.completeExitRoom();

      _resetState();
      _releaseOperationLock();
      callback?.call();

      // The host leaving used to always end the session for everyone. On
      // request, that now only happens when the host was the last one in the
      // room: if others are still there, they keep chatting/seated and are
      // not kicked or auto-muted — the room simply has no host until someone
      // reclaims it (no auto-transfer). If the host was alone, ending it is
      // unchanged: the room was only left, never closed, so it kept its
      // seats, its visitors and its place in the feed, and reopening it
      // dropped the host back into the previous session's state.
      if (isHost && roomId != 0 && !hasOtherParticipants) {
        await _endHostSession(context, roomId);
      }
    } catch (e) {
      log('[RoomStateManager] Error in exitRoom: $e', name: 'room_nav');
      _releaseOperationLock();
    }
  }

  /// Close the session server-side and show the host what it was worth.
  ///
  /// Runs after the room has already been torn down locally and the navigation
  /// has popped, so nothing here can delay the host getting out. Failures are
  /// swallowed for the same reason — a summary is a nice-to-have, and the exit
  /// itself has already happened.
  Future<void> _endHostSession(BuildContext context, int roomId) async {
    try {
      final summary = await RoomRemoteDataSourceImp(di())
          .endLive(roomId: roomId.toString());

      if (summary == null) return;

      final navContext = SafeNavigator.context;
      if (navContext == null || !navContext.mounted) return;

      await SessionSummaryDialog.show(navContext, summary);
    } catch (e) {
      log('[RoomStateManager] endLive failed: $e', name: 'room_nav');
    }
  }

  // ========== Minimize/Restore ==========

  void minimizeRoom() {
    if (!isActive) return;

    if (isInVideoRoom) {
      stateNotifier.value = RoomStateType.videoMinimized;
    }
  }

  Future<void> _restoreFromMinimize(bool isLive) async {
    // Video live is removed: the video-minimize state is never entered, so
    // there is nothing to restore. Kept as a safe no-op to clear stale state.
    if (stateNotifier.value == RoomStateType.videoMinimized) {
      stateNotifier.value = RoomStateType.none;
    }
  }


  // ========== Helpers ==========

  void _showPasswordDialog(RoomEntryRequest request) {
    showDialog(
      context: request.context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 30),
        child: EnterRoomPasswordScreen(
          roomId: request.roomData.id.toString(),
          isLive: request.isLive,
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    Methods.showToast(context, isError: true, message: message);
  }

  void _prepareRoomData(RoomEntryRequest request) {
    final roomData = request.roomData;
    final cachedData = Methods.fetchRoom(id: roomData.id.toString());

    RoomData.instance.room = cachedData.isNotEmpty
        ? EnterRoomModel(
            ownerId: cachedData['ownerId'],
            id: cachedData['id'],
            roomName: cachedData['name'],
            roomCover: cachedData['cover'],
            roomBackground: cachedData['background'],
            mode: cachedData['mode'],
            roomIntro: cachedData['roomIntro'],
            uuidOwnerRoom: cachedData['uuid'],
            giftPrice: cachedData['gift_price'],
            ownerSpecialId: cachedData['ownerSpecialId'],
            roomRule: cachedData['roomRule'] ?? "",
            roomLevelImage: cachedData['roomLevelImage'] ?? "",
            luckyGiftCoins: cachedData['luckyGiftCoins'] ?? "0",
            ownerImageColor:
                ImageColorEntity(color: cachedData['ownerIdColors']),
          )
        : EnterRoomModel(
            ownerId: roomData.ownerId,
            id: roomData.id,
            roomIntro: roomData.roomIntro,
            roomName: roomData.name,
            roomCover: roomData.cover,
            roomRule: roomData.roomRule ?? "",
            roomBackground: roomData.roomBackground,
            mode: roomData.mode,
            giftPrice: roomData.giftPrice,
            ownerSpecialId: roomData.ownerSpecialId,
            uuidOwnerRoom: roomData.uuidOwnerRoom,
            ownerImageColor: roomData.ownerImageColor,
            roomLevelImage: roomData.roomLevelImage,
            luckyGiftCoins: roomData.luckyGiftCoins,
          );
  }

  void _navigateToRoomScreen(RoomEntryRequest request) {
    final context = navKey.currentState?.context;
    if (context == null) return;
    Navigator.pushNamed(
      context,
      request.isLiveRoom ? Routes.liveRoomScreen : Routes.roomScreen,
      arguments: RoomParameter(
        roomId: request.roomData.id.toString(),
        ownerId: request.roomData.ownerId.toString(),
        myDataModel: MyDataModel.getInstance(),
        isLocked: request.isPasswordVerified,
        isHost: MyDataModel.getInstance().id == request.roomData.ownerId,
        isGame: request.isGame,
        gameDataEntity: request.gameDataEntity,
        specialIdImage: MyDataModel.getInstance().id == request.roomData.ownerId
            ? MyDataModel.getInstance().specialIdImage
            : request.roomData.ownerSpecialId,
        imageColorEntity:
            MyDataModel.getInstance().id == request.roomData.ownerId
                ? MyDataModel.getInstance().imageColorEntity
                : request.roomData.ownerImageColor,
      ),
    );
  }

  void _resetState() {
    _currentRoomId = null;
    _isCurrentRoomLive = false;
    stateNotifier.value = RoomStateType.none;
  }

  /// Disconnects + clears the live room state ([LiveRoomData]). The live screen's
  /// own exit goes through exitRoom() too, so this is the single teardown path;
  /// idempotent so room-switch / minimize-close / force-exit that bypass the
  /// screen still tear it down.
  Future<void> _teardownLiveController() async {
    final c = LiveRoomData.instance.liveController;
    if (c == null) return;
    try {
      if (c.minimize.isMinimizing) c.minimize.dismiss();
      await c.leave();
    } catch (e) {
      log('[RoomStateManager] Live controller teardown error: $e',
          name: 'room_nav');
    }
    // Cancels live RTM subscriptions + nulls the controller.
    LiveRoomData.instance.reset();
  }

  Future<void> _waitForOperationComplete() async {
    if (_operationLock != null && !_operationLock!.isCompleted) {
      await _operationLock!.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          _releaseOperationLock();
        },
      );
    }

    await RoomData.instance.waitForExitRoomComplete();
  }

  void _releaseOperationLock() {
    if (_operationLock != null && !_operationLock!.isCompleted) {
      _operationLock!.complete();
    }
  }

  // ========== Video Room State Callbacks ==========

  void onVideoRoomMinimized() {
    if (stateNotifier.value == RoomStateType.videoActive) {
      stateNotifier.value = RoomStateType.videoMinimized;
    }
  }

  void onVideoRoomRestored() {
    if (stateNotifier.value == RoomStateType.videoMinimized) {
      stateNotifier.value = RoomStateType.videoActive;
    }
  }

  // ========== PiP State ==========

  void onPiPEntered() {
    if (stateNotifier.value == RoomStateType.audioActive) {
      stateNotifier.value = RoomStateType.audioPiP;
    } else if (stateNotifier.value == RoomStateType.videoActive) {
      stateNotifier.value = RoomStateType.videoPiP;
    }
  }

  void onPiPExited() {
    if (stateNotifier.value == RoomStateType.audioPiP) {
      stateNotifier.value = RoomStateType.audioActive;
    } else if (stateNotifier.value == RoomStateType.videoPiP) {
      stateNotifier.value = RoomStateType.videoActive;
    }
  }

  /// For video rooms that bypass navigateToRoom().
  void onRoomEntered(int roomId, bool isLive) {
    _currentRoomId = roomId;
    _isCurrentRoomLive = isLive;
    stateNotifier.value =
        isLive ? RoomStateType.videoActive : RoomStateType.audioActive;
  }

  void onRoomExited() {
    _resetState();
  }
}
