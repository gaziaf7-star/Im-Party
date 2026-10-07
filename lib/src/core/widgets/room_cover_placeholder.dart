import 'package:general/src/core/index.dart';

/// Neutral placeholder for a room/live cover that has no image (null/empty) or
/// whose image failed to load. Shown instead of a blank box or the app logo so
/// the slot still reads as "a room". Brand-free: a soft themed gradient with a
/// built-in Material icon — no client/brand asset.
///
/// Used by [CacheImageWidget] when `isRoomCover` is set, so every room-cover
/// render shares one fallback (zero duplication).
class RoomCoverPlaceholder extends StatelessWidget {
  const RoomCoverPlaceholder({
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
    final double iconSize = ((width ?? height ?? 60) * 0.4).clamp(18.0, 64.0);
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: border,
        shape: shape ?? BoxShape.rectangle,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(radius ?? 0),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE3E1F0), Color(0xFFCFCBE6)],
        ),
      ),
      child: Icon(
        Icons.meeting_room_rounded,
        size: iconSize,
        color: Colors.white.withValues(alpha: 0.85),
      ),
    );
  }
}
