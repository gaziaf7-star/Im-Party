import '../api/utd_api_client.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../controller/utd_room_controller.dart';
import '../core/connection_prewarm.dart';
import '../minimizing/mini_overlay_machine.dart';
import '../models/ban_model.dart';
import '../models/room_config.dart';
import '../models/room_mode.dart';
import '../models/seat_layout.dart';
import '../models/seat_model.dart';
import '../models/token_response_model.dart';
import 'banned_dialog.dart';
import 'controls_bar.dart';
import 'default_connect_error.dart';
import 'default_message_list.dart';
import 'seat_grid.dart';
import 'seat_widget.dart';

class UTDAudioRoom extends StatefulWidget {
  final String appId;

  /// The project's publishable app key (no backend required). The kit mints tokens directly from
  /// the engine with `X-App-Key` and authenticates in-room actions with the per-user bearer the
  /// engine returns. The project `server_secret` never ships in the app.
  final String appKey;

  final String userId;
  final String userName;
  final String roomId;
  final String roomOwnerId;

  /// Identities the app considers admins (from its own enter-room admin list).
  /// Used to request the `admin` role at join — owner is always `host`, anyone
  /// in this set is `admin`, everyone else is `audience`.
  final Set<String> adminIds;

  /// Optional async source for the admin list when [adminIds] is empty at
  /// build (the app usually learns the admins from its enter-room API AFTER
  /// this widget builds). The token step NEVER waits for it: everyone joins
  /// immediately with the best-known role, and when this future resolves and
  /// lists the local user as an admin, the kit self-upgrades through the
  /// engine role endpoint ([UTDRoomController.upgradeSelfRole]) — which
  /// updates RTC permissions server-side and broadcasts `_role_change`,
  /// so the admin ends up with full moderation powers without serializing
  /// every join behind the enter-room response.
  final Future<Set<String>> Function()? adminIdsResolver;

  /// Optional SYNC probe for the admin list at token time (no waiting): the
  /// enter-room response may have landed during the route transition, in
  /// which case the join can use an `admin` token directly and no upgrade
  /// round-trip is needed.
  final Set<String> Function()? adminIdsNow;

  /// Host serving the in-room engine (seats, speakers, bans, roles).
  ///
  /// PATCH (Eco Live): the kit hardcoded these to the vendor's hosts by calling
  /// [UTDRoomController.initApi] without them, so a pre-configured controller
  /// was silently reset to `engine.udt-stream.com` on every build. Threading
  /// them through here is what lets the app run its own engine.
  final String baseUrl;

  /// Host serving `POST /api/v1/token`. Usually the same as [baseUrl]; the
  /// vendor split them because token issuance ran on a different edge.
  final String tokenBaseUrl;

  final String layoutMode;
  final UTDAudioRoomConfig config;
  final void Function(UTDRoomController controller)? onControllerReady;
  final void Function(bool isConnected)? onConnectionChanged;
  final void Function(int index, SeatState seat)? onSeatTap;
  final void Function(List<SeatState> seats)? onSeatChanged;
  final void Function(Object error, StackTrace stackTrace)? onConnectError;

  final UTDRoomController? controller;

  /// Optional pre-fetched token source: when set, the widget awaits it instead
  /// of issuing its own [UTDRoomController.generateToken] call, so the app can
  /// overlap the token round trip with route navigation (start the fetch at
  /// tap time, pass `() => thatFuture` here).
  ///
  /// MUST be a future produced by calling `generateToken` on the SAME
  /// [controller] instance passed to this widget — `generateToken` applies the
  /// per-user bearer and remembers the RTC edge URL on the controller and its
  /// API clients as side effects, so a token minted through another controller
  /// would leave this one unauthenticated. Compute the seat parameters with
  /// [resolveTokenSeatParams] so they match the widget's own request. If the
  /// provider throws or resolves to null, the widget falls back to its own
  /// `generateToken` call (the join is not failed).
  final Future<UTDTokenResponse?> Function()? tokenProvider;

  final List<UTDRoomMode> modes;

