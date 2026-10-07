import '../api/utd_api_client.dart';
import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart' show CameraPosition;

import '../controller/utd_room_controller.dart';
import '../minimizing/mini_overlay_machine.dart';
import '../models/ban_model.dart';
import '../models/role_model.dart';
import '../models/seat_model.dart';
import '../models/room_config.dart';
import '../theme/utd_room_scope.dart';
import '../theme/utd_room_strings.dart';
import '../theme/utd_room_theme.dart';
import 'banned_dialog.dart';
import 'live_ended_dialog.dart';
import 'default_connect_error.dart';
import 'default_controls_bar.dart';
import 'default_message_list.dart';
import 'default_room_header.dart';
import 'live_stage.dart';
import 'multi_guest_seat_layout.dart';
import 'pip_view.dart';
import 'sheets/live_tile_action_sheet.dart';
import 'sheets/member_list_sheet.dart';
import 'sheets/utd_sheet.dart';

/// A LiveKit-based video live room.
///
/// The host's camera fills the screen; up to [UTDLiveRoomConfig.maxGuestTiles]
/// invited guests appear as floating video tiles. There is no seat grid and no
/// separate background layer — the host video IS the background. The host enters
/// a self-preview and taps "Go Live" to publish (unless
/// [UTDLiveRoomConfig.autoHostCamera] is set). Audience can watch + chat and may
/// request to go live.
class UTDLiveRoom extends StatefulWidget {
  final String appId;

  /// Credential (no backend required): the project's publishable app key. The kit mints tokens
  /// directly from the engine with `X-App-Key` and authenticates in-room actions with the per-user
  /// bearer the engine returns. The project `server_secret` never ships in the app.
  final String appKey;

  final String userId;
  final String userName;
  final String roomId;
  final String roomOwnerId;

  /// Identities the app considers admins (owner -> host, these -> admin, rest ->
  /// audience). No engine round-trip; the engine only force-upgrades the owner.
  final Set<String> adminIds;

  /// Async source for [adminIds] when they are not known yet at build time
  /// (e.g. the app backend's enter-room response is still in flight). The
  /// token step NEVER waits for it: everyone joins immediately with the
  /// best-known role, and when this future resolves and lists the local user
  /// as an admin, the kit self-upgrades through the engine role endpoint
  /// ([UTDRoomController.upgradeSelfRole]) — server-side permissions +
  /// `_role_change` broadcast, so full moderation powers without serializing
  /// every join behind the enter-room response.
  final Future<Set<String>> Function()? adminIdsResolver;

  /// Optional SYNC probe for the admin list at token time (no waiting): the
  /// enter-room response may have landed during the route transition, in
  /// which case the join can use an `admin` token directly.
  final Set<String> Function()? adminIdsNow;

  /// Host serving `POST /api/v1/token`.
  ///
  /// PATCH (Eco Live): the kit hardcoded the vendor's hosts by calling
  /// [UTDRoomController.initApi] without them, so a pre-configured controller
  /// was reset to `udt-stream.com` on every build. Same fix as the audio kit.
  final String baseUrl;

  /// Host serving the in-room engine (stage, participants, bans, roles).
  final String engineBaseUrl;

  final UTDLiveRoomConfig config;
  final void Function(UTDRoomController controller)? onControllerReady;
  final void Function(bool isConnected)? onConnectionChanged;
  final void Function(Object error, StackTrace stackTrace)? onConnectError;

  /// Reuse an existing (already-connected) controller — e.g. restoring from a
  /// minimized overlay.
  final UTDRoomController? controller;

  const UTDLiveRoom({
    super.key,
    required this.appId,
    required this.appKey,
    required this.userId,
    required this.userName,
    required this.roomId,
    required this.roomOwnerId,
    this.adminIds = const {},
    this.adminIdsResolver,
    this.adminIdsNow,
    this.baseUrl = UTDApiClient.defaultBaseUrl,
    this.engineBaseUrl = UTDApiClient.defaultEngineBaseUrl,
    this.config = const UTDLiveRoomConfig(),
    this.onControllerReady,
    this.onConnectionChanged,
    this.onConnectError,
    this.controller,
  });

  @override
  State<UTDLiveRoom> createState() => _UTDLiveRoomState();
}

