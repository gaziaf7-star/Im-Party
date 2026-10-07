import 'package:equatable/equatable.dart';

/// Safely parses a value that may be `bool`, `int` (0/1), or `null` into a bool.
/// Handles the case where the REST API returns `locked: 0` (int) while
/// the data-channel `_seat_update` returns `locked: false` (bool).
bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value != 0;
  return false;
}

/// Represents the state of a single seat in the audio room.
class SeatState extends Equatable {
  /// Seat index (0 = host seat).
  final int index;

  /// User ID occupying this seat. `null` means empty.
  final String? occupantUserId;

  /// Whether this seat is locked by admin.
  final bool isLocked;

  /// Whether the occupant's mic is muted.
  final bool isMuted;

  /// Identity this seat is reserved for (e.g., host). `null` means not reserved.
  /// Only the reserved identity can sit here. Cannot be kicked/locked.
  final String? reservedFor;

  /// Custom attributes of the occupant (e.g., 'fr', 'avatar', 'frt', 'cn').
  final Map<String, String> attributes;

  const SeatState({
    required this.index,
    this.occupantUserId,
    this.isLocked = false,
    this.isMuted = false,
    this.reservedFor,
    this.attributes = const {},
  });

  /// Whether the seat is empty and not locked.
  bool get isEmpty => occupantUserId == null && !isLocked;

  /// Whether the seat has an occupant.
  bool get isOccupied => occupantUserId != null;

  /// Whether this seat is reserved for a specific user.
  bool get isReserved => reservedFor != null;

  SeatState copyWith({
    int? index,
    String? Function()? occupantUserId,
    bool? isLocked,
    bool? isMuted,
    String? Function()? reservedFor,
    Map<String, String>? attributes,
  }) {
    return SeatState(
      index: index ?? this.index,
      occupantUserId:
          occupantUserId != null ? occupantUserId() : this.occupantUserId,
      isLocked: isLocked ?? this.isLocked,
      isMuted: isMuted ?? this.isMuted,
      reservedFor: reservedFor != null ? reservedFor() : this.reservedFor,
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
      isLocked: _parseBool(json['locked']),
      reservedFor: json['reserved_for'] as String?,
      attributes: parsedAttrs,
    );
  }

  @override
  List<Object?> get props =>
      [index, occupantUserId, isLocked, isMuted, reservedFor, attributes];
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
