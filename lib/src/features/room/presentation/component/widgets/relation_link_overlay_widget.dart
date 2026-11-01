import 'dart:math' as math;
import 'package:flutter_svga/flutter_svga.dart';
import 'package:general/src/core/cache/svga_movie_cache.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/cp/presentation/intimate_space/intimate_space_data.dart';
import 'package:general/src/features/room/room.dart';

/// One entry of the backend `relation_link` data-channel frame (also shipped
/// as `relation_links` in enter_room):
/// {type, level, user_a, user_b, seat_a, seat_b, effect, effect_type}
class RelationLink {
  final String type;
  final int level;
  final int seatA;
  final int seatB;
  final String effect;

  const RelationLink({
    required this.type,
    required this.level,
    required this.seatA,
    required this.seatB,
    required this.effect,
  });

  static int _int(dynamic v) => v is int ? v : int.tryParse('$v') ?? -1;

  static List<RelationLink> parseList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map(
          (m) => RelationLink(
            type: '${m['type'] ?? ''}',
            level: _int(m['level']),
            seatA: _int(m['seat_a']),
            seatB: _int(m['seat_b']),
            effect: '${m['effect'] ?? ''}',
          ),
        )
        .where((l) => l.seatA >= 0 && l.seatB >= 0)
        .toList();
  }
}

/// Finds the mic-link animation the admin set for a relation [type] at a
/// [level] (the level's `effect`, else its `image` when that is an SVGA).
/// Level tables are fetched once per room and reused.
class RelationLevelEffects {
  RelationLevelEffects._();

  static final _levels = <RelationKind, Future<List<IntimateLevel>>>{};

  static void clear() => _levels.clear();

  static Future<String?> effectFor(String type, int level) async {
    if (level <= 0) return null;
    final kind = RelationKindX.classify(type, '');
    final future = _levels[kind] ??= IntimateSpaceRepo.instance.levels(kind);
    final levels = await future;
    // Don't keep a failed / empty fetch, so the next link retries it.
    if (levels.isEmpty) _levels.remove(kind);
    final match = levels.where((l) => l.level == level).firstOrNull;
    if (match == null) return null;
    for (final path in [match.effect, match.image]) {
      if (path.toLowerCase().endsWith('.svga')) return path;
    }
    return null;
  }
}

/// Draws the relation (best friend, …) handshake effect between
/// two related users when they sit next to each other. Same geometry as
/// [CpOverlayWidget].
class RelationLinkOverlayWidget extends StatelessWidget {
  final List<List<int>> rows;
  final double seatSize;
  final double rowSpacing;
  final double topOffset;

  const RelationLinkOverlayWidget({
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
        child: ValueListenableBuilder<List<RelationLink>>(
          valueListenable: RoomData.instance.relationLinks,
          builder: (context, links, _) {
            if (links.isEmpty) return const SizedBox();

            final posMap = <int, math.Point<int>>{};
            for (int r = 0; r < rows.length; r++) {
              for (int c = 0; c < rows[r].length; c++) {
                posMap[rows[r][c]] = math.Point(r, c);
              }
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final effectSize = seatSize * 0.55;
                final rowSpacingPx = rowSpacing.h;

                final effects = <Widget>[];
                for (final link in links) {
                  // CP pairs are drawn by [CpOverlayWidget].
                  if (RelationKindX.classify(link.type, '') ==
                      RelationKind.cp) {
                    continue;
                  }
                  final p1 = posMap[link.seatA];
                  final p2 = posMap[link.seatB];
                  if (p1 == null || p2 == null) continue;
                  // Only when seated side by side (same row, adjacent cols).
                  if (p1.x != p2.x || (p1.y - p2.y).abs() != 1) continue;

                  final cx1 = _seatCenterX(
                    p1.y,
                    rows[p1.x].length,
                    totalWidth,
                    seatSize,
                  );
                  final cx2 = _seatCenterX(
                    p2.y,
                    rows[p2.x].length,
                    totalWidth,
                    seatSize,
                  );
                  final cy = _seatCenterY(p1.x, seatSize, rowSpacingPx);

                  effects.add(
                    Positioned(
                      left: (cx1 + cx2) / 2 - effectSize / 2,
                      top: cy - effectSize / 2 - 4.h,
                      width: effectSize,
                      height: effectSize,
                      child: _RelationEffect(link: link, size: effectSize),
                    ),
                  );
                }

                return SizedBox(
                  width: totalWidth,
                  height: _gridHeight(rows.length, seatSize, rowSpacingPx),
                  child: Stack(clipBehavior: Clip.none, children: effects),
                );
              },
            );
          },
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

/// Plays the effect the admin set for this relation's level; when there is
/// none, the bundled handshake SVGA. The backend link `effect`
/// (`links/<type>/lvN.svga`) is one generic file shared by every type and
/// level, so it is ignored.
class _RelationEffect extends StatefulWidget {
  final RelationLink link;
  final double size;

  const _RelationEffect({required this.link, required this.size});

  @override
  State<_RelationEffect> createState() => _RelationEffectState();
}

class _RelationEffectState extends State<_RelationEffect>
    with SingleTickerProviderStateMixin {
  // Created in initState: a lazy `late final` would first be built inside
  // dispose() when no effect ever loaded, which looks up a dead ancestor.
  late final SVGAAnimationController _controller;
  bool _loaded = false;
  String? _loadedUrl;

  String get _key => '${widget.link.type}#${widget.link.level}';

  @override
  void initState() {
    super.initState();
    _controller = SVGAAnimationController(vsync: this);
    _load();
  }

  @override
  void didUpdateWidget(_RelationEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_key != _loadedUrl) _load();
  }

  Future<void> _load() async {
    final key = _key;
    _loadedUrl = key;
    MovieEntity? movie;
    final path = await RelationLevelEffects.effectFor(
      widget.link.type,
      widget.link.level,
    );
    final url = path == null ? '' : EndPoints.getImage(path);
    if (url.isNotEmpty) {
      try {
        movie = await SvgaMovieCache.instance.loadFromUrl(url);
      } catch (_) {
        // Not a valid SVGA (server placeholder image) — use the bundled one.
      }
    }
    if (movie == null) {
      try {
        movie = await SvgaMovieCache.instance.loadFromAsset(
          AssetsManager.relationHandshake,
        );
      } catch (_) {}
    }
    if (!mounted || key != _loadedUrl) return;
    if (movie == null) {
      setState(() => _loaded = false);
      return;
    }
    _controller.videoItem = movie;
    _controller.repeat();
    setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _loaded
        ? SVGAImage(_controller, fit: BoxFit.contain)
        : Center(
          child: Icon(
            Icons.handshake_rounded,
            size: widget.size * 0.6,
            color: const Color(0xFFFFC94D),
            shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
          ),
        );
  }
}