  @Deprecated('Use modes parameter instead')
  final Widget Function(
    List<SeatState> seats,
    Widget Function(int seatIndex) seatWidgetCreator,
  )? containerBuilder;

  const UTDAudioRoom({
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
    this.tokenBaseUrl = UTDApiClient.defaultTokenBaseUrl,
    this.layoutMode = '3',
    this.config = const UTDAudioRoomConfig(),
    this.onControllerReady,
    this.onConnectionChanged,
    this.onSeatTap,
    this.onSeatChanged,
    this.onConnectError,
    @Deprecated('Use modes parameter instead') this.containerBuilder,
    this.controller,
    this.tokenProvider,
    this.modes = const [],
  }) : assert(
          controller != null || tokenProvider == null,
          'tokenProvider must come from generateToken on the same controller '
          'passed to this widget — pass that controller too',
        );

  /// Resolves the seat-related `generateToken` parameters exactly as this
  /// widget does at connect time: the mode is looked up by [layoutMode] in
  /// [modes] (falling back to [UTDRoomMode.defaultMode]), and the seat fields
  /// are only sent for the host — the owner defines the room layout, everyone
  /// else inherits it. Use this when prefetching a token at tap time (see
  /// [tokenProvider]) so the prefetch carries parameters IDENTICAL to the
  /// widget's own request.
  static UTDTokenSeatParams resolveTokenSeatParams({
    required String layoutMode,
    required bool isHost,
    List<UTDRoomMode> modes = const [],
  }) {
    // Last match wins, mirroring UTDRoomController.registerModes (map put).
    var mode = UTDRoomMode.defaultMode;
    for (final m in modes) {
      if (m.id == layoutMode) mode = m;
    }
    return UTDTokenSeatParams(
      seatCount: isHost ? mode.seatCount : null,
      seatMode: isHost ? 'free' : null,
      hostSeat: isHost ? 0 : null,
      modeId: isHost ? layoutMode : null,
    );
  }

  @override
  State<UTDAudioRoom> createState() => _UTDAudioRoomState();
}

/// Seat-related `generateToken` parameters resolved from a layout mode —
/// see [UTDAudioRoom.resolveTokenSeatParams]. All fields are null for
/// non-host joins (the engine ignores seat parameters from non-owners).
class UTDTokenSeatParams {
  const UTDTokenSeatParams({
    this.seatCount,
    this.seatMode,
    this.hostSeat,
    this.modeId,
  });

  final int? seatCount;
  final String? seatMode;
  final int? hostSeat;
  final String? modeId;
}

class _UTDAudioRoomState extends State<UTDAudioRoom> {
  late final UTDRoomController _controller;
  bool _connected = false;

  // True once the token response landed. The token step is where a ban is
  // rejected (UTDBannedException), so past this point the user is allowed to
  // see room content — the real room body renders immediately, fed by the
  // REST seat snapshot racing the RTC dial, instead of holding the grey
  // skeleton for the whole WSS+ICE establishment.
  bool _tokenReady = false;

  // The connect failure, when the consumer supplied no onConnectError. Drives the
  // built-in error view (Retry/Exit, or a not-activated message for a forbidden 403)
  // instead of leaving the connecting skeleton up forever.
  Object? _connectError;
  VoidCallback? _seatChangedListener;

  /// The room body (seats/chat/controls) is shown from token receipt onward;
  /// live features light up when [_connected] flips.
  bool get _showRoomBody => _connected || _tokenReady;

