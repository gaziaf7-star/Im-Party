import 'package:general/src/core/index.dart';

/// Neutral placeholder for a USER AVATAR that has no photo (null/empty) or whose
/// photo failed to load AND whose name is unknown. A plain grey circle with a
/// generic Material person glyph — brand-free, so a photoless user NEVER shows
/// the app logo. When the name IS known the avatar renders [InitialsAvatar]
/// instead; this is only the last-resort generic fallback.
///
/// Used by [CacheImageWidget] as the default empty/failed fallback, so every
/// avatar render shares one neutral placeholder (zero duplication).
class PersonPlaceholder extends StatelessWidget {
  const PersonPlaceholder({
    super.key,
    this.width,
    this.height,
    this.radius,
    this.shape,
    this.margin,
    this.padding,
    this.border,
  });

  final double? width;
  final double? height;
  final double? radius;
  final BoxShape? shape;
  final EdgeInsetsDirectional? margin;
  final EdgeInsetsDirectional? padding;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    final double iconSize = ((width ?? height ?? 60) * 0.6).clamp(16.0, 64.0);
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: border,
        color: const Color(0xFFBDBDBD),
        shape: shape ?? BoxShape.rectangle,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(radius ?? 0),
      ),
      child: Icon(
        Icons.person,
        size: iconSize,
        color: Colors.white.withValues(alpha: 0.9),
      ),
    );
  }
}
