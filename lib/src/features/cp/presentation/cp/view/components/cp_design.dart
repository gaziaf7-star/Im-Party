import 'package:general/src/core/index.dart';

/// Shared, image-free design system for the CP (couple) pages: a romantic
/// pink/purple gradient with soft glow "lighting" instead of the old
/// Image.asset banners, reused across every CP section so the whole feature
/// reads as one consistent, professional surface.
class CpPalette {
  static const List<Color> accent = [Color(0xFFFF5EA8), Color(0xFFAC55E7)];
  static const Color surface = Color(0xFF2B1440);
  static const Color surfaceBorder = Color(0x33FF9AD5);
  static const Color glowPink = Color(0x66FF5EA8);
  static const Color glowPurple = Color(0x66AC55E7);
  static const List<Color> deepBackground = [
    Color(0xFF130821),
    Color(0xFF2B123F),
    Color(0xFF130821),
  ];
}

/// One bordered "legend" box (fieldset-style) with a gold pill label
/// straddling its top border — the simple single-box look for the Rules
/// content, instead of a separate header/footer card per rule.
class CpLegendBox extends StatelessWidget {
  const CpLegendBox({
    super.key,
    required this.label,
    required this.child,
    this.backgroundGradient = const [Color(0xFF3B1E6B), Color(0xFF1E1040)],
  });

  final String label;
  final Widget child;
  final List<Color> backgroundGradient;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.only(top: 14.h),
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 26.h, 16.w, 16.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: backgroundGradient,
            ),
            border: Border.all(color: const Color(0xE6FFD98A), width: 2.4),
          ),
          child: child,
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 6.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(colors: CpPalette.accent),
                border: Border.all(color: const Color(0xE6FFD98A), width: 1.6),
                boxShadow: const [
                  BoxShadow(color: CpPalette.glowPink, blurRadius: 8),
                ],
              ),
              child: Text(
                label,
                style: context.bodyMedium.bold.colorExt(Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Horizontal row of level badges (heart + level number + "Lv.N" label),
/// connected by a thin line, matching the reference Privileges ranking row.
/// Tappable when [onSelect] is given, so the caller can show only the
/// tapped level's detail below instead of every level at once.
class CpLevelRow extends StatelessWidget {
  const CpLevelRow({
    super.key,
    required this.levels,
    this.activeLevel = 1,
    this.onSelect,
  });

  final List<int> levels;
  final int activeLevel;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final level in levels)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: GestureDetector(
                onTap: onSelect == null ? null : () => onSelect!(level),
                child: _CpLevelRankBadge(
                  level: level,
                  active: level == activeLevel,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CpLevelRankBadge extends StatelessWidget {
  const _CpLevelRankBadge({required this.level, required this.active});

  final int level;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.favorite_rounded,
              size: 40.w,
              color: active ? const Color(0xFFFFD98A) : Colors.white24,
            ),
            Text(
              '$level',
              style: context.bodySmall.bold.colorExt(
                active ? CpPalette.surface : Colors.white70,
              ),
            ),
          ],
        ),
        4.hBox,
        Text(
          'Lv.$level',
          style: context.bodySmall
              .copyWith(fontSize: 11)
              .colorExt(active ? const Color(0xFFFFD98A) : Colors.white54)
              .copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

/// One simple rule entry: an emoji, a title, and its body text(s) — the
/// plain "emoji + heading + paragraph" look from the reference, no card
/// chrome of its own.
class CpRuleSection extends StatelessWidget {
  const CpRuleSection({
    super.key,
    required this.emoji,
    required this.title,
    required this.body,
    this.isLast = false,
  });

  final String emoji;
  final String title;
  final Widget body;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: TextStyle(fontSize: 15.sp)),
              6.wBox,
              Expanded(
                child: Text(
                  title,
                  style: context.bodyMedium.bold.colorExt(const Color(0xFFFFB3E0)),
                ),
              ),
            ],
          ),
          6.hBox,
          DefaultTextStyle.merge(
            style: context.bodySmall.colorExt(Colors.white70),
            child: body,
          ),
        ],
      ),
    );
  }
}

