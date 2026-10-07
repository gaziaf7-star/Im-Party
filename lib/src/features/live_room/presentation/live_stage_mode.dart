import 'package:general/src/core/index.dart';

/// The broadcast shapes a host can choose before going live.
///
/// The mode is picked BEFORE the broadcast starts, not configured afterwards,
/// which is why there is no "multi-guest settings" screen anywhere.
///
/// The counts are TOTAL seats including the host — 4, 6 or 8 — because that is
/// what the grid geometry is defined in and what hosts read off the picker.
/// Eight is the ceiling: host in seat 0 plus seven guests.
/// [guestTiles] is the same number minus the host, and it is what actually caps
/// how many people can be pulled up.
///
/// [guestTiles] is stored on the room (`rooms.mode`) so the engine can enforce
/// the same number server-side — the kit sends no capacity at token time, so the
/// room row is the only place the engine can learn it from.
enum LiveStageMode {
  /// One broadcaster, no guest slots: the full-screen host layout.
  solo(seats: 1),

  four(seats: 4),

  six(seats: 6),

  eight(seats: 8);

  const LiveStageMode({required this.seats});

  /// Total seats, host included. This is the number shown in the picker.
  final int seats;

  /// Guests allowed on stage at once, the host excluded.
  int get guestTiles => seats - 1;

  /// `rooms.mode` holds the GUEST count directly. A live room never uses that
  /// column for an audio seat layout, so the two vocabularies cannot collide.
  int get roomMode => guestTiles;

  /// Numerals need no translation, so the seat modes label themselves and only
  /// the solo pill needs a string.
  String get label =>
      this == LiveStageMode.solo ? StringManager.liveModeSolo : '$seats';

  /// Resolves the room's stored guest count back to a broadcast shape.
  ///
  /// Snaps UP to the smallest shape that can hold the count, never down: a row
  /// saying 4 guests must render the 6-seat grid, because a 4-seat grid has only
  /// three guest cells and the fourth guest would have nowhere to appear.
  /// Falling back to solo would be worse still — that is the flat live.
  static LiveStageMode fromRoomMode(Object? mode) {
    final guests = int.tryParse('${mode ?? ''}') ?? 0;
    if (guests <= 0) return LiveStageMode.solo;

    for (final m in LiveStageMode.values) {
      if (m != LiveStageMode.solo && m.guestTiles >= guests) return m;
    }

    // More guests than any shape can hold: the largest grid is the honest
    // answer, and the engine caps the count anyway.
    return LiveStageMode.eight;
  }
}
