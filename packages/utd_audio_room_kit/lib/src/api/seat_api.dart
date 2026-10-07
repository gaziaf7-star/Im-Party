import 'utd_api_client.dart';

/// REST API client for all seat management endpoints.
///
/// Base path: `/api/v1/rooms/:name/seats/...`
///
/// See: UTD Stream Engine — UIKit Developer Guide § Seat Management APIs
class UTDSeatApi {
  final UTDApiClient _client;

  UTDSeatApi(this._client);

  // ---------------------------------------------------------------------------
  // Setup Seats
  // ---------------------------------------------------------------------------

  /// Configures the seat system for a room. Only host/admin can call this.
  ///
  /// [roomId] — RTC room name (e.g. "p9325906999_32")
  /// [identity] — the actor (must be host/admin)
  /// [seatCount] — number of seats (1-100)
  /// [seatMode] — "free" or "request"
  ///
  /// POST /api/v1/rooms/:name/seats/setup
  Future<Map<String, dynamic>> setupSeats({
    required String roomId,
    required String identity,
    required int seatCount,
    required String seatMode,
    String? modeId,
  }) {
    final data = <String, dynamic>{
      'identity': identity,
      'seat_count': seatCount,
      'seat_mode': seatMode,
    };
    if (modeId != null) data['mode_id'] = modeId;

    return _client.post(
      '/api/v1/rooms/$roomId/seats/setup',
      data: data,
    );
  }

  // ---------------------------------------------------------------------------
  // Get Seats
  // ---------------------------------------------------------------------------

  /// Returns current seat state including occupants, locks, and pending requests.
  ///
  /// GET /api/v1/rooms/:name/seats
  Future<Map<String, dynamic>> getSeats({
    required String roomId,
  }) {
    return _client.get('/api/v1/rooms/$roomId/seats');
  }

  // ---------------------------------------------------------------------------
  // Take Seat
  // ---------------------------------------------------------------------------

  /// Takes a seat at the given index.
  ///
  /// In `free` mode: takes immediately if available and unlocked.
  /// In `request` mode: requires a prior approved speaker request (403 otherwise).
  /// Returns `409` if user is already seated or seat is occupied.
  /// On success, backend upgrades user permissions to `canPublish: true`.
  ///
  /// POST /api/v1/rooms/:name/seats/:index/take
  Future<Map<String, dynamic>> takeSeat({
    required String roomId,
    required int seatIndex,
    required String identity,
  }) {
    return _client.post(
      '/api/v1/rooms/$roomId/seats/$seatIndex/take',
      data: {'identity': identity},
    );
  }

  // ---------------------------------------------------------------------------
  // Leave Seat
  // ---------------------------------------------------------------------------

  /// Removes the user from their current seat.
  /// Backend downgrades permissions back to audience (canPublish: false).
  ///
  /// POST /api/v1/rooms/:name/seats/leave
  Future<Map<String, dynamic>> leaveSeat({
    required String roomId,
    required String identity,
  }) {
    return _client.post(
      '/api/v1/rooms/$roomId/seats/leave',
      data: {'identity': identity},
    );
  }

  // ---------------------------------------------------------------------------
  // Kick from Seat (host/admin only)
  // ---------------------------------------------------------------------------

  /// Removes the occupant from the seat. Admin cannot kick the host.
  /// Backend downgrades the kicked user's permissions to audience.
  ///
  /// [identity] — the actor performing the kick (must be host/admin)
  ///
  /// POST /api/v1/rooms/:name/seats/:index/kick
  Future<Map<String, dynamic>> kickFromSeat({
    required String roomId,
    required int seatIndex,
    required String identity,
  }) {
    return _client.post(
      '/api/v1/rooms/$roomId/seats/$seatIndex/kick',
      data: {'identity': identity},
    );
  }

  // ---------------------------------------------------------------------------
  // Lock Seat (host/admin only)
  // ---------------------------------------------------------------------------

  /// Locks a seat so no one can sit in it.
  /// If someone is currently seated, they are kicked first.
  /// Admin can't lock the host's seat.
  ///
  /// POST /api/v1/rooms/:name/seats/:index/lock
  Future<Map<String, dynamic>> lockSeat({
    required String roomId,
    required int seatIndex,
    required String identity,
  }) {
    return _client.post(
      '/api/v1/rooms/$roomId/seats/$seatIndex/lock',
      data: {'identity': identity},
    );
  }

  // ---------------------------------------------------------------------------
  // Unlock Seat (host/admin only)
  // ---------------------------------------------------------------------------

  /// Unlocks a previously locked seat.
  ///
  /// POST /api/v1/rooms/:name/seats/:index/unlock
  Future<Map<String, dynamic>> unlockSeat({
    required String roomId,
    required int seatIndex,
    required String identity,
  }) {
    return _client.post(
      '/api/v1/rooms/$roomId/seats/$seatIndex/unlock',
      data: {'identity': identity},
    );
  }

  // ---------------------------------------------------------------------------
  // Mute Seat Occupant (host/admin only)
  // ---------------------------------------------------------------------------

  /// Mutes the audio track of the participant sitting in this seat
  /// via the RTC server-side API. Admin cannot mute the host.
  ///
  /// POST /api/v1/rooms/:name/seats/:index/mute
  Future<Map<String, dynamic>> muteSeat({
    required String roomId,
    required int seatIndex,
    required String identity,
  }) {
    return _client.post(
      '/api/v1/rooms/$roomId/seats/$seatIndex/mute',
      data: {'identity': identity},
    );
  }

  // ---------------------------------------------------------------------------
  // Unmute Seat Occupant (host/admin only)
  // ---------------------------------------------------------------------------

  /// Unmutes the audio track of the participant sitting in this seat.
  ///
  /// POST /api/v1/rooms/:name/seats/:index/unmute
  Future<Map<String, dynamic>> unmuteSeat({
    required String roomId,
    required int seatIndex,
    required String identity,
  }) {
    return _client.post(
      '/api/v1/rooms/$roomId/seats/$seatIndex/unmute',
      data: {'identity': identity},
    );
  }

  // ---------------------------------------------------------------------------
  // Move to Another Seat
  // ---------------------------------------------------------------------------

  /// Atomically moves the user from their current seat to [targetSeat].
  ///
  /// - No permission gap — user stays `canPublish: true` throughout.
  /// - No UI flicker — only one `_seat_update` is sent.
  /// - If the target seat was taken during the operation, the user stays on
  ///   their original seat (automatic rollback).
  /// - Respects reserved seats and lock rules (same as take).
  ///
  /// POST /api/v1/rooms/:name/seats/move
  ///
  /// Returns: `{ "from": 3, "to": 5 }`
  Future<Map<String, dynamic>> moveSeat({
    required String roomId,
    required String identity,
    required int targetSeat,
  }) {
    return _client.post(
      '/api/v1/rooms/$roomId/seats/move',
      data: {
        'identity': identity,
        'target_seat': targetSeat,
      },
    );
  }
}
