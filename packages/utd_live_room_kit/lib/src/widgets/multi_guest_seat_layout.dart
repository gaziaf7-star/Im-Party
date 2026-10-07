import 'package:flutter/material.dart';

/// Single source of truth for multi-guest seat geometry (4 / 6 / 8 seats).
///
/// A multi-guest broadcast is a fixed GRID with the host occupying one cell —
/// not a full-bleed host video with tiles floating over it. That floating-strip
/// shape belongs to a SOLO live where one or two viewers happen to come up; used
/// for a 4- or 8-seat room it makes the broadcast look like a plain solo live,
/// which is exactly how "I chose 3 seats and got a flat live" happens.
///
/// Geometry rules:
/// - Cell size is derived from the available WIDTH, so the block's height grows
///   with the row count. An 8-seat grid is taller than a 4-seat one.
/// - The block is TOP-anchored; whatever vertical space is left below stays free
///   for the chat column.
/// - Seat indices are POSITIONAL and never compacted: visual cell `i` is always
///   seat `i`. Compacting would land a guest who asked for seat 5 in seat 2.
///
/// Layouts (host = index 0):
///   4-seat:  host 2 columns wide, full height, + 3 square guests stacked right.
///   6-seat:  host 2x2 top-left + 2 stacked right; bottom row of 3.
///   8-seat:  top row of 3 (host + 2), bottom row of 5.
typedef UTDSeatCellBuilder = Widget Function(BuildContext context, int index);

class UTDMultiGuestSeatLayout extends StatelessWidget {
  /// Total seats INCLUDING the host. Supported: 4, 6, 8. Anything else falls
  /// back to the 4-seat shape rather than guessing a geometry.
  final int seatCount;

  /// The host cell (index 0). Must fill its parent.
  final WidgetBuilder hostBuilder;

  /// Guest cells, `index` running 1..seatCount-1.
  final UTDSeatCellBuilder guestBuilder;

  /// Gap between cells, logical pixels.
  final double gap;

  const UTDMultiGuestSeatLayout({
    super.key,
    required this.seatCount,
    required this.hostBuilder,
    required this.guestBuilder,
    this.gap = 6,
  });

  /// The seat totals a host can pick.
  static const List<int> supportedCounts = [4, 6, 8];

  /// Snap an arbitrary total UP to the smallest supported grid that can hold
  /// it. Up, not down: snapping 7 down to 6 would leave the seventh occupant
  /// with no cell to render in.
  static int normalise(int total) {
    if (total <= 4) return 4;
    if (total <= 6) return 6;
    return 8;
  }

  /// The widest the block may be drawn without exceeding [maxHeight].
  ///
  /// The 4- and 6-seat blocks are exactly as tall as they are wide, so on a
  /// phone a full-width grid eats nearly half the screen and leaves the chat a
  /// sliver. Capping the WIDTH is how the height is capped, since every cell is
  /// derived from it.
  static double widthForMaxHeight(
    int seatCount,
    double availableWidth,
    double maxHeight, {
    double gap = 6,
  }) {
    final natural = heightFor(seatCount, availableWidth, gap: gap);
    if (natural <= maxHeight) return availableWidth;

    // Height scales linearly with width for every layout, so scaling the width
    // by the same ratio lands exactly on the cap.
    return availableWidth * (maxHeight / natural);
  }

  /// How tall the block will be for a given width.
  ///
  /// Exposed so whatever sits UNDER the grid — the chat column — can reserve
  /// exactly this much space instead of being overlapped. Kept here with the
  /// builders so the two can never disagree: an independently guessed height is
  /// how the chat ends up half-hidden behind the seats.
  static const double _aspect = 1.12;

