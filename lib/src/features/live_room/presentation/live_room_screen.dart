import 'dart:io';

import 'package:general/src/features/live_room/presentation/live_stage_mode.dart';

import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/live_room/presentation/component/messages/live_tabbed_messages_view.dart';
import 'package:general/src/features/live_room/presentation/live_room_data.dart';
import 'package:general/src/features/live_room/presentation/widgets/live_controls_bar.dart';
import 'package:general/src/features/live_room/presentation/widgets/live_foreground_widget.dart';
import 'package:general/src/features/live_room/presentation/widgets/live_gift_button.dart';
import 'package:general/src/features/live_room/presentation/widgets/live_room_header.dart';
import 'package:utd_video_effects_kit/utd_video_effects_kit.dart';
import 'package:general/src/features/live_room/presentation/taps/live_taps_controller.dart';
import 'package:general/src/features/live_room/presentation/taps/live_tap_hearts_overlay.dart';
import 'package:general/src/features/room/presentation/component/room_header/exit_room/exit_side_panel_overlay.dart';
import 'package:general/src/features/live_room/presentation/widgets/live_end_confirm_dialog.dart';
import 'package:general/src/features/room/room.dart';
import 'package:general/src/core/realtime/realtime_config.dart';
import 'package:utd_live_room_kit/utd_live_room_kit.dart' as live;

/// Hosts the video live room ([live.UTDLiveRoom]).
///
/// Mirrors the audio [RoomScreen]'s controller wiring (navigatorKey,
/// minimize.configure(enableOSPip), onForceExit / onConnectError → exitRoom +
/// popUntil) but for the live kit. The live kit is imported with an `as live`
/// prefix because the audio kit is exported app-wide (`room.dart`) and both
/// export same-named symbols.
class LiveRoomScreen extends StatefulWidget {
  final MyDataModel userModel;
  final String roomId;
  final String ownerId;
  final bool isHost;
  final bool isLocked;

  const LiveRoomScreen({
    super.key,
    required this.userModel,
    required this.roomId,
    required this.ownerId,
    required this.isHost,
    this.isLocked = false,
  });

  @override
  State<LiveRoomScreen> createState() => _LiveRoomScreenState();
}

