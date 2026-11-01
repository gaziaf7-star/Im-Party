import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/show_svga.dart';

/// Colour set of one ranking page. Every page (room, wealth, charm, games,
/// agency, lucky, family) has its own.
class RankPalette {
  const RankPalette({
    required this.bgTop,
    required this.bgMid,
    required this.bgBottom,
    required this.podiumTop,
    required this.podiumFrontTop,
    required this.podiumFrontBottom,
    required this.panel,
    required this.card,
    this.value = const Color(0xFFFFE36E),
    required this.selectedText,
  });

  final Color bgTop;
  final Color bgMid;
  final Color bgBottom;
  final Color podiumTop;
  final Color podiumFrontTop;
  final Color podiumFrontBottom;
  final Color panel;
  final Color card;
  final Color value;

  /// Text colour on the white "selected period" pill.
  final Color selectedText;

  LinearGradient get background => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [bgTop, bgMid, bgBottom],
      );

  static const room = RankPalette(
    bgTop: Color(0xFF2A1659),
    bgMid: Color(0xFF45209A),
    bgBottom: Color(0xFF6A34D6),
    podiumTop: Color(0xFFA27AF6),
    podiumFrontTop: Color(0xFF7C4BE6),
    podiumFrontBottom: Color(0xFF5A2DBE),
    panel: Color(0xFFA67CF4),
    card: Color(0xFF9A44F2),
    selectedText: Color(0xFF2A1659),
  );

  static const wealth = RankPalette(
    bgTop: Color(0xFF3A2005),
    bgMid: Color(0xFF7A4A0C),
    bgBottom: Color(0xFFB8781A),
    podiumTop: Color(0xFFF2CE7A),
    podiumFrontTop: Color(0xFFD69A2E),
    podiumFrontBottom: Color(0xFFA86E14),
    panel: Color(0xFFE8B95A),
    card: Color(0xFFCC8A22),
    value: Color(0xFFFFF4C2),
    selectedText: Color(0xFF6B3F05),
  );

  static const charm = RankPalette(
    bgTop: Color(0xFF4A0F35),
    bgMid: Color(0xFF8E1F62),
    bgBottom: Color(0xFFD9468F),
    podiumTop: Color(0xFFF7A2CB),
    podiumFrontTop: Color(0xFFE2589D),
    podiumFrontBottom: Color(0xFFB8327A),
    panel: Color(0xFFF08DBE),
    card: Color(0xFFE0458F),
    selectedText: Color(0xFF8E1F62),
  );

  static const games = RankPalette(
    bgTop: Color(0xFF052E3A),
    bgMid: Color(0xFF0B5E73),
    bgBottom: Color(0xFF1494A8),
    podiumTop: Color(0xFF7FE3EE),
    podiumFrontTop: Color(0xFF26AFC2),
    podiumFrontBottom: Color(0xFF117E92),
    panel: Color(0xFF5CCBD9),
    card: Color(0xFF169DB2),
    selectedText: Color(0xFF0B5E73),
  );

  static const agency = RankPalette(
    bgTop: Color(0xFF0B1A4D),
    bgMid: Color(0xFF16348F),
    bgBottom: Color(0xFF2F5BD6),
    podiumTop: Color(0xFF8FB0FA),
    podiumFrontTop: Color(0xFF4A78E6),
    podiumFrontBottom: Color(0xFF2B54BE),
    panel: Color(0xFF7C9DF4),
    card: Color(0xFF3F6CE8),
    selectedText: Color(0xFF16348F),
  );

  static const lucky = RankPalette(
    bgTop: Color(0xFF07361F),
    bgMid: Color(0xFF0F6B3A),
    bgBottom: Color(0xFF1FA35A),
    podiumTop: Color(0xFF8EEAB3),
    podiumFrontTop: Color(0xFF34B86C),
    podiumFrontBottom: Color(0xFF1D8A4C),
    panel: Color(0xFF6FD69A),
    card: Color(0xFF26A85E),
    selectedText: Color(0xFF0F6B3A),
  );

  static const family = RankPalette(
    bgTop: Color(0xFF4A0E0E),
    bgMid: Color(0xFF8E2318),
    bgBottom: Color(0xFFD24A26),
    podiumTop: Color(0xFFF7AE8E),
    podiumFrontTop: Color(0xFFE2603A),
    podiumFrontBottom: Color(0xFFB63E20),
    panel: Color(0xFFF0926C),
    card: Color(0xFFDB5530),
    selectedText: Color(0xFF8E2318),
  );

  /// Palette of a ranking tab index (0 room, 1 wealth, 2 charm, 3 games,
  /// 4 agency, 5 lucky).
  static RankPalette forIndex(int index) => switch (index) {
        1 => wealth,
        2 => charm,
        3 => games,
        4 => agency,
        5 => lucky,
        _ => room,
      };
}

