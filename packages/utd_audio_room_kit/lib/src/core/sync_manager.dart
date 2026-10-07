import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/seat_model.dart';

// Recovers room state after reconnect + periodic light sync every 60s
class UTDSyncManager {
  // Fetches seat map only (lightweight)
  final Future<List<SeatState>> Function() fetchSeatMap;

  // Fetches full room state from enter_room API
  final Future<Map<String, dynamic>> Function() fetchFullRoomState;

  // Apply full state diff (seats, mode, admins, PK, background)
  final void Function(Map<String, dynamic> state) applyFullState;

  // Apply updated seats only
  final void Function(List<SeatState> seats) applySeats;

  Timer? _periodicTimer;
  static const _syncInterval = Duration(seconds: 60);

  UTDSyncManager({
    required this.fetchSeatMap,
    required this.fetchFullRoomState,
    required this.applyFullState,
    required this.applySeats,
  });

  // Quick seat check — no UI interruption
  Future<void> lightSync() async {
    try {
      final seats = await fetchSeatMap();
      applySeats(seats);
    } catch (e) {
      debugPrint('[SyncManager] lightSync failed: $e');
    }
  }

  // Full room state recovery — after >15s disconnect
  Future<void> fullSync() async {
    try {
      final state = await fetchFullRoomState();
      applyFullState(state);
    } catch (e) {
      debugPrint('[SyncManager] fullSync failed: $e');
    }
  }

  // Start periodic light sync
  void startPeriodicSync() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(_syncInterval, (_) => lightSync());
  }

  void stopPeriodicSync() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  void dispose() => stopPeriodicSync();
}
