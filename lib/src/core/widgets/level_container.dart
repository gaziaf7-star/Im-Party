import 'package:general/src/core/index.dart';

class LevelContainer extends StatelessWidget {
  final String? image;
  final int? level;
  final BoxFit? boxFit;
  final double? height;
  final double? width;
  final bool isComment;

  /// When true, renders as a circle (BoxShape.circle) instead of the default
  /// rounded-rect badge. Defaults to false so every existing call site (level
  /// badges elsewhere in the app) keeps its current rectangular look — only
  /// callers that opt in (the Moment post card's sender/receiver image) get
  /// the circle.
  final bool isCircle;

  const LevelContainer({
    this.image,
    super.key,
    this.boxFit,
    this.height,
    this.width,
    this.isComment = false,
    this.level,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return image == null || (image ?? '').isEmpty
        ? const SizedBox()
        : ImageViewWidget(
      url: image ?? "",
      width: width ?? 40.w,
      height: height ?? 30.h,
      boxFit: boxFit ?? BoxFit.contain,
      radius: isCircle ? null : 20,
      shape: isCircle ? BoxShape.circle : null,
    );
  }
}