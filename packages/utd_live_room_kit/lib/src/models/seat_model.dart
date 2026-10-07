import 'package:equatable/equatable.dart';

/// Represents one tile in the live room: index 0 = host, 1..N = guest tiles.
/// (On the wire this is a backend "seat" — the tile IS the seat.)
class SeatState extends Equatable {
  /// Tile/seat index (0 = host).
  final int index;

  /// User ID occupying this tile. `null` means empty.
  final String? occupantUserId;

  /// Custom attributes of the occupant (e.g., 'name', 'avatar', 'fr', 'frt').
  final Map<String, String> attributes;

  const SeatState({
    required this.index,
    this.occupantUserId,
    this.attributes = const {},
  });

  /// Whether the tile has an occupant.
  bool get isOccupied => occupantUserId != null;

  SeatState copyWith({
    int? index,
    String? Function()? occupantUserId,
    Map<String, String>? attributes,
  }) {
    return SeatState(
      index: index ?? this.index,
      occupantUserId:
          occupantUserId != null ? occupantUserId() : this.occupantUserId,
      attributes: attributes ?? this.attributes,
    );
  }

  /// Parse a seat from backend JSON.
  ///
  /// Supports **both** response shapes:
  /// - Data-channel `_seat_update` / room metadata `_seats`:
  ///   `{ "index": 0, "identity": "host-user", "locked": false, "reserved_for": "host-user" }`
  /// - REST API `GET /seats`:
  ///   `{ "seat_index": 0, "occupant_identity": "host-user", "locked": 0, "reserved_for": "host-user" }`
  factory SeatState.fromBackendJson(Map<String, dynamic> json) {
    // Parse attributes from backend (fr, frt, avatar, cn, name, etc.)
    final rawAttrs = json['attributes'];
    final Map<String, String> parsedAttrs = {};
    if (rawAttrs is Map) {
      for (final entry in rawAttrs.entries) {
        if (entry.value != null) {
          parsedAttrs[entry.key.toString()] = entry.value.toString();
        }
      }
    }

    // Also include 'name' in attributes if present at the top level
    final name = json['name'] as String?;
    if (name != null && name.isNotEmpty) {
      parsedAttrs['name'] = name;
    }

    return SeatState(
      index: ((json['seat_index'] ?? json['index']) as num?)?.toInt() ?? 0,
      occupantUserId:
          (json['occupant_identity'] ?? json['identity']) as String?,
      attributes: parsedAttrs,
    );
  }

  @override
  List<Object?> get props => [index, occupantUserId, attributes];
}

/// Represents a pending speaker request.
class SpeakerRequest extends Equatable {
  final int id;
  final String identity;
  final String? createdAt;

  const SpeakerRequest({
    required this.id,
    required this.identity,
    this.createdAt,
  });

  factory SpeakerRequest.fromJson(Map<String, dynamic> json) {
    return SpeakerRequest(
      id: (json['id'] as num?)?.toInt() ?? 0,
      identity: json['identity'] as String? ?? '',
      createdAt: json['created_at'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, identity, createdAt];
}

/// Full seat state from the backend `_seats` namespace.
///
/// Supports **both** response shapes:
/// - Data-channel / metadata: `{ "count": 9, "mode": "free", ... }`
/// - REST API `GET /seats`: `{ "seat_count": 9, "seat_mode": "free", ... }`
class RoomSeatState extends Equatable {
  final int count;
  final String mode;
  final String? modeId;
  final List<SeatState> seats;
  final List<SpeakerRequest> requests;

  const RoomSeatState({
    required this.count,
    required this.mode,
    this.modeId,
    required this.seats,
    required this.requests,
  });

  factory RoomSeatState.fromJson(Map<String, dynamic> json) {
    final seatsList = (json['seats'] as List<dynamic>?)
            ?.map((s) => SeatState.fromBackendJson(s as Map<String, dynamic>))
            .toList() ??
        [];

    final requestsList = (json['requests'] as List<dynamic>?)
            ?.map((r) => SpeakerRequest.fromJson(r as Map<String, dynamic>))
            .toList() ??
        [];

    return RoomSeatState(
      count: ((json['seat_count'] ?? json['count']) as num?)?.toInt() ??
          seatsList.length,
      mode: (json['seat_mode'] ?? json['mode']) as String? ?? 'free',
      modeId: json['mode_id'] as String?,
      seats: seatsList,
      requests: requestsList,
    );
  }

  @override
  List<Object?> get props => [count, mode, modeId, seats, requests];
}
