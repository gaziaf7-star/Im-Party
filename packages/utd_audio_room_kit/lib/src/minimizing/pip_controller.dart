import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:floating/floating.dart';

import '../controller/utd_room_controller.dart';
import '../models/minimize_config.dart';

/// Drives Android OS-level Picture-in-Picture for the audio room, *alongside*
/// the in-app minimize overlay ([UTDMinimizeController]).
///
/// Mechanism mirrors a typical prebuilt audio-room kit: it delegates to the `floating`
/// plugin's [OnLeavePiP], which on Android 12+ (API 31+) sets
/// `setAutoEnterEnabled(true)` so the OS auto-enters a system PiP window when
/// the user backgrounds the app (Home gesture) while on the room screen.
///
/// "In-room only" is enforced by lifecycle: [armIfEnabled] is called when the
/// room widget is mounted and connected; [disarm] is called when it is disposed
/// (minimized → overlay on the home feed, or leaving) and on room teardown — so
/// backgrounding from anywhere but the live room never triggers PiP.
///
/// Android-only: every method is a no-op on other platforms (the `floating`
/// MethodChannel is not registered on iOS, so calls are guarded to avoid
/// `MissingPluginException`). iOS / Android < 31 keep using the overlay.
class UTDPipController {
  UTDPipController(this._controller);

  final UTDRoomController _controller;

  /// `floating` exposes a process-wide singleton — never dispose/close it here.
  final Floating _floating = Floating();

  /// `true` while the app is actually shrunk into the system PiP window.
  /// [UTDAudioRoom] swaps its body to the compact PiP view while this is `true`.
  final ValueNotifier<bool> isInPip = ValueNotifier(false);

  bool _armed = false;
  bool _wasInPip = false;
  bool _disposed = false;

  /// Bumped by every [disarm]/[dispose]. An in-flight arm captures the value
  /// before its async platform round-trips and aborts/undoes if it changed —
  /// this closes the arm-after-disarm race (an `enable` landing *after* a
  /// `cancel` would otherwise leave PiP armed after the user left the room).
  int _gen = 0;

  /// Arms auto-enter-on-Home if PiP is enabled in config and supported by the
  /// device. Safe to call repeatedly (re-arms). No-op on iOS, when disabled in
  /// config, or when unavailable.
  Future<void> armIfEnabled() async {
    if (!Platform.isAndroid || _disposed) return;

    final config = _controller.minimize.config;
    if (config == null || !config.enableOSPip) return;

    final gen = _gen;
    bool available;
    try {
      available = await _floating.isPipAvailable;
    } catch (_) {
      // FEATURE_PICTURE_IN_PICTURE missing / channel error → treat as no PiP.
      return;
    }
    // A disarm()/dispose() landed during the availability round-trip — abort so
    // we never arm a room the user has already left.
    if (!available || gen != _gen) return;

    await _enableOnLeave(config);
  }

  Future<void> _enableOnLeave(UTDMinimizeConfig config) async {
    final gen = _gen;
    try {
      final status = await _floating.enable(
        OnLeavePiP(
          aspectRatio: Rational(config.pipAspectWidth, config.pipAspectHeight),
        ),
      );
      // If disarm()/dispose() ran while `enable` was in flight, the native
      // auto-enter flag may have been (re)set AFTER our cancel. Undo it so PiP
      // can never stay armed once the room screen is gone (the core
      // "in-room only" invariant). Reached only on Android.
      if (gen != _gen) {
        _armed = false;
        try {
          await _floating.cancelOnLeavePiP();
        } catch (_) {}
        return;
      }
      _armed = true;
      if (kDebugMode) debugPrint('[UTDPip] armed OnLeavePiP → $status');
    } on PlatformException catch (e) {
      // Android < 31: OnLeavePiP (auto-enter) is unsupported. No system PiP;
      // the in-app minimize overlay remains the fallback.
      if (kDebugMode) {
        debugPrint('[UTDPip] OnLeavePiP unavailable (SDK < 31?): ${e.message}');
      }
    } catch (e) {
      // e.g. RationalNotMatchingAndroidRequirementsException for a bad aspect.
      if (kDebugMode) debugPrint('[UTDPip] arm failed: $e');
    }
  }

  /// Reports the real OS PiP enter/exit transition.
  ///
  /// Driven by the host app's `pip_state_channel` handler, which forwards
  /// `MainActivity.onPictureInPictureModeChanged` (exactly one event per actual
  /// transition). This deliberately replaces `floating`'s `pipStatusStream`:
  /// the first access to that stream starts a process-wide
  /// `Timer.periodic(10ms)` native poll that the plugin never stops (no public
  /// cancel), a permanent battery/CPU drain for the rest of the process.
  /// Driving [isInPip] from the event channel means no perpetual poll is ever
  /// created. No-op on iOS / Android < 31, where the channel never fires.
  void setInPip(bool inPip) {
    if (_disposed) return;

    // User expanded or closed the PiP window while still in the room: re-arm so
    // the next Home gesture works again (re-arms so the next gesture works).
    if (_wasInPip && !inPip && _armed) {
      final config = _controller.minimize.config;
      if (config != null && config.enableOSPip) {
        _enableOnLeave(config);
      }
    }
    _wasInPip = inPip;

    if (isInPip.value != inPip) isInPip.value = inPip;
  }

  /// Cancels auto-enter so backgrounding no longer triggers PiP. Called when the
  /// room screen is no longer the foreground (minimized / left). No-op on iOS.
  Future<void> disarm() async {
    _gen++;
    _armed = false;
    _wasInPip = false;
    if (!_disposed && isInPip.value) isInPip.value = false;
    if (!Platform.isAndroid) return;
    try {
      await _floating.cancelOnLeavePiP();
    } catch (_) {
      // Best-effort; ignore channel errors during teardown.
    }
  }

  /// Final teardown — call from [UTDRoomController.dispose]. Disposes [isInPip]
  /// and cancels any pending auto-enter. Does NOT dispose the `floating`
  /// singleton (it is shared process-wide).
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _gen++;
    _armed = false;
    if (Platform.isAndroid) {
      // Fire-and-forget: make sure auto-enter is off after the room is gone.
      _floating.cancelOnLeavePiP().catchError((_) {});
    }
    isInPip.dispose();
  }
}
