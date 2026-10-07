import 'dart:math' as math;
import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/show_svga.dart';
import 'package:general/src/features/room/room.dart';

class CpOverlayWidget extends StatelessWidget {
  final List<List<int>> rows;
  final double seatSize;
  final double rowSpacing;
  final double topOffset;

  const CpOverlayWidget({
    super.key,
    required this.rows,
    required this.seatSize,
    this.rowSpacing = 10,
    this.topOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: topOffset,
      child: IgnorePointer(
        child: ValueListenableBuilder<List<List<int>>>(
          valueListenable: RoomData.instance.showCp,
          builder: (context, cpPairs, _) {
            if (cpPairs.isEmpty) return const SizedBox();

            final posMap = <int, math.Point<int>>{};
            for (int r = 0; r < rows.length; r++) {
              for (int c = 0; c < rows[r].length; c++) {
                posMap[rows[r][c]] = math.Point(r, c);
              }
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                // Back to the original, smaller size on request (the 1.3x
                // bump made it too big once the position itself was fixed).
                final heartSize = seatSize * 0.8;
                final rowSpacingPx = rowSpacing.h;

                final hearts = <Widget>[];
                for (final pair in cpPairs) {
                  if (pair.length != 2) continue;
                  final p1 = posMap[pair[0]];
                  final p2 = posMap[pair[1]];
                  if (p1 == null || p2 == null) continue;
                  // Only draw the connector when the two CP partners are
                  // actually seated next to each other — same row, adjacent
                  // columns. Otherwise (different rows, or same row but not
                  // neighbouring) it stays hidden, on request.
                  if (p1.x != p2.x || (p1.y - p2.y).abs() != 1) continue;

                  final cx1 = _seatCenterX(
                      p1.y, rows[p1.x].length, totalWidth, seatSize);
                  final cy1 = _seatCenterY(p1.x, seatSize, rowSpacingPx);
                  final cx2 = _seatCenterX(
                      p2.y, rows[p2.x].length, totalWidth, seatSize);
                  final cy2 = _seatCenterY(p2.x, seatSize, rowSpacingPx);

                  hearts.add(
                    Positioned(
                      left: (cx1 + cx2) / 2 - heartSize / 2,
                      // Nudged up a hair on request — position is otherwise
                      // correct now.
                      top: (cy1 + cy2) / 2 - heartSize / 2 - 4.h,
                      width: heartSize,
                      height: heartSize,
                      child: ShowSVGA(
                        svgaAssetPath: AssetsManager.cpLoveIcon,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                }

                return SizedBox(
                  width: totalWidth,
                  height: _gridHeight(rows.length, seatSize, rowSpacingPx),
                  child: Stack(clipBehavior: Clip.none, children: hearts),
                );
              },
            );
          },
        ),
      ),
    );
  }

  static double _seatCenterX(
      int col, int numCols, double totalWidth, double seatSize) {
    final spacing = (totalWidth - numCols * seatSize) / (2 * numCols);
    return spacing * (2 * col + 1) + col * seatSize + seatSize / 2;
  }

  static double _seatCenterY(int row, double seatSize, double rowSpacingPx) {
    return row * (seatSize + rowSpacingPx) + seatSize / 2;
  }

  static double _gridHeight(
      int rowCount, double seatSize, double rowSpacingPx) {
    return rowCount * seatSize + (rowCount - 1) * rowSpacingPx;
  }
}
