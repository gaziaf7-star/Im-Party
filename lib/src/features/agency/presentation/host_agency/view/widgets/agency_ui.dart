import 'package:flutter_animate/flutter_animate.dart';
import 'package:general/src/core/index.dart';

/// One look for every Agency Center page: white page, white cards with a
/// hairline border and a soft shadow, dark text, and a gentle fade/rise as
/// sections and list rows appear.
class AgencyUI {
  static const Color bg = Colors.white;
  static const Color ink = Color(0xFF1C1C1E);
  static const Color muted = Color(0xFF8E8F96);
  static const Color line = Color(0xFFEDEEF2);
  static const Color surface = Color(0xFFF5F6F8);

  static BoxDecoration card({double? radius, Color color = Colors.white}) =>
      BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius ?? 14.r),
        border: Border.all(color: line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .045),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      );

  /// Section heading used above groups of cards.
  static TextStyle title(BuildContext context) => TextStyle(
        color: ink,
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
      );
}

/// White rounded card with the Agency Center border + shadow.
class AgencyCard extends StatelessWidget {
  const AgencyCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.radius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius ?? 14.r);
    return Container(
      margin: margin,
      decoration: AgencyUI.card(radius: radius),
      child: Material(
        color: Colors.transparent,
        borderRadius: r,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding ?? EdgeInsets.all(12.w),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A [Column] whose children fade/rise in one after another.
class AgencyStaggerColumn extends StatelessWidget {
  const AgencyStaggerColumn({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  });

  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    var i = 0;
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: [
        for (final child in children)
          // Spacers don't need an animation of their own.
          child is SizedBox && child.child == null
              ? child
              : child.agencyEntrance(i++),
      ],
    );
  }
}

extension AgencyEntrance on Widget {
  /// Fade + small rise, staggered by [index] (capped so long lists don't
  /// wait for ages before the lower rows show).
  Widget agencyEntrance([int index = 0]) => animate(
        delay: Duration(milliseconds: 55 * index.clamp(0, 8)),
      )
          .fadeIn(duration: const Duration(milliseconds: 340))
          .slideY(
            begin: 0.06,
            end: 0,
            duration: const Duration(milliseconds: 340),
            curve: Curves.easeOutCubic,
          );
}
