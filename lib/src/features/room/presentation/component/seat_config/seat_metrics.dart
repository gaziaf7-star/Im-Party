import 'package:utd_audio_room_kit/utd_audio_room_kit.dart' show UTDSeatLayout;

/// Derives every seat sub-element dimension from a single seat size, so seats,
/// avatars, frames, names, mute icons, charisma badges and index labels stay
/// proportional in every room mode and on every device.
///
/// The seat size itself comes from `UTDRoomMode.computeSeatSize`, which already
/// scales with the device. Therefore **every value here is device-real logical
/// px** and callers MUST NOT re-apply ScreenUtil (`.w`/`.h`/`.r`). Fonts must be
/// applied via `TextStyle.copyWith(fontSize: ...)` rather than the `.size()`
/// (`.sp`) extension, otherwise the device scaling is applied twice.
class SeatMetrics {
  /// The full seat slot size.
  final double seat;

  /// The avatar diameter (the kit lays the avatar out at `seat * 0.7`).
  final double avatar;

  const SeatMetrics._(this.seat, this.avatar);

  /// The single source of truth for how big the avatar/circle is relative to
  /// the seat slot. EVERY seat state (occupied avatar, empty, locked) derives
  /// its diameter from this one constant, so the three can never drift apart —
  /// change it here to resize all of them together.
  ///
  /// Read from the kit's active seat layout (set in room_screen.dart) so the
  /// app-side seat widgets and the kit's own seat grid always agree.
  static double get avatarRatio => UTDSeatLayout.active.avatarRatio;

  /// Build from the full seat slot size — the canonical entry point. The kit
  /// hands every seat builder (avatar/empty/locked) the full slot, so all three
  /// go through here and get the identical [avatar] diameter.
  factory SeatMetrics.forSeat(double seatSize) =>
      SeatMetrics._(seatSize, seatSize * avatarRatio);

  /// Build from an avatar diameter (used by sub-elements that only know the
  /// avatar size, e.g. the charisma/mic overlays).
  factory SeatMetrics.forAvatar(double avatarDiameter) =>
      SeatMetrics._(avatarDiameter / avatarRatio, avatarDiameter);

  /// Frame ring drawn around the avatar. Increased from 1.18 -> 1.35 -> 1.5
  /// -> 1.8, then pulled back to 1.5 -- 1.8 badly overlapped neighboring
  /// seats in the dense 30-seat layout. Avatar photo size is untouched
  /// (this only scales the frame, per request).
  ///
  /// Scales with the seat slot: dense rooms keep the frame about the photo's
  /// size, sparse rooms (9 seats) get a little more.
  double get frame {
    final k = (1.0 + (seat - 66) / 34 * 0.12).clamp(1.0, 1.12).toDouble();
    return avatar * k;
  }

  /// Display-name font size (was a fixed `8`).
  double get nameFont => (avatar * 0.18).clamp(9.0, 15.0);

  /// Vertical offset of the name below the avatar (was a fixed `-5`).
  double get namePosBottom => -(avatar * 0.08);

  /// Name is capped to the slot width so long names never bleed into neighbours.
  double get nameMaxWidth => seat;

  /// White mute-indicator circle, bottom-right of the avatar.
  double get micCircle => avatar * 0.26;

  /// The mute glyph inside the circle (replaces a fixed `Image.asset(scale: 7)`).
  double get micInner => micCircle * 0.6;

  /// Charisma badge total/count font (was fixed `9`/`10`).
  double get charismaFont => (avatar * 0.16).clamp(8.0, 13.0);

  /// Charisma heart icon (was a fixed `10`).
  double get charismaIcon => avatar * 0.18;

  /// Gap between the heart icon and the count (was a fixed `3.wBox`).
  double get charismaGap => avatar * 0.05;

  /// Empty/locked seat index label font (was a fixed `12`).
  double get indexFont => (seat * 0.15).clamp(9.0, 14.0);
}