class _UTDLiveRoomState extends State<UTDLiveRoom> {
  late final UTDRoomController _controller;
  bool _connected = false;

  /// True while the host is in self-preview and has not yet tapped "Go Live".
  bool _showGoLive = false;

  /// Set when connect() fails and the consumer did not supply [onConnectError].
  Object? _connectError;
  StreamSubscription<UTDRoleChangeEvent>? _roleSnackSub;

  /// Two-page chrome carousel: page 0 = clear screen (video only), page 1 =
  /// full overlay UI. Starts on the overlay page; in the app's RTL layout
  /// going 1→0 (hide) is a leftward swipe and 0→1 (restore) a rightward one,
  /// matching the requested gesture.
  final PageController _overlayPageController = PageController(initialPage: 1);

  bool get _isHost => widget.userId == widget.roomOwnerId;

  @override
  void initState() {
    super.initState();

    if (UTDMiniOverlayMachine.instance.isMinimizing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          UTDMiniOverlayMachine.instance
              .changeState(UTDMiniOverlayState.inAudioRoom);
        }
      });
    }

    if (widget.controller != null && widget.controller!.isConnected) {
      _controller = widget.controller!;
      _controller.initApi(
        baseUrl: widget.baseUrl,
        engineBaseUrl: widget.engineBaseUrl,
        appId: widget.appId,
        appKey: widget.appKey,
      );
      // Wire the video-effects (beauty/filter) factory BEFORE connect so the
      // first camera capture carries the processor. Harmless on the reuse branch
      // (already-connected) — it applies to any subsequent re-capture.
      _controller.setVideoProcessorFactory(widget.config.buildVideoProcessor);
      _connected = true;
      widget.onControllerReady?.call(_controller);
      // Re-entering an already-connected room (restored from minimize): re-arm
      // OS PiP for this freshly-mounted screen.
      _controller.pip.armIfEnabled();
      // Re-arm owner-driven admin promotion on this fresh State (the prior State's
      // participantsStream listener was cancelled on its dispose). Idempotent: already-admin
      // identities are skipped, so it only catches admins who join during the restored session.
      if (_isHost) _armOwnerAdminPromotion();
    } else {
      _controller = widget.controller ?? UTDRoomController();
      _controller.initApi(
        baseUrl: widget.baseUrl,
        engineBaseUrl: widget.engineBaseUrl,
        appId: widget.appId,
        appKey: widget.appKey,
      );
      // Wire the video-effects (beauty/filter) factory BEFORE connect so the
      // first camera capture carries the processor. Harmless on the reuse branch
      // (already-connected) — it applies to any subsequent re-capture.
      _controller.setVideoProcessorFactory(widget.config.buildVideoProcessor);
      // Publish quality must also land BEFORE connect — it is baked into the
      // LiveKit RoomOptions at Room construction (default: HD 720p).
      _controller.setVideoQuality(widget.config.videoQuality);
      widget.onControllerReady?.call(_controller);
      _connect();
    }

    // Bans handled entirely inside the package (dialog → leave → onClose hook).
    _controller.onBanned = _handleBanned;
    // Host leaving ends the live for every other client (same dialog→leave→
    // onClose funnel as bans). ??= so a host app can override it.
    _controller.onLiveEnded ??= _handleLiveEnded;
    // Default force-exit only if the host did not wire its own (??= so host wins).
    _controller.onForceExit ??= _handleForceExit;

    if (widget.config.headerWidget == null &&
        widget.config.foregroundWidget == null) {
      _roleSnackSub = _controller.roleChangeStream.listen((e) {
        if (!mounted) return;
        if (e.identity != _controller.localIdentity) return;
        utdShowSnack(
            context, widget.config.resolveStrings().roleChangedTo(e.role));
      });
    }
  }

  Future<void> _connect() async {
    // Tile-layout capacity: host slot + guest tiles (the engine stage is
    // uncapped; this only sizes the UI strip).
    //
    // A SOLO broadcast has `maxGuestTiles == 0` — it draws no grid — but it
    // still accepts guests, who appear as floating tiles from the stage member
    // list. Sizing the seat list to 1 gave it a host seat and nothing else, and
    // `hasFreeGuestTile` (which looks for a free seat with index != 0) was then
    // permanently false: the host's approve was refused locally, before any
    // request left the device. So a viewer could ask to join a solo live and
    // the host could never accept.
    //
    // `maxGuestTiles` itself is left at 0 on purpose — it is what decides
    // whether the GRID is drawn.
    final guestCapacity = widget.config.maxGuestTiles > 0
        ? widget.config.maxGuestTiles
        : widget.config.soloRailGuests;
    final seatCount = guestCapacity + 1;
    final joinWatch = Stopwatch()..start();
    try {
      // Server-authoritative roles: only the verified owner is host; everyone
      // else joins as audience. The OWNER promotes admins/co-publishers after
      // join (see _armOwnerAdminPromotion + the stage), so the client never
      // self-asserts admin (the engine would clamp it anyway).
      final role = _isHost ? 'host' : 'audience';
      if (kDebugMode) {
        debugPrint(
            '[JOIN_TT] live tokenReq role=$role +${joinWatch.elapsedMilliseconds}ms');
      }
      final tokenResponse = await _controller.generateToken(
        identity: widget.userId,
        roomName: widget.roomId,
        roomOwnerId: widget.roomOwnerId,
        role: role,
        name: widget.userName,
        // type defaults to 'live_stream' — always the unbounded seatless stage.
        // No seat_count/seat_mode/host_seat is sent.
      );

      await _controller.connect(
        url: tokenResponse.url,
        token: tokenResponse.token,
        seatCount: seatCount,
        // The host enables the mic at "Go Live" (or autoHostCamera); audience
        // never publishes on join. So never enable the mic at connect.
        enableMicOnJoin: false,
        useSpeaker: widget.config.useSpeakerWhenJoining,
        userAttributes: widget.config.userInRoomAttributes,
        roomName: widget.roomId,
        // Lets the controller detect the host leaving and end the live for
        // every other client.
        hostIdentity: widget.roomOwnerId,
      );

      if (kDebugMode) {
        debugPrint(
            '[JOIN_TT] live connected +${joinWatch.elapsedMilliseconds}ms');
      }
      if (!mounted) return;
      setState(() => _connected = true);
      widget.onConnectionChanged?.call(true);
      _controller.pip.armIfEnabled();
      if (_isHost) {
        _armOwnerAdminPromotion();
      }
      await _startHostFlow();
    } on UTDBannedException catch (_) {
      if (mounted) {
        widget.onConnectionChanged?.call(false);
        _controller.notifyBannedFromToken();
      }
    } catch (e, st) {
      debugPrint('[UTDLiveRoom] connect failed: $e\n$st');
      if (mounted) {
        widget.onConnectionChanged?.call(false);
        if (widget.onConnectError != null) {
          widget.onConnectError!(e, st);
        } else {
          setState(() => _connectError = e);
        }
      }
    }
  }

  /// Identities the OWNER will promote to `admin` (moderators). Seeded from
  /// [UTDLiveRoom.adminIds] + the sync [UTDLiveRoom.adminIdsNow] probe + the
  /// async [UTDLiveRoom.adminIdsResolver]. Only meaningful on the host client.
  final Set<String> _adminTargets = {};

  /// Identities already promoted (or in flight) — guards against re-promoting on
  /// every participant event. Dropped on failure so a later event retries.
  final Set<String> _promoting = {};
  StreamSubscription<void>? _adminPromoteSub;

  /// Owner-driven, server-authoritative admin promotion. A client can't be
  /// trusted to declare itself admin (the engine clamps non-owners to audience),
  /// so the OWNER promotes the configured admin identities via the role endpoint
  /// once they are present in the room. Admins moderate but do NOT publish —
  /// publishing is the separate stage flow.
  void _armOwnerAdminPromotion() {
    if (!_isHost) return;
    _adminTargets.addAll(widget.adminIds);
    if (widget.adminIdsNow != null) {
      try {
        _adminTargets.addAll(widget.adminIdsNow!());
      } catch (_) {}
    }
    widget.adminIdsResolver?.call().then((ids) {
      if (!mounted) return;
      _adminTargets.addAll(ids);
      _promotePresentAdmins();
    }).catchError((Object e) {
      debugPrint('[UTDLiveRoom] adminIdsResolver failed (non-fatal): $e');
    });
    // Promote as admins join (and on the initial seed).
    _adminPromoteSub =
        _controller.participantsStream.listen((_) => _promotePresentAdmins());
    _promotePresentAdmins();
  }

  void _promotePresentAdmins() {
    if (!_isHost || !mounted || !_controller.isConnected) return;
    for (final id in _adminTargets) {
      if (id == widget.roomOwnerId || _promoting.contains(id)) continue;
      if (!_controller.participants.any((p) => p.id == id)) continue;
      final role = _controller.getParticipantRole(id);
      if (role == 'admin' || role == 'host') {
        _promoting.add(id);
        continue;
      }
      _promoting.add(id);
      _promoteOne(id);
    }
  }

  Future<void> _promoteOne(String id) async {
    try {
      await _controller.changeRole(targetIdentity: id, role: 'admin');
    } catch (e) {
      // Allow a later participant event to retry (e.g. the engine participants
      // row lagged the join).
      _promoting.remove(id);
      debugPrint('[UTDLiveRoom] promote admin failed (non-fatal): $e');
    }
  }

  /// Host go-live experience: self-preview → "Go Live" (default), or publish
  /// immediately when [UTDLiveRoomConfig.autoHostCamera] is set. Audience: no-op.
  Future<void> _startHostFlow() async {
    if (!_isHost) return;
    final position = widget.config.frontCameraOnJoin
        ? CameraPosition.front
        : CameraPosition.back;
    if (widget.config.autoHostCamera) {
      await _controller.mediaController.goLive();
      return;
    }
    await _controller.mediaController.startPreview(position: position);
    if (mounted) setState(() => _showGoLive = true);
  }

  Future<void> _goLive() async {
    await _controller.mediaController.goLive();
    if (mounted) setState(() => _showGoLive = false);
  }

  void _handleForceExit() => unawaited(_forceExit());

  Future<void> _forceExit() async {
    final strings = widget.config.resolveStrings();
    if (mounted) utdShowSnack(context, strings.connectionLost);
    final onClose = _controller.minimize.config?.onClose;
    await _controller.leave();
    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    onClose?.call();
  }

  Future<void> _handleBanned(UTDBanNotice notice) async {
    if (mounted) {
      await showUTDBannedDialog(context, notice);
      await _controller.leave();
      if (!mounted) return;
      final onClose = _controller.minimize.config?.onClose;
      Navigator.of(context).popUntil((route) => route.isFirst);
      onClose?.call();
      return;
    }
    // Minimized: this widget is disposed; route the ban through the app navigator.
    final ctx = _controller.navigatorKey?.currentContext;
    if (ctx != null) await showUTDBannedDialog(ctx, notice);
    if (_controller.minimize.isMinimizing) {
      await _controller.minimize.close();
    } else {
      await _controller.leave();
      _controller.minimize.config?.onClose?.call();
    }
  }

  /// The host left → end the live for this (non-host) client: show the
  /// "live ended" dialog, leave, pop to the first route, then run the host
  /// app's teardown via the `onClose` hook. Mirrors [_handleBanned].
  Future<void> _handleLiveEnded() async {
    final strings = widget.config.resolveStrings();

    if (mounted) {
      await showUTDLiveEndedDialog(
        context,
        title: strings.liveEndedTitle,
        message: strings.liveEndedMessage,
        confirmLabel: strings.ok,
      );
      await _controller.leave();
      if (!mounted) return;
      final onClose = _controller.minimize.config?.onClose;
      Navigator.of(context).popUntil((route) => route.isFirst);
      onClose?.call();
      return;
    }
    // Widget disposed (e.g. backgrounded): route through the app navigator.
    final ctx = _controller.navigatorKey?.currentContext;
    if (ctx != null) {
      await showUTDLiveEndedDialog(
        ctx,
        title: strings.liveEndedTitle,
        message: strings.liveEndedMessage,
        confirmLabel: strings.ok,
      );
    }
    await _controller.leave();
    _controller.minimize.config?.onClose?.call();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.minimize.captureNavigation(context);
  }

  void _retry() {
    setState(() => _connectError = null);
    _connect();
  }

  Future<void> _exitOnError() async {
    final onClose = _controller.minimize.config?.onClose;
    await _controller.leave();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    onClose?.call();
  }

  @override
  void dispose() {
    _roleSnackSub?.cancel();
    _adminPromoteSub?.cancel();
    _overlayPageController.dispose();
    _controller.pip.disarm();
    if (!_controller.minimize.isMinimizing) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.config.theme;
    final strings = widget.config.resolveStrings();

    return ValueListenableBuilder<bool>(
      valueListenable: _controller.pip.isInPip,
      builder: (context, inPip, child) =>
          inPip ? UTDPipView(controller: _controller) : child!,
      child: UTDRoomScope(
        theme: theme,
        strings: strings,
        controller: _controller,
        hostSeatIndex: widget.config.hostSeatIndex,
        roomOwnerId: widget.roomOwnerId,
        child: Scaffold(
          backgroundColor: theme.background,
          // The comment composer is pushed as a transparent route and owns
          // the keyboard inset. Keep the live chrome at its normal geometry
          // underneath it; resizing both routes subtracts the IME twice and
          // can make the messages slot negative while the keyboard animates.
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              // Base layer: the full-bleed video stage (host fills the screen).
              // Guest tiles are rendered SEPARATELY above the chrome PageView —
              // the scrollable is hit-test opaque and would swallow tile taps.
              if (_connected)
                Positioned.fill(
                  child: UTDLiveStage(
                    controller: _controller,
                    config: widget.config,
                    roomOwnerId: widget.roomOwnerId,
                    showGuestTiles: false,
                  ),
                )
              else if (_connectError != null)
                Positioned.fill(
                  child: UTDConnectErrorView(
                    theme: theme,
                    strings: strings,
                    onRetry: _retry,
                    onExit: _exitOnError,
                    error: _connectError,
                  ),
                )
              else
                // Connecting skeleton: a stage-shaped dark gradient (the host
                // video IS the background) with a subtle indicator — instant
                // visual structure instead of a bare spinner on black.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF2A2A33),
                          Color(0xFF17171D),
                          Color(0xFF0E0E12),
                        ],
                      ),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                ),

              // Overlays (header top, chat bottom-start, controls bottom).
              // bottomStart (not bottomLeft): the chat column must hug the
              // reading edge — right in RTL locales, left in LTR.
              //
              // The whole chrome lives in a two-page horizontal PageView —
              // "a screen over the screen": swiping toward the reading
              // direction slides every overlay away for an unobstructed view
              // of the video, swiping back restores it (owner request
              // 2026-06-11). Inner horizontal scrollables (visitor strip)
              // win over the PageView inside their own bounds, as usual.
              if (_connected)
                Positioned.fill(
                  child: PageView(
                    controller: _overlayPageController,
                    physics: const ClampingScrollPhysics(),
                    children: [
                      // Page 0 — the "clear screen": nothing but the video.
                      // The scrollable is hit-test-opaque, so stage taps must
                      // be re-emitted from INSIDE the page (tap-hearts).
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: widget.config.onStageTap,
                        child: const SizedBox.expand(),
                      ),
                      // Page 1 — chrome. A bottom-layer detector catches taps
                      // that fall through the chrome's transparent gaps (the
                      // chrome widgets keep winning their own taps), since the
                      // PageView blocks them from reaching the stage below.
                      Stack(
                        children: [
                          if (widget.config.onStageTap != null)
                            Positioned.fill(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: widget.config.onStageTap,
                                child: const SizedBox.expand(),
                              ),
                            ),
                          SafeArea(
                            // Keep the same bottom safe padding while the
                            // transparent input route opens/closes its IME.
                            // This leaves one stable chrome/messages/controls
                            // subtree mounted throughout keyboard rebuilds.
                            maintainBottomViewPadding: true,
                            child: Column(
                              children: [
                                widget.config.headerWidget ??
                                    UTDDefaultRoomHeader(
                                      controller: _controller,
                                      enableMinimize:
                                          widget.config.enableMinimize,
                                    ),
                                Expanded(
                                  // A custom messagesWidget gets the WHOLE area
                                  // between the header and the controls bar and
                                  // manages its own size/alignment (the app's
                                  // tabbed chat anchors itself bottom-start and
                                  // can expand up to just below the header). Only
                                  // the built-in default keeps the legacy 0.72×0.6
                                  // bottom-start framing.
                                  // In grid mode the seats occupy a band at the top
                                  // of this same area, so the chat is pushed below
                                  // them. Without this the first few messages sit
                                  // underneath the seat cells.
                                  child: _reserveGridSpace(
                                    context,
                                    widget.config.messagesWidget ??
                                        Align(
                                          alignment:
                                              AlignmentDirectional.bottomStart,
                                          child: FractionallySizedBox(
                                            widthFactor: 0.72,
                                            heightFactor: 0.6,
                                            child: UTDDefaultMessageList(
                                              chatController:
                                                  _controller.chatController,
                                            ),
                                          ),
                                        ),
                                  ),
                                ),
                                widget.config.controlsBarWidget ??
                                    (widget.config.showControlsBar
                                        ? UTDDefaultControlsBar(
                                            controller: _controller)
                                        : const SizedBox()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Guest tiles layer — ABOVE the chrome PageView so tile taps
              // (action sheet) keep working; visible in clear-screen mode too.
              if (_connected)
                Positioned.fill(
                  child: UTDLiveStage(
                    controller: _controller,
                    config: widget.config,
                    roomOwnerId: widget.roomOwnerId,
                    showHost: false,
                    onGuestTileTap: (ctx, seat) => UTDLiveTileActionSheet.show(
                      ctx,
                      controller: _controller,
                      seat: seat,
                    ),
                    // An empty slot is an invitation, and who it invites
                    // depends on who is tapping: the host picks somebody from
                    // the member list, everyone else asks to be let up.
                    onEmptySlotTap: _onEmptySlotTap,
                  ),
                ),

              // Host "Go Live" button (only while in self-preview, and only
              // when the app did not take over the composer UI).
              if (_connected && _showGoLive && widget.config.showGoLiveButton)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 96,
                  child: Center(child: _goLiveButton(theme, strings)),
                ),

              if (widget.config.foregroundWidget != null)
                Positioned.fill(child: widget.config.foregroundWidget!),
            ],
          ),
        ),
      ),
    );
  }

  /// Pad [child] down by the height of the seat grid, when there is one.
  ///
  /// The grid is absolutely positioned over the header-to-controls area; the
  /// chat is laid out inside it. Reserving the grid's measured height is what
  /// keeps the two from sharing pixels.
  Widget _reserveGridSpace(BuildContext context, Widget child) {
    final guests = widget.config.maxGuestTiles;
    if (guests < 3) return child;

    // Measured exactly the way the stage measures it — same available width,
    // same height cap — so the reservation can never disagree with what is
    // actually drawn.
    final media = MediaQuery.of(context);
    final total = guests + 1;
    final width = UTDMultiGuestSeatLayout.widthForMaxHeight(
      total,
      media.size.width - 16,
      media.size.height * UTDLiveStage.gridMaxHeightFraction,
    );
    final gridHeight = UTDMultiGuestSeatLayout.heightFor(total, width);

    return Padding(
      padding: EdgeInsets.only(top: gridHeight + 10),
      child: child,
    );
  }

  /// An empty guest slot was tapped.
  ///
  /// Host or admin -> the member list, where each participant has an
  /// "invite to speak" action. Anyone else -> ask to come up, which reaches the
  /// host as a `_stage_request`.
  ///
  /// Deliberately no-ops for a viewer who already has a request outstanding,
  /// rather than sending a duplicate the host would see twice.
  Future<void> _onEmptySlotTap(BuildContext ctx, SeatState seat) async {
    final strings = widget.config.resolveStrings();

    if (_controller.isHostOrAdmin) {
      await UTDMemberListSheet.show(ctx, controller: _controller);
      return;
    }

    if (_controller.seatController.localStageRequested.value) {
      utdShowSnack(ctx, strings.cancelRequest);
      return;
    }

    // Captured before the await: the sheetless tap leaves this context alive,
    // but the messenger lookup is cheap insurance against a rebuild.
    final messenger = ScaffoldMessenger.maybeOf(ctx);
    final ok = await _controller.requestToSpeak();
    utdShowSnackVia(
      messenger,
      ok != null ? strings.invitationSent : strings.actionFailed,
    );
  }

  Widget _goLiveButton(UTDRoomTheme theme, UTDRoomStrings strings) {
    return ElevatedButton.icon(
      onPressed: _goLive,
      icon: const Icon(Icons.podcasts),
      label: Text(strings.goLive),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