  @override
  void initState() {
    super.initState();

    // Publish the dev-set seat layout BEFORE the first build, so every size
    // consumer (computeSeatSize call sites, the grid, the connecting skeleton,
    // and the app-side SeatMetrics) reads this room's values from the start.
    UTDSeatLayout.active = widget.config.seatLayout;

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
        tokenBaseUrl: widget.tokenBaseUrl,
        appId: widget.appId,
        appKey: widget.appKey,
      );
      _controller.registerModes(widget.modes);
      _connected = true;
      widget.onControllerReady?.call(_controller);
      _listenSeatChanges();
    } else {
      _controller = widget.controller ?? UTDRoomController();
      _controller.initApi(
        baseUrl: widget.baseUrl,
        tokenBaseUrl: widget.tokenBaseUrl,
        appId: widget.appId,
        appKey: widget.appKey,
      );
      _controller.registerModes(widget.modes);
      widget.onControllerReady?.call(_controller);
      _connect();
    }

    // Localized strings for controller-emitted room-chat lines (admin
    // promote/demote announcements). Covers both branches above.
    _controller.strings = widget.config.resolveStrings();

    // Handle bans entirely inside the package: show the banned dialog, leave
    // the room, then trigger the host app's exit via the minimize onClose hook.
    _controller.onBanned = _handleBanned;
  }

  Future<void> _handleBanned(UTDBanNotice notice) async {
    // Case 1: the user is actively viewing the room (this widget is mounted).
    if (mounted) {
      await showUTDBannedDialog(context, notice);
      await _controller.leave();
      if (!mounted) return;

      // Capture before popping: popping the room route disposes this widget
      // (and the controller), so resolve onClose now.
      final onClose = _controller.minimize.config?.onClose;

      // Take the banned user out of the room UI. The host's onClose
      // (e.g. RoomStateManager.exitRoom) only tears down room state — it does
      // not navigate — so the route must be popped here. popUntil (not
      // maybePop) so a host PopScope(canPop:false) guard on the room screen
      // can't intercept the pop and re-show its exit dialog, and so any
      // sheets/dialogs stacked over the room are dismissed too.
      Navigator.of(context).popUntil((route) => route.isFirst);

      // App-level room-state teardown (RTM, gifts, RoomStateManager…).
      onClose?.call();
      return;
    }

    // Case 2: the room is minimized, so this widget has already been disposed
    // (its route was popped on minimize) while the controller lives on for the
    // floating overlay. Surface the ban through the app navigator and tear down
    // the overlay + room state. There is no room route to pop.
    final ctx = _controller.navigatorKey?.currentContext;
    if (ctx != null) {
      await showUTDBannedDialog(ctx, notice);
    }
    if (_controller.minimize.isMinimizing) {
      // close(): leave the room, dismiss the overlay, fire the host onClose.
      await _controller.minimize.close();
    } else {
      await _controller.leave();
      _controller.minimize.config?.onClose?.call();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.minimize.captureNavigation(context);
  }

  void _listenSeatChanges() {
    if (widget.onSeatChanged != null) {
      _seatChangedListener = () {
        widget.onSeatChanged!(_controller.seatController.seats.value);
      };
      _controller.seatController.seats.addListener(_seatChangedListener!);
    }
  }

  Future<void> _connect() async {
    final mode = _controller.resolveMode(widget.layoutMode);
    final seatCount = mode.seatCount;
    final joinWatch = Stopwatch()..start();

    // Overlap two costs with the token round trip instead of paying them
    // serially after it: (a) DNS/TLS warm-up to the RTC edge remembered from
    // the last join, so the WSS dial resumes instead of a cold handshake, and
    // (b) teardown of a previous room on a room switch (connect() awaits it
    // before dialing). Both are no-ops on a plain first join.
    unawaited(UTDConnectionPrewarm.prewarmRtc());
    _controller.prepareConnect();

    try {
      final isHost = widget.userId == widget.roomOwnerId;
      // The app is the source of truth for roles: owner -> host, anyone in the
      // app's admin list -> admin, everyone else -> audience. NO waiting on
      // the enter-room response: join immediately with the best-known role
      // ([adminIds], else the sync [adminIdsNow] probe), and self-upgrade
      // post-connect if the resolver later lists the local user as an admin
      // (see _armAdminUpgrade). Non-admins — 99% of joins — pay zero wait.
      var adminIds = widget.adminIds;
      if (!isHost && adminIds.isEmpty && widget.adminIdsNow != null) {
        try {
          adminIds = widget.adminIdsNow!();
        } catch (_) {}
      }
      final role = isHost
          ? 'host'
          : adminIds.contains(widget.userId)
              ? 'admin'
              : 'audience';
      if (kDebugMode) {
        debugPrint(
            '[JOIN_TT] tokenReq role=$role +${joinWatch.elapsedMilliseconds}ms');
      }
      UTDTokenResponse? tokenResponse;
      if (widget.tokenProvider != null) {
        try {
          tokenResponse = await widget.tokenProvider!();
        } catch (e) {
          debugPrint(
              '[UTDAudioRoom] tokenProvider failed — falling back to '
              'generateToken: $e');
        }
      }
      if (tokenResponse == null) {
        final seatParams = UTDAudioRoom.resolveTokenSeatParams(
          layoutMode: widget.layoutMode,
          isHost: isHost,
          modes: _controller.registeredModes,
        );
        tokenResponse = await _controller.generateToken(
          identity: widget.userId,
          roomName: widget.roomId,
          roomOwnerId: widget.roomOwnerId,
          role: role,
          name: widget.userName,
          seatCount: seatParams.seatCount,
          seatMode: seatParams.seatMode,
          hostSeat: seatParams.hostSeat,
          modeId: seatParams.modeId,
        );
      }
      final url = tokenResponse.url;
      final token = tokenResponse.token;
      if (kDebugMode) {
        debugPrint('[JOIN_TT] tokenResp +${joinWatch.elapsedMilliseconds}ms');
      }

      // Token issued → the user is not banned (a ban is a 403 on the token
      // POST, caught below). Show the real room body NOW and race a seat
      // snapshot against the RTC dial: the engine may embed the seat state in
      // the token response (zero extra round trips); otherwise primeSeats
      // fires GET /seats in parallel with connect(). Either way the grid shows
      // occupants roughly a full RTC establishment earlier than before.
      _controller.primeSeats(
        roomName: widget.roomId,
        seatCount: seatCount,
        snapshot: tokenResponse.seats,
      );
      if (mounted) {
        setState(() => _tokenReady = true);
      }

      await _controller.connect(
        url: url,
        token: token,
        seatCount: seatCount,
        enableMicOnJoin: widget.config.turnOnMicrophoneWhenJoining,
        useSpeaker: widget.config.useSpeakerWhenJoining,
        userAttributes: widget.config.userInRoomAttributes,
        roomName: widget.roomId,
      );
      if (kDebugMode) {
        debugPrint('[JOIN_TT] connected +${joinWatch.elapsedMilliseconds}ms');
        _watchFirstAudio(joinWatch);
      }

      if (mounted) {
        setState(() => _connected = true);
        widget.onConnectionChanged?.call(true);
        _listenSeatChanges();
      }
      if (!isHost && role != 'admin') {
        _armAdminUpgrade();
      }
    } on UTDBannedException catch (_) {
      // Re-entry blocked: route through the controller's ban funnel so the
      // banned dialog + exit flow run (de-duplicated with other ban signals).
      if (mounted) {
        widget.onConnectionChanged?.call(false);
        _controller.notifyBannedFromToken();
      }
    } catch (e, st) {
      debugPrint('[UTDAudioRoom] connect failed: $e\n$st');
      if (mounted) {
        widget.onConnectionChanged?.call(false);
        // Drop the token-ready body in BOTH branches: a dead, never-connected
        // room must not stay rendered (and interactive) after the RTC connect
        // failed — the skeleton returns until a retry re-issues a token.
        setState(() => _tokenReady = false);
        // Honor a host-supplied handler; otherwise fall back to the built-in error
        // view so a refusal (e.g. audio rooms not activated) is shown, not a spinner.
        if (widget.onConnectError != null) {
          widget.onConnectError!(e, st);
        } else {
          setState(() => _connectError = e);
        }
      }
    }
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

  /// Attaches the (non-blocking) admin self-upgrade: when the enter-room
  /// response resolves and lists the local user as an admin, upgrade the
  /// already-connected audience session through the engine role endpoint.
  /// Fallback on persistent failure (e.g. the engine validates the actor as a
  /// present participant and the owner is offline): one silent token re-issue
  /// + reconnect with the admin role — admins only, rare.
  void _armAdminUpgrade() {
    final resolver = widget.adminIdsResolver;
    if (resolver == null) return;
    resolver().then((ids) async {
      if (!mounted || !ids.contains(widget.userId)) return;
      if (!_controller.isConnected) return;
      final upgraded = await _controller.upgradeSelfRole(
        ownerId: widget.roomOwnerId,
        selfId: widget.userId,
      );
      if (!upgraded && mounted && _controller.isConnected) {
        await _reconnectAsAdmin();
      }
    }).catchError((Object e) {
      debugPrint('[UTDAudioRoom] adminIdsResolver failed (non-fatal): $e');
    });
  }

  Future<void> _reconnectAsAdmin() async {
    try {
      final tokenResponse = await _controller.generateToken(
        identity: widget.userId,
        roomName: widget.roomId,
        roomOwnerId: widget.roomOwnerId,
        role: 'admin',
        name: widget.userName,
      );
      // The user may have exited (or been removed) while the token request
      // was in flight — reconnecting then would resurrect a room session
      // nobody is looking at.
      if (!mounted || !_controller.isConnected) return;
      final mode = _controller.resolveMode(widget.layoutMode);
      await _controller.connect(
        url: tokenResponse.url,
        token: tokenResponse.token,
        seatCount: mode.seatCount,
        enableMicOnJoin: false,
        useSpeaker: widget.config.useSpeakerWhenJoining,
        userAttributes: widget.config.userInRoomAttributes,
        roomName: widget.roomId,
      );
      // Exited while the reconnect itself was in flight: tear the fresh
      // session down immediately instead of leaving it audible.
      if (!mounted) await _controller.leave();
    } on UTDBannedException catch (_) {
      if (mounted) _controller.notifyBannedFromToken();
    } catch (e) {
      debugPrint('[UTDAudioRoom] admin token re-issue failed (non-fatal): $e');
    }
  }

  VoidCallback? _firstAudioListener;

  /// Debug-only join timeline: stamps the first moment someone is audibly
  /// speaking after connect (≈ "audio flowing" for the joiner).
  void _watchFirstAudio(Stopwatch joinWatch) {
    if (_firstAudioListener != null) return;
    if (_controller.activeSpeakers.value.isNotEmpty) {
      debugPrint('[JOIN_TT] firstAudio +${joinWatch.elapsedMilliseconds}ms');
      return;
    }
    _firstAudioListener = () {
      if (_controller.activeSpeakers.value.isEmpty) return;
      debugPrint('[JOIN_TT] firstAudio +${joinWatch.elapsedMilliseconds}ms');
      final l = _firstAudioListener;
      _firstAudioListener = null;
      if (l != null) _controller.activeSpeakers.removeListener(l);
    };
    _controller.activeSpeakers.addListener(_firstAudioListener!);
  }

  @override
  void didUpdateWidget(covariant UTDAudioRoom oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep the published layout in step if the host app swaps in a new config.
    if (widget.config.seatLayout != oldWidget.config.seatLayout) {
      UTDSeatLayout.active = widget.config.seatLayout;
    }
  }

  @override
  void dispose() {
    if (_seatChangedListener != null) {
      _controller.seatController.seats.removeListener(_seatChangedListener!);
    }
    if (_firstAudioListener != null) {
      _controller.activeSpeakers.removeListener(_firstAudioListener!);
      _firstAudioListener = null;
    }
    if (!_controller.minimize.isMinimizing) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: widget.config.resizeToAvoidBottomInset,
      body: Stack(
        children: [
          // Layer 1: Static background
          if (widget.config.backgroundWidget != null)
            Positioned.fill(child: widget.config.backgroundWidget!),

          // Layer 1b: Mode-specific background
          if (_showRoomBody)
            Positioned.fill(
              child: ValueListenableBuilder<UTDRoomMode>(
                valueListenable: _controller.currentMode,
                builder: (ctx, mode, _) {
                  if (mode.backgroundBuilder != null) {
                    return mode.backgroundBuilder!(ctx);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

          // Layer 2: Main Column. Until the TOKEN resolves, the room body is
          // replaced by a skeleton so users about to be rejected (banned — a
          // 403 on the token POST) never see room content. Once the token is
          // issued the real body renders immediately (seats fed by the REST
          // snapshot racing the RTC dial); a subsequent connect failure swaps
          // it for the error view (checked first, below). The header and
          // foreground (Layer 3) stay so room info and the exit affordance
          // remain available throughout.
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.config.headerWidget != null)
                widget.config.headerWidget!,
              if (_connectError != null)
                Expanded(
                  child: UTDConnectErrorView(
                    theme: widget.config.theme,
                    strings: widget.config.resolveStrings(),
                    onRetry: _retry,
                    onExit: _exitOnError,
                    error: _connectError,
                  ),
                )
              else if (_showRoomBody) ...[
                Padding(
                  padding: EdgeInsets.only(
                    top: UTDSeatLayout.active.seatsTopPadding,
                  ),
                  child: _buildSeats(),
                ),
                if (widget.config.pkWidget != null) widget.config.pkWidget!,
                Expanded(
                  child: widget.config.messagesWidget ??
                      UTDDefaultMessageList(
                        chatController: _controller.chatController,
                      ),
                ),
                widget.config.controlsBarWidget ??
                    (widget.config.showControlsBar
                        ? UTDControlsBar(
                            mediaController: _controller.mediaController,
                            chatController: _controller.chatController,
                          )
                        : const SizedBox()),
              ] else
                Expanded(child: _buildConnectingSkeleton(context)),
            ],
          ),

          // Layer 3: Foreground
          if (widget.config.foregroundWidget != null)
            Positioned.fill(child: widget.config.foregroundWidget!),
        ],
      ),
    );
  }

  /// Pre-connect skeleton: greyed placeholder seat circles laid out exactly
  /// like the real grid ([widget.layoutMode] is known at build) plus an empty
  /// chat area, so the room shape appears instantly instead of a bare spinner.
  /// Placeholders only — NO real seat/chat data renders before connect, so a
  /// user about to be rejected (banned) still never sees room content.
  Widget _buildConnectingSkeleton(BuildContext context) {
    final mode = _controller.resolveMode(widget.layoutMode);
    // sizeOf (not MediaQuery.of): a full-MediaQuery dependency would rebuild
    // this subtree on every keyboard-inset animation frame.
    final seatSize = mode.computeSeatSize(MediaQuery.sizeOf(context).width);
    return _ConnectingSkeleton(rows: mode.rows, seatSize: seatSize);
  }

  Widget _buildSeats() {
    return ValueListenableBuilder<UTDRoomMode>(
      valueListenable: _controller.currentMode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<List<SeatState>>(
          valueListenable: _controller.seatController.seats,
          builder: (_, seats, __) {
            // sizeOf (not MediaQuery.of): a full-MediaQuery dependency would
            // rebuild the whole seats subtree — including the jsonDecode role
            // getter it used to call — on every keyboard-inset frame.
            final seatSize =
                mode.computeSeatSize(MediaQuery.sizeOf(context).width);

            // Host-app override (e.g. the Ludo game): swaps the grid out while
            // active, without touching the room mode or seat state.
            final overrideActive = widget.config.seatsOverrideActive;
            final overrideBuilder = widget.config.seatsOverrideBuilder;
            if (overrideActive != null && overrideBuilder != null) {
              return ValueListenableBuilder<bool>(
                valueListenable: overrideActive,
                builder: (ctx, on, _) {
                  if (on) {
                    return overrideBuilder(
                        seats, (i) => _seatAt(i, seats, seatSize), seatSize);
                  }
                  return _buildSeatGrid(mode, seats, seatSize);
                },
              );
            }
            return _buildSeatGrid(mode, seats, seatSize);
          },
        );
      },
    );
  }

  Widget _buildSeatGrid(
      UTDRoomMode mode, List<SeatState> seats, double seatSize) {
            // App-provided container/seat builders render seats whose widgets
            // self-listen to activeSpeakers (e.g. the speaking glow). Wrapping
            // them in a VLB(activeSpeakers) here would rebuild the ENTIRE grid on
            // every speaking transition; instead let each seat rebuild itself.
            // Only the built-in UTDSeatGrid path (below) needs activeSpeakers.
            // ignore: deprecated_member_use_from_same_package
            if (widget.containerBuilder != null) {
              // ignore: deprecated_member_use_from_same_package
              return widget.containerBuilder!(
                  seats, (i) => _seatAt(i, seats, seatSize));
            }

            if (mode.containerBuilder != null) {
              return mode.containerBuilder!(
                  seats, (i) => _seatAt(i, seats, seatSize));
            }

            // Roles come from the controller's cached notifier (updated only
            // when participants/roles actually change), NOT the
            // participantRoles getter — the getter jsonDecodes every
            // participant's metadata and would run on every speaker
            // transition.
            return ValueListenableBuilder<Map<String, String>>(
              valueListenable: _controller.participantRolesNotifier,
              builder: (_, roles, __) {
                return ValueListenableBuilder<Set<String>>(
                  valueListenable: _controller.activeSpeakers,
                  builder: (_, speakers, __) {
                    return UTDSeatGrid(
                      rows: mode.rows,
                      seatSize: seatSize,
                      seats: seats,
                      activeSpeakers: speakers,
                      participantRoles: roles,
                      onSeatTap: widget.onSeatTap,
                      seatBuilder: widget.config.seatBuilder,
                      avatarBuilder: widget.config.avatarBuilder,
                      emptySeatBuilder: widget.config.emptySeatBuilder,
                      lockedSeatBuilder: widget.config.lockedSeatBuilder,
                    );
                  },
                );
              },
            );
  }

  Widget _seatAt(int i, List<SeatState> seats, double size) {
    final seat = i < seats.length ? seats[i] : SeatState(index: i);
    return UTDSeatWidget(
      seat: seat,
      size: size,
      onTap: () => widget.onSeatTap?.call(i, seat),
      seatBuilder: widget.config.seatBuilder,
      avatarBuilder: widget.config.avatarBuilder,
      emptySeatBuilder: widget.config.emptySeatBuilder,
      lockedSeatBuilder: widget.config.lockedSeatBuilder,
    );
  }
}