/// A single floating, gold-edged pill tab — selected state fills with the
/// brand gradient + glow, unselected stays a dim bordered outline. Meant to
/// be driven manually off a [TabController] (via an `AnimatedBuilder` +
/// `controller.animateTo`) rather than the stock `TabBar` indicator, so each
/// tab reads as its own separate capsule with a gap between them.
class CpTabPill extends StatelessWidget {
  const CpTabPill({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 46.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: selected
                ? const [Color(0xFFFF8AC2), Color(0xFFAC55E7)]
                : const [Color(0xFF4FC3FF), Color(0xFF3556E8)],
          ),
          border: Border.all(
            color: selected ? const Color(0xE6FFD98A) : const Color(0x99FFD98A),
            width: selected ? 2.2 : 1.8,
          ),
          boxShadow: [
            // Bottom depth shadow — the "3D" bevel.
            BoxShadow(
              color: selected ? CpPalette.glowPink : const Color(0x66000000),
              blurRadius: selected ? 12 : 6,
              offset: const Offset(0, 4),
            ),
            // Top inner-highlight glint.
            const BoxShadow(
              color: Color(0x33FFFFFF),
              blurRadius: 2,
              offset: Offset(0, -1),
              spreadRadius: -1,
            ),
          ],
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.bodySmall
              .copyWith(fontSize: 14)
              .colorExt(selected ? Colors.white : Colors.white70)
              .copyWith(
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                shadows: selected
                    ? const [Shadow(color: Color(0x66000000), blurRadius: 3, offset: Offset(0, 1))]
                    : null,
              ),
        ),
      ),
    );
  }
}

/// Full-bleed dark gradient with two soft blurred glow circles behind
/// [child] — the "lighting effect" backdrop for the CP screens.
class CpGlowBackground extends StatelessWidget {
  const CpGlowBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          AssetsManager.cpBackgroundImage,
          fit: BoxFit.cover,
        ),
        // The photo stays clear/HD up top; only fade toward the bottom,
        // where the tab bar and content card sit, so that text stays
        // readable without dimming the image itself.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x00130821),
                Color(0x00130821),
                Color(0xB3130821),
              ],
              stops: [0, 0.45, 1],
            ),
          ),
        ),
        const Positioned(
          top: -60,
          left: -40,
          child: _Glow(size: 220, color: CpPalette.glowPink),
        ),
        const Positioned(
          bottom: -80,
          right: -50,
          child: _Glow(size: 260, color: CpPalette.glowPurple),
        ),
        child,
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

/// Circular "LVL n" badge with connecting rail lines, replacing the old
/// per-file duplicated gradient-circle + Image.asset combo.
class CpLevelBadge extends StatelessWidget {
  const CpLevelBadge({
    super.key,
    required this.level,
    this.topConnector = true,
    this.bottomConnector = true,
  });

  final int level;
  final bool topConnector;
  final bool bottomConnector;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 3.w,
          height: 28.h,
          color: topConnector ? const Color(0xFFAC55E7) : Colors.transparent,
        ),
        Container(
          width: 46.w,
          height: 46.w,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: CpPalette.accent,
            ),
            border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 1.5)),
            boxShadow: [
              BoxShadow(color: CpPalette.glowPink, blurRadius: 10),
            ],
          ),
          child: Center(
            child: Text(
              'LVL $level',
              style: context.bodySmall.bold.colorExt(Colors.white).copyWith(fontSize: 10),
            ),
          ),
        ),
        Container(
          width: 3.w,
          height: 28.h,
          color: bottomConnector ? const Color(0xFFAC55E7) : Colors.transparent,
        ),
      ],
    );
  }
}

/// Content pill next to a [CpLevelBadge]: title + optional reward image,
/// replacing the old plain-color container + Image.asset reward art.
class CpLevelTile extends StatelessWidget {
  const CpLevelTile({
    super.key,
    required this.title,
    this.rewardImageUrl,
  });

  final String title;
  final String? rewardImageUrl;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: 12.radius,
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: CpPalette.surfaceBorder),
        ),
        child: Padding(
          padding: context.paddingSymmetric(vertical: 10, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.bodyMedium.bold.colorExt(Colors.white),
              ),
              if ((rewardImageUrl ?? '').isNotEmpty) ...[
                10.hBox,
                ClipRRect(
                  borderRadius: 8.radius,
                  child: ImageViewWidget(
                    url: rewardImageUrl!,
                    width: double.infinity,
                    height: 90.h,
                    boxFit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