class _LiveRoomScreenState extends State<LiveRoomScreen>
    with WidgetsBindingObserver {
  /// The host identity (room owner) — drives the full-bleed host tile and the
  /// host-video-only mini-overlay / PiP.
  String get _hostId =>
      (widget.ownerId.isNotEmpty && widget.ownerId != '0')
          ? widget.ownerId
          : (LiveRoomData.instance.roomOrNull?.ownerId?.toString() ?? '');

  /// Whether the HOST is currently backgrounded mid-broadcast (went to
  /// WhatsApp etc.) — used to pair the away/back system messages and the
  /// camera-off safety state.
  bool _hostAway = false;

  /// Camera state at the moment the host stepped out — restored on return so
  /// a host who had the camera OFF doesn't get it forced back on.
  bool _cameraWasOnBeforeAway = false;

  /// Guards the UTD Stream "service unavailable" notice so it is shown only
  /// once even if onConnectError fires repeatedly during connect/token retries.
  bool _streamNoticeShown = false;

  /// Host stepping out of the app mid-broadcast: tell the room (system chat
  /// line) and switch the camera off — viewers see the camera-closed tile
  /// instead of a frozen frame — then announce the return and switch the
  /// camera back on. Safety + transparency per owner spec.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = LiveRoomData.instance.liveController;
    if (controller == null) return;
    final isHost =
        widget.isHost || MyDataModel.getInstance().id.toString() == _hostId;
    // Only mid-broadcast (the pre-live composer or a viewer doesn't announce).
    if (!isHost || controller.mediaController.liveStartedAt.value == null) {
      return;
    }

    final me = MyDataModel.getInstance();
    final userData = {
      "img": me.profile?.image ?? "",
      "senderId": me.id?.toString() ?? "",
      "senderName": me.name ?? "",
      'type': 'message',
    };

    if (state == AppLifecycleState.paused && !_hostAway) {
      _hostAway = true;
      _cameraWasOnBeforeAway = controller.mediaController.isCameraEnabled.value;
      LiveRoomData.instance.chatController?.sendMessage(
        "${me.name ?? ''} hostAwayLive",
        userData: userData,
      );
      if (_cameraWasOnBeforeAway) {
        controller.mediaController.setCameraEnabled(false);
      }
    } else if (state == AppLifecycleState.resumed && _hostAway) {
      _hostAway = false;
      LiveRoomData.instance.chatController?.sendMessage(
        "${me.name ?? ''} hostBackLive",
        userData: userData,
      );
      // Restore, don't force: only reopen the camera if it was on when the
      // host stepped out (owner report 2026-06-11).
      if (_cameraWasOnBeforeAway) {
        controller.mediaController.setCameraEnabled(true);
      }
    }
  }

  /// Pop back to wherever the user came from once the room is torn down:
  /// the lives page if the live was opened from it, else the layout/home.
  /// exitRoom() only tears down state — it never navigates — so the screen
  /// pops itself.
  void _popToLayout() {
    final popCtx = navKey.currentContext;
    if (popCtx != null) {
      Navigator.popUntil(
        popCtx,
        (route) =>
            route.settings.name == Routes.livesPage ||
            route.settings.name == Routes.layout,
      );
    }
  }

  Future<void> _showExitDialog() async {
    final dialogCtx = navKey.currentState?.context ?? context;
    // The host ends the stream via an explicit confirmation dialog; viewers
    // get the exit side-panel (other live streams + exit action) — ExitPanel
    // hides the audio-only minimize action inside a live room and runs the
    // full exit flow itself.
    final isHost =
        widget.isHost || MyDataModel.getInstance().id.toString() == _hostId;
    if (isHost) return showEndLiveConfirmDialog(dialogCtx);
    return ExitSidePanelOverlay.show(dialogCtx);
  }

  Future<void> _forceExit() async {
    final ctx = navKey.currentContext;
    if (ctx == null) return;
    Methods.showToast(
      ctx,
      message: StringManager.unableToConnect.tr(),
      isError: true,
    );
    await di<RoomStateManager>().exitRoom(ctx);
    _popToLayout();
  }

  /// Pre-live close (the composer's X): tear down and leave without the toast
  /// or the exit side-panel — the host never actually went live.
  Future<void> _forceExitSilently() async {
    final ctx = navKey.currentContext;
    if (ctx == null) return;
    await di<RoomStateManager>().exitRoom(ctx);
    _popToLayout();
  }

  void _enterRoom() {
    // Skip the duplicate dispatch when RoomStateManager already dispatched
    // enter_room at tap time (pre-push). Re-dispatch only if that request
    // already failed, so the error reaches this screen's listeners.
    final dispatchedAtTap = RoomData.instance.takeEnterRoomDispatchedAtTap();
    if (dispatchedAtTap &&
        di<RoomHandlerBloc>().state is! EnterRoomErrorMessageState) {
      return;
    }
    di<RoomHandlerBloc>().add(
      EnterRoomEvent(
        isVip: 0,
        // Use the screen's own roomId, not LiveRoomData.room — `room` is only
        // set AFTER this enter-room call succeeds, so reading it here would
        // throw on the first live-room entry (the singleton isn't loaded yet).
        roomId: widget.roomId,
        roomPassword: "",
        context,
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _seedStageCapacity();
    _enterRoom();
    super.initState();
  }

  /// Publish the broadcast's guest capacity BEFORE the kit connects.
  ///
  /// The kit reads `maxGuestTiles` once, at connect, to size its seat list
  /// (`initSeats(maxGuestTiles + 1)`). The enter-room RESPONSE has not landed
  /// by then, so waiting for it produced `initSeats(1)` — one host seat, no
  /// guest slots — and a 7-seat broadcast rendered as a flat solo live.
  ///
  /// The stub RoomStateManager puts in place at TAP time already carries
  /// `mode` (it comes from the rooms list), which is exactly what is needed
  /// and is available this early.
  void _seedStageCapacity() {
    final mode = RoomData.instance.roomOrNull?.mode;
    if (mode == null) return;

    LiveRoomData.instance.stageGuestTiles.value =
        LiveStageMode.fromRoomMode(mode).guestTiles;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// The room engine host. Never null, and never a host we do not own.
  ///
  /// `rtc_engine_url` arrives from `/config/settings`, which can still be in
  /// flight when this screen builds — and the kit's own constants point at the
  /// RETIRED vendor (`udt-stream.com`). Falling back to them meant the token
  /// POST went to a host that answers 404, the kit retried behind its backoff,
  /// and the room sat on a spinner for minutes before any seat appeared. That is
  /// the "party room seat load 20 min" report, and it is not slowness: it is a
  /// request to the wrong company.
  ///
  /// Our engine is served by our own API host, so `EndPoints.domainURL` is
  /// always the right answer when the server-driven value has not landed yet.
  ///
  /// Trailing slashes are stripped: the kit appends absolute paths, and a base
  /// ending in `/` yields a double slash some proxies 404 rather than normalise.
  String get _engineBaseUrl {
    final url = RealtimeConfig.rtcEngineUrl.trim();
    final base = url.isEmpty ? EndPoints.domainURL : url;

    return base.endsWith('/') ? base.substring(0, base.length - 1) : base;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _showExitDialog();
      },
      // The kit takes its guest capacity as a plain constructor value, so the
      // whole thing has to rebuild when the host switches broadcast shape —
      // otherwise "3 Seats" is chosen and the stage keeps the capacity it was
      // first built with.
      child: ValueListenableBuilder<int>(
        valueListenable: LiveRoomData.instance.stageGuestTiles,
        builder:
            (context, guestTiles, _) => live.UTDLiveRoom(
              // Same UTD Stream credentials as the audio room (X-App-Id/Secret).
              // Server-driven via /config/settings; the build-time default is only the
              // cold-start fallback (prod by default, test-overridable via dart-define).
              appId:
                  RealtimeConfig.utdStreamAppId ??
                  RealtimeConfig.defaultUtdStreamAppId,
              appKey:
                  RealtimeConfig.utdStreamAppKey ??
                  RealtimeConfig.defaultUtdStreamAppKey,
              // Which engine serves this live room. One host for both the token and
              // the in-room stage calls — the vendor split them across two edges, we
              // do not. Empty leaves the kit on its own defaults, so a deployment that
              // has not set `rtc_engine_url` behaves exactly as before.
              baseUrl: _engineBaseUrl,
              engineBaseUrl: _engineBaseUrl,
              // Reuse the live controller only while it is still connected
              // (minimize/PiP restore). A leftover disposed controller is non-null but
              // not connected; the kit reuses any non-null controller and connect()
              // then touches a disposed ValueNotifier → red crash. Null forces a fresh
              // controller per entry.
              controller:
                  (LiveRoomData.instance.liveController?.isConnected ?? false)
                      ? LiveRoomData.instance.liveController
                      : null,
              userId: widget.userModel.id.toString(),
              userName: widget.userModel.name ?? widget.userModel.id.toString(),
              roomId: widget.roomId,
              roomOwnerId: _hostId,
              // Admins aren't known until the enter-room response sets `room`, which
              // happens after this build. Seed what we have, and give the kit an
              // async resolver so the TOKEN step waits for the backend admin list —
              // an admin must join with an `admin` token (the engine enforces
              // token-baked permissions; post-connect seeding doesn't grant them).
              adminIds:
                  (LiveRoomData.instance.roomOrNull?.admins ?? const <String>[])
                      .map((e) => e.toString())
                      .toSet(),
              adminIdsResolver:
                  () async =>
                      (await LiveRoomData.instance.adminsWhenLoaded)
                          .map((e) => e.toString())
                          .toSet(),
              // Sync probe at token time: enter_room fires at TAP (pre-push), so
              // its response often lands during the route transition — then the
              // join uses an `admin` token directly, no upgrade round-trip.
              adminIdsNow:
                  () =>
                      (LiveRoomData.instance.roomOrNull?.admins ??
                              const <String>[])
                          .map((e) => e.toString())
                          .toSet(),
              onControllerReady: (controller) {
                controller.navigatorKey = navKey;
                // In-app minimize → a draggable floating mini-window showing the host's
                // live video (PiP-style) while the broadcast stays connected. OS-level
                // PiP stays off; the in-app overlay is the picture-in-picture surface.
                // `onClose` is also the kit→app teardown callback used by the ban /
                // force-exit / live-ended funnels (not just the mini-window's leave).
                controller.minimize.configure(
                  live.UTDMinimizeConfig(
                    enableOSPip: false,
                    hostIdentity: _hostId,
                    showHostVideoInMini: true,
                    roomImage: EndPoints.getImage(
                      LiveRoomData.instance.roomOrNull?.roomCover,
                    ),
                    onClose: () {
                      final c = navKey.currentContext;
                      if (c != null) di<RoomStateManager>().exitRoom(c);
                    },
                  ),
                );
                LiveRoomData.instance.liveController = controller;
                // Per-stage guest gift counters (المسّات) follow seat occupancy.
                LiveRoomData.instance.watchGuestSeats(controller);
                controller.onForceExit = _forceExit;
              },
              onConnectError: (error, stackTrace) async {
                // Room/live ENTRY is NOT tied to UTD Stream: the enter_room REST has
                // already succeeded, so the user STAYS in the room. UTD Stream only
                // powers audio/video and realtime broadcast — those won't work
                // without it, which is acceptable. Browsing and gift/lucky-gift
                // sending (app REST) keep working. The kit's reconnection force-exit
                // timer only ARMS after a SUCCESSFUL connect, so when connect never
                // succeeds, staying here will NOT auto-exit later. Show a small
                // non-blocking notice ONCE — do NOT _forceExit / exitRoom / pop.
                if (_streamNoticeShown) return;
                _streamNoticeShown = true;
                final ctx = navKey.currentContext;
                if (ctx == null) return;
                Methods.showToast(
                  ctx,
                  message: StringManager.liveServiceUnavailable.tr(),
                  isError: false,
                );
              },
              config: live.UTDLiveRoomConfig(
                // Guest tiles the host chose before going live. The kit sends no
                // capacity at token time, so the room row is the shared source of
                // truth that both this gate and the engine read from — surfaced here
                // as LiveRoomData.stageGuestTiles, which the ValueListenableBuilder
                // around this widget rebuilds on.
                maxGuestTiles: guestTiles,
                // Brand the kit's built-in chrome (Go Live button, accents, links)
                // with the app theme instead of the kit's default purple.
                // NOT const: ColorManager.primary is set per app flavor at runtime.
                theme: live.UTDRoomTheme(primary: ColorManager.primary),
                // Guest tile footer: the guest's name (tap → profile) + the gift
                // value they received during THIS stage stint (resets on leave).
                guestTileFooterBuilder:
                    (ctx, identity) => _GuestTileFooter(identity: identity),
                // The app renders its own TikTok-style pre-live composer.
                showGoLiveButton: false,
                // TikTok-style tap-hearts: taps on the empty stage area.
                onStageTap: () => LiveTapsController.instance.onLocalTap(),
                // Attach the session's video-effects processor to every local camera
                // capture (preview, go-live, switch, reconnect). The factory returns
                // the SAME instance owned by LiveRoomData so the beauty sheet can drive
                // it. null-safe: with no native pipeline yet it is a passthrough.
                buildVideoProcessor:
                    (entitled) => LiveRoomData.instance.ensureVideoEffects(
                      entitled: entitled,
                    ),
                strings:
                    Methods.getLang() == 'ar'
                        ? live.UTDRoomStrings.ar()
                        : live.UTDRoomStrings.en(),
                userInRoomAttributes: {
                  'fr': widget.userModel.frame ?? '',
                  'avatar': EndPoints.getImage(widget.userModel.profile?.image),
                  'frt': widget.userModel.frameType ?? '',
                  'cn': widget.userModel.vip1?.colorName ?? '',
                },
                // Live-room's own chrome. For the HOST before "Go Live" the screen is
                // a clean TikTok-style composer: camera + title field + beauty/flip
                // only — no chat, no gifts, no room chrome. Everything appears the
                // moment the broadcast starts.
                headerWidget: _HostPreLiveGate(
                  isHost: widget.isHost,
                  builder:
                      (preLive) =>
                          preLive
                              ? _PreLiveHeader(onClose: _forceExitSilently)
                              : const LiveRoomHeader(),
                ),
                controlsBarWidget: _HostPreLiveGate(
                  isHost: widget.isHost,
                  builder:
                      (preLive) =>
                          preLive
                              ? const _PreLiveBar()
                              : const LiveControlsBar(),
                ),
                // Live-room's own tabbed in-room chat list (All / Chat / Games / Gift),
                // forked from the audio room and bound to the live chat channel.
                messagesWidget: _HostPreLiveGate(
                  isHost: widget.isHost,
                  builder:
                      (preLive) =>
                          preLive
                              ? const SizedBox.shrink()
                              : const LiveTabbedMessagesView(),
                ),
                // Live-only overlay (gift / lucky-gift / entry / super-boom + side
                // column). Drives entry + RTM off the live controller's connection.
                // Pre-live it stays MOUNTED (Offstage) — its listeners capture the
                // enter-room response — while the title composer renders on top.
                foregroundWidget: _HostPreLiveGate(
                  isHost: widget.isHost,
                  builder: (preLive) {
                    final foreground = LiveForegroundWidget(
                      roomId: widget.roomId,
                      userId: widget.userModel.id.toString(),
                      isHost: widget.isHost,
                      // Lucky-box gift trigger uses the same on-stage recipients
                      // (host + live guests) as the bottom-bar gift button.
                      giftButtonCallBack: () => openLiveGiftScreen(context),
                    );
                    if (!preLive) {
                      // Tap-hearts float ABOVE the chrome but never block touches.
                      return Stack(
                        children: [foreground, const LiveTapHeartsOverlay()],
                      );
                    }
                    return Stack(
                      children: [
                        Offstage(child: foreground),
                        _PreLiveTitleComposer(roomId: widget.roomId),
                      ],
                    );
                  },
                ),
              ),
            ),
      ),
    );
  }
}

