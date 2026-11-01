import 'dart:math' as math;
import 'package:general/src/core/index.dart';
import 'package:flutter_svga/flutter_svga.dart';
import 'package:general/src/core/cache/svga_movie_cache.dart';
import 'package:general/src/core/widgets/show_svga.dart';
import 'package:general/src/features/cp/presentation/intimate_space/intimate_space_data.dart';
import 'package:general/src/features/room/presentation/component/widgets/relation_link_overlay_widget.dart';
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
          builder:
              (
                context,
                cpPairs,
                _,
              ) => ValueListenableBuilder<List<RelationLink>>(
                valueListenable: RoomData.instance.relationLinks,
                builder: (context, links, _) {
                  if (cpPairs.isEmpty) return const SizedBox();

                  // CP level per seat pair, from the backend relation_link frame.
                  int levelOf(int a, int b) {
                    for (final l in links) {
                      if (RelationKindX.classify(l.type, '') !=
                          RelationKind.cp) {
                        continue;
                      }
                      if ((l.seatA == a && l.seatB == b) ||
                          (l.seatA == b && l.seatB == a)) {
                        return l.level;
                      }
                    }
                    return 0;
                  }

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
                          p1.y,
                          rows[p1.x].length,
                          totalWidth,
                          seatSize,
                        );
                        final cy1 = _seatCenterY(p1.x, seatSize, rowSpacingPx);
                        final cx2 = _seatCenterX(
                          p2.y,
                          rows[p2.x].length,
                          totalWidth,
                          seatSize,
                        );
                        final cy2 = _seatCenterY(p2.x, seatSize, rowSpacingPx);

                        hearts.add(
                          Positioned(
                            left: (cx1 + cx2) / 2 - heartSize / 2,
                            // Nudged up a hair on request — position is otherwise
                            // correct now.
                            top: (cy1 + cy2) / 2 - heartSize / 2 - 4.h,
                            width: heartSize,
                            height: heartSize,
                            child: _CpLinkEffect(
                              level: levelOf(pair[0], pair[1]),
                            ),
                          ),
                        );
                      }

                      return SizedBox(
                        width: totalWidth,
                        height: _gridHeight(
                          rows.length,
                          seatSize,
                          rowSpacingPx,
                        ),
                        child: Stack(clipBehavior: Clip.none, children: hearts),
                      );
                    },
                  );
                },
              ),
        ),
      ),
    );
  }

  static double _seatCenterX(
    int col,
    int numCols,
    double totalWidth,
    double seatSize,
  ) {
    final spacing = (totalWidth - numCols * seatSize) / (2 * numCols);
    return spacing * (2 * col + 1) + col * seatSize + seatSize / 2;
  }

  static double _seatCenterY(int row, double seatSize, double rowSpacingPx) {
    return row * (seatSize + rowSpacingPx) + seatSize / 2;
  }

  static double _gridHeight(
    int rowCount,
    double seatSize,
    double rowSpacingPx,
  ) {
    return rowCount * seatSize + (rowCount - 1) * rowSpacingPx;
  }
}

/// The CP level's admin effect when the level is known and has one,
/// otherwise the bundled CP heart.
class _CpLinkEffect extends StatefulWidget {
  final int level;

  const _CpLinkEffect({required this.level});

  @override
  State<_CpLinkEffect> createState() => _CpLinkEffectState();
}

class _CpLinkEffectState extends State<_CpLinkEffect>
    with SingleTickerProviderStateMixin {
  // Created in initState: a lazy `late final` would first be built inside
  // dispose() when no effect ever loaded, which looks up a dead ancestor.
  late final SVGAAnimationController _controller;
  bool _hasEffect = false;
  int _loadedLevel = -1;

  @override
  void initState() {
    super.initState();
    _controller = SVGAAnimationController(vsync: this);
    _load();
  }

  @override
  void didUpdateWidget(_CpLinkEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.level != _loadedLevel) _load();
  }

  Future<void> _load() async {
    final level = widget.level;
    _loadedLevel = level;
    MovieEntity? movie;
    final path = await RelationLevelEffects.effectFor('cp', level);
    if (path != null) {
      try {
        movie = await SvgaMovieCache.instance.loadFromUrl(
          EndPoints.getImage(path),
        );
      } catch (_) {}
    }
    if (!mounted || level != _loadedLevel) return;
    if (movie != null) {
      _controller.videoItem = movie;
      _controller.repeat();
    }
    setState(() => _hasEffect = movie != null);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _hasEffect
        ? SVGAImage(_controller, fit: BoxFit.contain)
        : ShowSVGA(
          svgaAssetPath: AssetsManager.cpLoveIcon,
          fit: BoxFit.contain,
        );
  }
}
