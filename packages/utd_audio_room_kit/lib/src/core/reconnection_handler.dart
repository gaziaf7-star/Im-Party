import 'dart:async';

import 'package:flutter/foundation.dart';

// Tiered reconnection: <15s light sync, <60s full sync, >60s force exit
class UTDReconnectionHandler {
  final Future<void> Function() onLightSync;
  final Future<void> Function() onFullSync;
  final VoidCallback onForceExit;

  DateTime? _disconnectedAt;
  Timer? _exitTimer;

  static const _lightThreshold = Duration(seconds: 15);
  static const _fullThreshold = Duration(seconds: 60);

  UTDReconnectionHandler({
    required this.onLightSync,
    required this.onFullSync,
    required this.onForceExit,
  });

  // Called when the RTC engine reports a disconnect
  void onDisconnected() {
    // Cancel any prior timer first — a reconnecting→disconnected flap can call
    // this again, which would otherwise leak a second timer and double-fire
    // onForceExit.
    _exitTimer?.cancel();
    _disconnectedAt = DateTime.now();
    _exitTimer = Timer(_fullThreshold, () {
      onForceExit();
      _reset();
    });
  }

  // Called when the RTC engine reports a reconnect
  Future<void> onReconnected() async {
    _exitTimer?.cancel();
    if (_disconnectedAt == null) return;

    final elapsed = DateTime.now().difference(_disconnectedAt!);
    _disconnectedAt = null;

    if (elapsed < _lightThreshold) {
      await onLightSync();
    } else if (elapsed < _fullThreshold) {
      await onFullSync();
    } else {
      onForceExit();
    }
  }

  void _reset() {
    _disconnectedAt = null;
    _exitTimer?.cancel();
    _exitTimer = null;
  }

  void dispose() => _reset();
}