/// Supplies the current page's [RankPalette] to the ranking widgets below.
class RankPaletteScope extends InheritedWidget {
  const RankPaletteScope({
    super.key,
    required this.palette,
    required super.child,
  });

  final RankPalette palette;

  static RankPalette of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RankPaletteScope>()?.palette ??
      RankPalette.room;

  @override
  bool updateShouldNotify(RankPaletteScope old) => old.palette != palette;
}

/// Period selector: translucent pill track, white pill on the selected one.
class RankPeriodTabs extends StatelessWidget {
  const RankPeriodTabs({
    super.key,
    required this.controller,
    required this.labels,
  });

  final TabController controller;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final palette = RankPaletteScope.of(context);
    return Container(
      height: 40.h,
      margin: context.paddingSymmetric(horizontal: 36),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: 30.radius,
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        controller: controller,
        isScrollable: false,
        dividerHeight: 0,
        overlayColor: WidgetStateColor.transparent,
        labelStyle: context.bodyLarge.size(12).w700,
        unselectedLabelStyle: context.bodyLarge.size(12).w500,
        labelColor: palette.selectedText,
        unselectedLabelColor: Colors.white,
        labelPadding: EdgeInsets.zero,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: 30.radius,
        ),
        tabs: [
          for (final l in labels)
            FittedBox(fit: BoxFit.scaleDown, child: Text(l)),
        ],
      ),
    );
  }
}

/// Top three on three podiums (centre #1 tallest, #2 left, #3 right), each
/// avatar inside the app's own rank frame, with an info block on the
/// podium front.
///
/// Geometry is in fractions of the width so it scales on every phone. The
/// #1 frame sits highest; #2 and #3 stand lower on their own podiums so the
/// frames never collide.
class RankPodium extends StatelessWidget {
  const RankPodium({
    super.key,
    required this.frames,
    required this.avatar,
    required this.info,
    this.onTap,
    this.isPhoto = true,
  });

  /// (svga, png) frame art for a rank.
  final (String, String) Function(int rank) frames;

  /// Avatar for a rank, drawn at [size] inside the frame ring.
  final Widget Function(int rank, double size) avatar;

  /// Text block for a rank's podium front; null hides it.
  final Widget? Function(int rank, bool compact) info;

  final void Function(int rank)? onTap;
  final bool isPhoto;

  // (left, right, top) of each podium block, fractions of the width.
  static const Map<int, (double, double, double)> blocks = {
    1: (0.32, 0.68, 0.42),
    2: (0.02, 0.335, 0.62),
    3: (0.665, 0.98, 0.66),
  };