  static double heightFor(int seatCount, double width, {double gap = 6}) {
    switch (normalise(seatCount)) {
      case 8:
        final topH = ((width - gap * 2) / 3) * _aspect;
        final botH = ((width - gap * 4) / 5) * _aspect;
        return topH + gap + botH;
      default:
        return width;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final w = constraints.maxWidth.isFinite ? constraints.maxWidth : 360.0;
        final block = switch (seatCount) {
          6 => _build6(ctx, w),
          8 => _build8(ctx, w),
          _ => _build4(ctx, w),
        };

        return Align(alignment: Alignment.topCenter, child: block);
      },
    );
  }

  /// Host spans 2 of 3 columns and the full height; 3 square guests stack on
  /// the right. Total height equals the width, so the block is a square.
  Widget _build4(BuildContext ctx, double w) {
    final cw = (w - gap * 2) / 3;
    final hostW = cw * 2 + gap;
    final h = cw * 3 + gap * 2;

    return SizedBox(
      width: w,
      height: h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: hostW, height: h, child: hostBuilder(ctx)),
          SizedBox(width: gap),
          Column(
            children: [
              SizedBox(width: cw, height: cw, child: guestBuilder(ctx, 1)),
              SizedBox(height: gap),
              SizedBox(width: cw, height: cw, child: guestBuilder(ctx, 2)),
              SizedBox(height: gap),
              SizedBox(width: cw, height: cw, child: guestBuilder(ctx, 3)),
            ],
          ),
        ],
      ),
    );
  }

  /// Host is a 2x2 square top-left with two cells stacked to its right, then a
  /// bottom row of three. Every cell is a true square here.
  Widget _build6(BuildContext ctx, double w) {
    final cw = (w - gap * 2) / 3;
    final hostSide = cw * 2 + gap;

    return SizedBox(
      width: w,
      height: hostSide + gap + cw,
      child: Column(
        children: [
          SizedBox(
            height: hostSide,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: hostSide,
                  height: hostSide,
                  child: hostBuilder(ctx),
                ),
                SizedBox(width: gap),
                Column(
                  children: [
                    SizedBox(
                        width: cw, height: cw, child: guestBuilder(ctx, 1)),
                    SizedBox(height: gap),
                    SizedBox(
                        width: cw, height: cw, child: guestBuilder(ctx, 2)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: gap),
          SizedBox(
            height: cw,
            child: Row(
              children: [
                SizedBox(width: cw, height: cw, child: guestBuilder(ctx, 3)),
                SizedBox(width: gap),
                SizedBox(width: cw, height: cw, child: guestBuilder(ctx, 4)),
                SizedBox(width: gap),
                SizedBox(width: cw, height: cw, child: guestBuilder(ctx, 5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Three big cells on top (host + 2), five smaller ones below.
  Widget _build8(BuildContext ctx, double w) {
    final topW = (w - gap * 2) / 3;
    final topH = topW * _aspect;
    final botW = (w - gap * 4) / 5;
    final botH = botW * _aspect;

    return SizedBox(
      width: w,
      height: topH + gap + botH,
      child: Column(
        children: [
          SizedBox(
            height: topH,
            child: Row(
              children: [
                SizedBox(width: topW, height: topH, child: hostBuilder(ctx)),
                SizedBox(width: gap),
                SizedBox(
                    width: topW, height: topH, child: guestBuilder(ctx, 1)),
                SizedBox(width: gap),
                SizedBox(
                    width: topW, height: topH, child: guestBuilder(ctx, 2)),
              ],
            ),
          ),
          SizedBox(height: gap),
          SizedBox(
            height: botH,
            child: Row(
              children: [
                for (int i = 0; i < 5; i++) ...[
                  if (i > 0) SizedBox(width: gap),
                  SizedBox(
                    width: botW,
                    height: botH,
                    child: guestBuilder(ctx, 3 + i),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The "+" placeholder shown in a seat nobody is on.
///
/// One implementation for host and viewer alike — the reference app duplicated
/// it and the two copies drifted (different corner radii).
class UTDEmptySeatCell extends StatelessWidget {
  /// Cyan ring, matching the reference seat art.
  static const Color ring = Color(0xFF4FD1C5);

  final VoidCallback? onTap;

  const UTDEmptySeatCell({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Opaque so the tap lands here and not on the stage below (which counts
      // taps as hearts).
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: LayoutBuilder(
            builder: (_, c) {
              final side = c.maxWidth < c.maxHeight ? c.maxWidth : c.maxHeight;
              final size = (side * 0.38).clamp(20.0, 90.0);

              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                  border: Border.all(
                    color: ring.withValues(alpha: 0.85),
                    width: 1.6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ring.withValues(alpha: 0.20),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.add,
                    color: ring.withValues(alpha: 0.85),
                    size: size * 0.5,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
