/// Dev-tunable seat-grid layout knobs.
///
/// Every seat dimension in the kit ultimately derives from these four values.
/// They are set once by the host app via [UTDAudioRoomConfig.seatLayout]; the
/// mounted [UTDAudioRoom] publishes that config to [UTDSeatLayout.active] so the
/// many size consumers that cannot reach the widget config — every
/// `UTDRoomMode.computeSeatSize` call site (grid, skeleton, overlays, gift &
/// foreground positioning) and the app-side `SeatMetrics` — all read the SAME
/// source and can never drift out of sync.
///
/// Defaults reproduce the kit's original look, so an app that passes nothing is
/// unaffected. Change the look by passing a `UTDSeatLayout(...)` to the config.
class UTDSeatLayout {
  /// Fraction of a seat slot the avatar circle fills (0–1). Higher = larger
  /// faces and less dead space inside each slot, which also visually tightens
  /// the vertical gap between rows.
  final double avatarRatio;

  /// Horizontal breathing room reserved across a row, expressed in seat-widths.
  /// Lower = larger seats and tighter horizontal gaps (a 4-column row uses
  /// `designWidth / (4 + rowPadding)` as its reference seat size). Keep it
  /// >= ~0.5 so the densest row still fits the narrowest phones.
  final double rowPadding;

  /// Vertical gap, in logical px, between seat rows in the built-in grid.
  final double rowSpacing;

  /// A direct multiplier applied to the final computed seat slot size. 1.0 is
  /// the computed default; 1.1 makes every seat 10% larger, 0.9 shrinks them.
  /// The kit's 52–120px safety clamp still applies as a hard rail, so an
  /// extreme value can never explode or collapse the grid.
  final double seatScale;

  /// Extra vertical gap (logical px) added between the first three rows (row 1
  /// -> 2 and row 2 -> 3), on top of [rowSpacing]. Rows after the third keep
  /// the plain [rowSpacing]. Used by the default 9-seat layout.
  final double firstRowGap;

  /// Extra space (logical px) above the whole seat block, pushing it down from
  /// the header.
  final double seatsTopPadding;

  const UTDSeatLayout({
    this.avatarRatio = 0.7,
    this.rowPadding = 1.0,
    this.rowSpacing = 5.0,
    this.seatScale = 1.0,
    this.firstRowGap = 0.0,
    this.seatsTopPadding = 0.0,
  });

  /// The kit's original shipped defaults.
  static const UTDSeatLayout defaults = UTDSeatLayout();

  /// The layout currently applied by the mounted [UTDAudioRoom]. Size consumers
  /// that can't reach the widget config read from here. Reset to [defaults] if a
  /// room is torn down without another taking its place is unnecessary — a new
  /// room overwrites it in `initState` before its first build.
  static UTDSeatLayout active = defaults;

  UTDSeatLayout copyWith({
    double? avatarRatio,
    double? rowPadding,
    double? rowSpacing,
    double? seatScale,
    double? firstRowGap,
    double? seatsTopPadding,
  }) =>
      UTDSeatLayout(
        avatarRatio: avatarRatio ?? this.avatarRatio,
        rowPadding: rowPadding ?? this.rowPadding,
        rowSpacing: rowSpacing ?? this.rowSpacing,
        seatScale: seatScale ?? this.seatScale,
        firstRowGap: firstRowGap ?? this.firstRowGap,
        seatsTopPadding: seatsTopPadding ?? this.seatsTopPadding,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UTDSeatLayout &&
          avatarRatio == other.avatarRatio &&
          rowPadding == other.rowPadding &&
          rowSpacing == other.rowSpacing &&
          seatScale == other.seatScale &&
          firstRowGap == other.firstRowGap &&
          seatsTopPadding == other.seatsTopPadding;

  @override
  int get hashCode =>
      Object.hash(
          avatarRatio, rowPadding, rowSpacing, seatScale, firstRowGap, seatsTopPadding);
}
