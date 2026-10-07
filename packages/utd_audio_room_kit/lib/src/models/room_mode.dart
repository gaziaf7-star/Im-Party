import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'seat_layout.dart';
import 'seat_model.dart';

typedef UTDSeatContainerBuilder = Widget Function(
  List<SeatState> seats,
  Widget Function(int seatIndex) seatWidgetCreator,
);

typedef UTDBackgroundBuilder = Widget Function(BuildContext context);

class UTDRoomMode {
  final String id;
  final int seatCount;
  final List<List<int>> rows;
  final double? seatSize;
  final UTDSeatContainerBuilder? containerBuilder;
  final UTDBackgroundBuilder? backgroundBuilder;
  final String? displayName;

  const UTDRoomMode({
    required this.id,
    required this.seatCount,
    required this.rows,
    this.seatSize,
    this.containerBuilder,
    this.backgroundBuilder,
    this.displayName,
  });

  static const defaultMode = UTDRoomMode(
    id: '3',
    seatCount: 9,
    rows: [
      [0],
      [1, 2, 3, 4],
      [5, 6, 7, 8],
    ],
  );

  /// Single source of truth for the seat slot size, in device-real logical px.
  ///
  /// The size is derived from a device-INDEPENDENT reference at the design width
  /// (so the densest row just fits), then scaled SUB-LINEARLY (sqrt) with the
  /// real width — phones stay close to their design size while tablets grow
  /// gently instead of ballooning. The result is clamped to sane bounds.
  ///
  /// IMPORTANT: every consumer (the kit's [UTDSeatGrid] layout, the avatar
  /// builder, the app's mode widgets, and the CP heart overlay which re-derives
  /// seat centres from this value) MUST read the size from this one method. Keep
  /// the clamp/curve HERE — never clamp at a call site — or those overlays will
  /// desync from the seats.
  double computeSeatSize(double screenWidth) {
    const designWidth = 400.0; // matches the app's ScreenUtil designSize
    const refCap = 88.0; // caps low-column modes (2-col → 133) to art size
    const minSize = 52.0;
    const maxSize = 120.0;

    // Dev-tunable knobs, published from UTDAudioRoomConfig.seatLayout.
    //   rowPadding: total horizontal breathing room reserved across a row, in
    //     seat-widths — lower = larger seats and tighter gaps (a 4-col row uses
    //     400/(4+rowPadding); e.g. 1.0→80, 0.7→85).
    //   seatScale: a direct multiplier on the final slot size.
    final layout = UTDSeatLayout.active;

    final maxPerRow =
        rows.fold<int>(0, (max, row) => row.length > max ? row.length : max);
    // Reference seat size at the design width (independent of the real device).
    final refRaw = seatSize ??
        (maxPerRow == 0 ? 80.0 : designWidth / (maxPerRow + layout.rowPadding));
    // An explicit per-mode seatSize is honoured as-is; computed sizes are capped
    // so wide-but-sparse modes don't overflow their background art.
    final ref = seatSize != null ? refRaw : math.min(refRaw, refCap);

    final factor = math.sqrt(screenWidth / designWidth); // gentle growth
    // The 52–120 clamp stays a hard safety rail even when seatScale is set, so
    // an extreme value can never explode or collapse the grid.
    // Never let the densest row be wider than the screen: seatScale and the
    // sqrt growth can otherwise push 4 seats past the edge (RenderFlex
    // overflow). Each seat gets at most screenWidth / seats-per-row.
    final fit = maxPerRow == 0 ? maxSize : screenWidth / maxPerRow;
    final upper = math.min(maxSize, math.max(minSize, fit));
    return (ref * factor * layout.seatScale).clamp(minSize, upper);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UTDRoomMode && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