/// Bottom overlay on each guest tile: the guest's name (tapping it opens
/// their in-room profile) and the gift value (المسّات) they received during
/// this stage stint — resets when they leave the stage (see
/// [LiveRoomData.watchGuestSeats]).
class _GuestTileFooter extends StatelessWidget {
  final String identity;

  const _GuestTileFooter({required this.identity});

  String _nameOf(live.UTDRoomController? c) {
    if (c == null) return '';
    for (final p in c.participants) {
      if (p.id == identity) return p.name;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final controller = LiveRoomData.instance.liveController;
    final name = _nameOf(controller);
    return GestureDetector(
      onTap: () {
        final room = LiveRoomData.instance.roomOrNull;
        if (room == null) return;
        bottomDailog(
          context: navKey.currentState?.context ?? context,
          widget: UserRoomProfile(userId: identity, roomData: room),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black87],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (name.isNotEmpty)
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodySmall.w600
                    .colorExt(Colors.white)
                    .copyWith(fontSize: 10.sp),
              ),
            ValueListenableBuilder<Map<String, int>>(
              valueListenable: LiveRoomData.instance.guestStageTouches,
              builder:
                  (_, touches, __) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.pinkAccent,
                        size: 10.sp,
                      ),
                      3.wBox,
                      Text(
                        '${touches[identity] ?? 0}',
                        style: context.bodySmall
                            .colorExt(Colors.white)
                            .copyWith(fontSize: 10.sp),
                      ),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chooses between the host's pre-live composer UI and the full live chrome.
///
/// Pre-live = the local user is the HOST and the broadcast hasn't started
/// ([UTDMediaController.liveStartedAt] still null). Audience members always get
/// the full chrome (their liveStartedAt never flips — it is host-local state).
class _HostPreLiveGate extends StatelessWidget {
  final bool isHost;
  final Widget Function(bool preLive) builder;

  const _HostPreLiveGate({required this.isHost, required this.builder});

  @override
  Widget build(BuildContext context) {
    if (!isHost) return builder(false);
    return ValueListenableBuilder<live.UTDRoomController?>(
      valueListenable: LiveRoomData.instance.liveControllerNotifier,
      builder: (_, controller, __) {
        if (controller == null) return builder(true);
        return ValueListenableBuilder<DateTime?>(
          valueListenable: controller.mediaController.liveStartedAt,
          builder: (_, startedAt, __) => builder(startedAt == null),
        );
      },
    );
  }
}

/// Pre-live header: just a close (X) on the start edge.
class _PreLiveHeader extends StatelessWidget {
  final Future<void> Function() onClose;

  const _PreLiveHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingSymmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onClose(),
            child: CircleAvatar(
              radius: 18.r,
              backgroundColor: Colors.black.withValues(alpha: 0.35),
              child: Icon(Icons.close, color: Colors.white, size: 22.sp),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pre-live bottom bar — empty: the TikTok-style composer
/// ([_PreLiveTitleComposer]) renders the tools row, title card and the wide
/// start button itself in the foreground layer.
class _PreLiveBar extends StatelessWidget {
  const _PreLiveBar();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// TikTok-style pre-live tool: plain white icon over the camera with a small
/// label underneath (no circle chip).
class _PreLiveTool extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PreLiveTool({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 28.sp,
            shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
          ),
          6.hBox,
          Text(
            label,
            style: context.bodySmall.colorExt(Colors.white).size(11.5),
          ),
        ],
      ),
    );
  }
}

/// The pre-live title field. Sits above the kit's "Go Live" button; when the
/// host starts the broadcast with an edited title, it is saved to the backing
/// room (fire-and-forget rooms/{owner}/edit, same call the room settings use).
class _PreLiveTitleComposer extends StatefulWidget {
  final String roomId;

  const _PreLiveTitleComposer({required this.roomId});

  @override
  State<_PreLiveTitleComposer> createState() => _PreLiveTitleComposerState();
}

class _PreLiveTitleComposerState extends State<_PreLiveTitleComposer> {
  late final TextEditingController _title;

  /// Broadcast intro (المقدمة) — prefilled from the backing room, edited via
  /// the المقدمة tool, persisted to the room at go-live.
  String _intro = '';

  /// Broadcast cover picked in THIS composer session (the live's own image,
  /// independent of the host's profile picture). Uploaded at go-live.
  File? _pickedCover;

  /// The broadcast shape the host has selected. Seeded from the backing room so
  /// re-opening the composer shows what they chose last time.
  late LiveStageMode _stageMode;

  final ImagePicker _picker = ImagePicker();
  live.UTDRoomController? _attached;
  VoidCallback? _startListener;

  @override
  void initState() {
    super.initState();
    // The host's last live title — intentionally separate from the audio
    // room's name (the backing live room is created silently with a default
    // title, so the host's own wording must survive locally).
    final savedTitle = HiveManager().getData<String>(
      KeysManager.ROOMS_BOX,
      KeysManager.LAST_LIVE_TITLE_KEY,
    );
    _title = TextEditingController(
      text:
          (savedTitle?.trim().isNotEmpty ?? false)
              ? savedTitle!
              : (RoomData.instance.room.roomName ?? ''),
    );
    _intro = RoomData.instance.room.roomIntro ?? '';
    _stageMode = LiveStageMode.fromRoomMode(RoomData.instance.room.mode);
    LiveRoomData.instance.liveControllerNotifier.addListener(_attach);
    _attach();
  }

  void _attach() {
    final c = LiveRoomData.instance.liveController;
    if (c == null || _attached == c) return;
    if (_startListener != null) {
      _attached?.mediaController.liveStartedAt.removeListener(_startListener!);
    }
    _attached = c;
    _startListener = _onLiveStarted;
    c.mediaController.liveStartedAt.addListener(_startListener!);
  }

  void _onLiveStarted() {
    if (_attached?.mediaController.liveStartedAt.value == null) return;
    final title = _title.text.trim();
    if (title.isNotEmpty) {
      // Remember the host's wording for the next broadcast.
      HiveManager().saveData(
        KeysManager.ROOMS_BOX,
        KeysManager.LAST_LIVE_TITLE_KEY,
        title,
      );
    }
    final room = RoomData.instance.room;
    final intro = _intro.trim();
    final titleChanged =
        title.isNotEmpty && title != (room.roomName ?? '').trim();
    final introChanged = intro != (room.roomIntro ?? '').trim();
    if (!titleChanged && !introChanged && _pickedCover == null) return;
    // Same wire shape as the settings editor (rooms/{ownerId}/edit): one call
    // carries the title, intro and the broadcast's own cover image.
    di<UpdateRoomUC>().call(
      ParameterUpdate(
        ownerId: room.ownerId?.toString() ?? '',
        roomId: widget.roomId,
        roomName: titleChanged ? title : null,
        roomIntro: introChanged ? intro : null,
        roomCover: _pickedCover,
        roomVideoType: 'live',
      ),
    );
  }

  Future<void> _pickCover() async {
    final file = await Methods.pickImageSafely(
      _picker,
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;
    setState(() => _pickedCover = File(file.path));
  }

  void _editIntro() {
    final ar = Methods.getLang() == 'ar';
    final controller = TextEditingController(text: _intro);
    showDialog(
      context: context,
      builder:
          (dialogCtx) => AlertDialog(
            backgroundColor: ColorManager.surfaceCardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.r),
            ),
            title: Text(
              ar ? 'مقدمة البث' : 'Broadcast intro',
              style: context.bodyLarge.w700.colorExt(ColorManager.textPrimary),
              textAlign: TextAlign.center,
            ),
            content: TextField(
              controller: controller,
              maxLines: 3,
              maxLength: 150,
              autofocus: true,
              style: context.bodyMedium.colorExt(ColorManager.textPrimary),
              decoration: InputDecoration(
                hintText:
                    ar
                        ? 'مثال: أهلاً وسهلاً بكم، اتفضلوا يا جماعة...'
                        : 'e.g. Welcome everyone, come on in...',
                hintStyle: context.bodySmall.colorExt(
                  ColorManager.secondaryText,
                ),
                counterStyle: context.bodySmall.colorExt(
                  ColorManager.secondaryText,
                ),
                filled: true,
                fillColor: ColorManager.secondaryText.withValues(alpha: 0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text(
                  StringManager.cancel.tr(),
                  style: context.bodyMedium.colorExt(
                    ColorManager.secondaryText,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _intro = controller.text.trim());
                  Navigator.pop(dialogCtx);
                },
                child: Text(
                  StringManager.save.tr(),
                  style: context.bodyMedium.w700.colorExt(ColorManager.primary),
                ),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    LiveRoomData.instance.liveControllerNotifier.removeListener(_attach);
    if (_startListener != null) {
      _attached?.mediaController.liveStartedAt.removeListener(_startListener!);
    }
    _title.dispose();
    super.dispose();
  }

  /// The broadcast's current cover thumbnail inside the title card: the image
  /// picked now, else the room's saved cover, else a camera placeholder.
  Widget _coverThumb() {
    final saved = RoomData.instance.room.roomCover ?? '';
    Widget child;
    if (_pickedCover != null) {
      child = Image.file(
        _pickedCover!,
        width: 52.r,
        height: 52.r,
        fit: BoxFit.cover,
      );
    } else if (saved.isNotEmpty) {
      child = ImageViewWidget(
        url: saved,
        width: 52.r,
        height: 52.r,
        boxFit: BoxFit.cover,
        displayName: _title.text,
      );
    } else {
      child = Container(
        width: 52.r,
        height: 52.r,
        color: Colors.white.withValues(alpha: 0.12),
        child: Icon(Icons.camera_alt, color: Colors.white70, size: 22.sp),
      );
    }
    return GestureDetector(
      onTap: _pickCover,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(10.r), child: child),
          PositionedDirectional(
            bottom: -4,
            end: -4,
            child: Container(
              padding: EdgeInsets.all(3.r),
              decoration: BoxDecoration(
                color: ColorManager.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Icon(Icons.edit, color: Colors.white, size: 10.sp),
            ),
          ),
        ],
      ),
    );
  }

  /// Switch broadcast shape.
  ///
  /// Two things move together, because the client and the engine enforce the
  /// cap independently:
  ///
  ///  - the room's stored mode, which is the ONLY way the engine learns the
  ///    capacity (the live kit sends none at token time), and
  ///  - the local guest-tile list, so the host immediately sees the right
  ///    number of slots instead of the ones the widget was built with.
  /// Seat slots to allocate for a broadcast shape.
  ///
  /// Solo draws no grid, but it still takes guests — they float over the host's
  /// camera. Allocating `0 + 1` slots left only the host seat, and the kit's
  /// `hasFreeGuestTile` check (a free seat with index != 0) then refused every
  /// approval on a solo live before it reached the network.
  int _seatSlotsFor(LiveStageMode mode) =>
      (mode.guestTiles > 0 ? mode.guestTiles : live.kUTDSoloRailGuests) + 1;

  Future<void> _selectStageMode(
    LiveStageMode mode,
    live.UTDRoomController? controller,
  ) async {
    if (mode == _stageMode) return;
    final previous = _stageMode;
    setState(() => _stageMode = mode);

    // Resize locally first: instant and reversible, so the host never waits on
    // the network to see their choice take effect. Both halves matter — the
    // seats are the data, stageGuestTiles is how many of them the stage draws.
    controller?.seatController.initSeats(_seatSlotsFor(mode));
    LiveRoomData.instance.stageGuestTiles.value = mode.guestTiles;

    final result = await di<ChangeRoomModeUC>().call(
      ChangeRoomModeParameter(roomId: widget.roomId, mode: mode.roomMode),
    );

    result.fold(
      (failure) {
        if (!mounted) return;
        // Put the strip back, so the host is never shown a capacity the engine
        // will refuse to honour.
        setState(() => _stageMode = previous);
        controller?.seatController.initSeats(_seatSlotsFor(previous));
        LiveRoomData.instance.stageGuestTiles.value = previous.guestTiles;
        Methods.showToast(
          context,
          isError: true,
          message: NetworkExceptions.getErrorMessage(failure),
        );
      },
      (_) {
        RoomData.instance.room.mode = mode.roomMode.toString();
        // The kit's capacity is read from here, so without this the host picks
        // "3 Seats" and still gets a solo stage.
        LiveRoomData.instance.stageGuestTiles.value = mode.guestTiles;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ar = Methods.getLang() == 'ar';
    final controller =
        live.UTDRoomScope.maybeOf(context)?.controller ??
        LiveRoomData.instance.liveController;
    return Positioned(
      left: 16.w,
      right: 16.w,
      bottom: 28.h,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tools row — TikTok style: bare white icons + labels above the card.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PreLiveTool(
                icon: Icons.cameraswitch_outlined,
                label: ar ? 'قلب' : 'Flip',
                onTap: () => controller?.mediaController.switchCamera(),
              ),
              36.wBox,
              _PreLiveTool(
                icon: Icons.auto_awesome,
                label: ar ? 'تجميل' : 'Beauty',
                onTap:
                    () => VideoEffectsSheet.show(
                      context,
                      processor: LiveRoomData.instance.ensureVideoEffects(),
                    ),
              ),
              36.wBox,
              _PreLiveTool(
                icon: Icons.edit_outlined,
                label: ar ? 'المقدمة' : 'Intro',
                onTap: _editIntro,
              ),
            ],
          ),
          16.hBox,
          // Title card: broadcast cover thumb + title input (TikTok's layout).
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                _coverThumb(),
                12.wBox,
                Expanded(
                  child: TextField(
                    controller: _title,
                    maxLength: 60,
                    style: context.bodyMedium.w600.colorExt(Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      counterText: '',
                      hintText:
                          ar ? 'اسم البث المباشر...' : 'Live stream name...',
                      hintStyle: context.bodyMedium.colorExt(Colors.white54),
                    ),
                  ),
                ),
              ],
            ),
          ),
          14.hBox,
          // Wide start pill — the app's own (kit button hidden via config).
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton.icon(
              onPressed: () => controller?.mediaController.goLive(),
              icon: Icon(
                Icons.podcasts,
                color: ColorManager.buttonTextColor,
                size: 20.sp,
              ),
              label: Text(
                ar ? 'بدء البث' : 'Go LIVE',
                style: context.bodyLarge.w700.colorExt(
                  ColorManager.buttonTextColor,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
            ),
          ),
          10.hBox,
          // Broadcast shape, chosen BEFORE going live: Live | 4 | 6 | 8 | 12.
          // Not a settings screen — the capacity is baked into the room the
          // moment the host starts, and it stays fixed for the whole session
          // (collapsing it when the last guest leaves would nuke the grid).
          //
          // The seat pills are bare numerals, which need no translation; only
          // the solo pill carries a string.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final mode in LiveStageMode.values) ...[
                _StageModeTab(
                  label:
                      mode == LiveStageMode.solo ? mode.label.tr() : mode.label,
                  isSelected: mode == _stageMode,
                  onTap: () => _selectStageMode(mode, controller),
                ),
                if (mode != LiveStageMode.values.last) 14.wBox,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// One tab in the broadcast-shape strip: label plus an underline when active.
class _StageModeTab extends StatelessWidget {
  const _StageModeTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextWidget(
            label,
            style: context.bodyMedium
                .size(13)
                .colorExt(isSelected ? Colors.white : Colors.white60)
                .copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
          ),
          4.hBox,
          Container(
            height: 2.h,
            width: isSelected ? 18.w : 0,
            decoration: BoxDecoration(
              color: ColorManager.primary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ],
      ),
    );
  }
}