/// Pre-connect skeleton whose placeholder seats gently "breathe" so the join
/// state clearly reads as loading rather than frozen. A SINGLE shared
/// AnimationController drives every circle's opacity (never one per tile), and
/// the whole widget — controller included — is torn down the instant the real
/// room body replaces it, so there is no steady-state cost after connect.
/// Honors reduce-motion (renders a static skeleton).
class _ConnectingSkeleton extends StatefulWidget {
  final List<List<int>> rows;
  final double seatSize;

  const _ConnectingSkeleton({required this.rows, required this.seatSize});

  @override
  State<_ConnectingSkeleton> createState() => _ConnectingSkeletonState();
}

class _ConnectingSkeletonState extends State<_ConnectingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final Widget grid = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int r = 0; r < widget.rows.length; r++)
          // scaleDown keeps a wide row from overflowing narrow screens.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final _ in widget.rows[r])
                  Padding(
                    padding: const EdgeInsets.all(6),
                    // A small per-row phase offset so the grid breathes
                    // top-to-bottom instead of all at once.
                    child: _SkeletonCircle(
                      controller: _controller,
                      size: widget.seatSize,
                      phase: r * 0.15,
                      animate: !reduceMotion,
                    ),
                  ),
              ],
            ),
          ),
        const Expanded(child: SizedBox.shrink()),
      ],
    );
    return RepaintBoundary(child: grid);
  }
}

class _SkeletonCircle extends StatelessWidget {
  final AnimationController controller;
  final double size;
  final double phase;
  final bool animate;

  const _SkeletonCircle({
    required this.controller,
    required this.size,
    required this.phase,
    required this.animate,
  });

  @override
  Widget build(BuildContext context) {
    Widget circle(double alpha) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: alpha),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
        );
    if (!animate) return circle(0.08);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        // Wrap the shared 0..1 clock by the row phase, fold to a triangle so it
        // eases 0.06 ↔ 0.14 smoothly.
        final t = (controller.value + phase) % 1.0;
        final tri = t < 0.5 ? t * 2 : (1 - t) * 2;
        return circle(0.06 + 0.08 * tri);
      },
    );
  }
}