  @override
  Widget build(BuildContext context) {
    final palette = RankPaletteScope.of(context);
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      return SizedBox(
        height: w * 1.06,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _PodiumPainter(blocks: blocks, palette: palette),
              ),
            ),
            for (final rank in [2, 3, 1]) ...[
              _frame(w, rank),
              _info(w, rank),
            ],
          ],
        ),
      );
    });
  }

  Widget _frame(double w, int rank) {
    final (svga, png) = frames(rank);
    final first = rank == 1;
    final block = blocks[rank]!;
    // Frame canvases: #1 is 750x400 (ring hole ~17% of its width), #2/#3
    // are 450x400 (ring hole ~30%); the ring sits at the canvas centre.
    final frameW = w * (first ? 0.72 : 0.38);
    final frameH = frameW * (first ? 400 / 750 : 400 / 450);
    final hole = frameW * (first ? 0.17 : 0.3);
    final cx = w * (block.$1 + block.$2) / 2;
    // #1 floats well above its podium; #2/#3 stand right on theirs.
    final ringY = first ? w * 0.29 : w * block.$3 - hole * 0.55;
    return Positioned(
      left: cx - frameW / 2,
      top: ringY - frameH / 2,
      width: frameW,
      height: frameH,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap == null ? null : () => onTap!(rank),
        child: Stack(
          alignment: Alignment.center,
          children: [
            avatar(rank, hole),
            IgnorePointer(
              child: ShowSVGA(
                svgaAssetPath: svga,
                height: frameH,
                width: frameW,
                fit: BoxFit.fill,
                isPhoto: isPhoto,
                pngImg: png,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(double w, int rank) {
    final child = info(rank, rank != 1);
    if (child == null) return const SizedBox.shrink();
    final block = blocks[rank]!;
    final left = w * block.$1;
    final width = w * (block.$2 - block.$1);
    return Positioned(
      left: left + 4,
      width: width - 8,
      top: w * block.$3 + w * 0.05,
      child: GestureDetector(
        onTap: onTap == null ? null : () => onTap!(rank),
        child: child,
      ),
    );
  }
}

/// Podium blocks (top face + front) with faint big numbers.
class _PodiumPainter extends CustomPainter {
  _PodiumPainter({required this.blocks, required this.palette});

  final Map<int, (double, double, double)> blocks;
  final RankPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final faceH = w * 0.045;
    for (final rank in [2, 3, 1]) {
      final (l, r, t) = blocks[rank]!;
      final left = l * w, right = r * w, top = t * w;
      final inset = w * 0.03;

      final topFace = Path()
        ..moveTo(left + inset, top)
        ..lineTo(right - inset, top)
        ..lineTo(right, top + faceH)
        ..lineTo(left, top + faceH)
        ..close();
      canvas.drawPath(
        topFace,
        Paint()
          ..shader = LinearGradient(
            colors: [
              Color.lerp(palette.podiumTop, Colors.white, 0.25)!,
              palette.podiumTop,
            ],
          ).createShader(Rect.fromLTRB(left, top, right, top + faceH)),
      );

      final front = Rect.fromLTRB(left, top + faceH, right, size.height);
      canvas.drawRect(
        front,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [palette.podiumFrontTop, palette.podiumFrontBottom],
          ).createShader(front),
      );

      final tp = TextPainter(
        text: TextSpan(
          text: '$rank',
          style: TextStyle(
            fontSize: w * 0.24,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset((left + right - tp.width) / 2, size.height - tp.height * 0.95),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PodiumPainter old) => old.palette != palette;
}

/// One rank 4+ card: number, avatar, info block, value icon + value.
class RankListCard extends StatelessWidget {
  const RankListCard({
    super.key,
    required this.rank,
    required this.avatar,
    required this.info,
    required this.valueIcon,
    required this.value,
    this.onTap,
  });

  final int rank;
  final Widget avatar;
  final Widget info;
  final String valueIcon;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = RankPaletteScope.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 26.w,
              child: Text(
                '$rank',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            8.wBox,
            avatar,
            12.wBox,
            Expanded(child: info),
            8.wBox,
            ImageWidget(image: valueIcon, height: 20.h, width: 20.w),
            5.wBox,
            Text(
              value,
              style: TextStyle(
                color: palette.value,
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Light rounded panel that holds the rank 4+ cards.
class RankListPanel extends StatelessWidget {
  const RankListPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = RankPaletteScope.of(context);
    return Container(
      width: MediaQuery.sizeOf(context).width,
      constraints: BoxConstraints(minHeight: 280.h),
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 16.h),
      decoration: BoxDecoration(
        color: palette.panel.withValues(alpha: 0.55),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: child,
    );
  }
}
