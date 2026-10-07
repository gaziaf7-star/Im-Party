import 'package:general/src/core/index.dart';

class ImageWidget extends StatelessWidget {
  final double height;
  final double width;
  final String image;
  final Color? color;
  final BoxFit? boxFit;

  const ImageWidget({
    super.key,
    required this.height,
    required this.width,
    required this.image,
    this.color,
    this.boxFit,
  });

  @override
  Widget build(BuildContext context) {
    if (image.trim().isEmpty) {
      return SizedBox(height: height, width: width);
    }
    if (image.contains('.svg')) {
      return SvgPicture.asset(
        image,
        height: height,
        colorFilter:
            color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
        width: width,
        fit: boxFit ?? BoxFit.contain,
      );
    } else {
      return Image.asset(
        image,
        color: color,
        height: height,
        width: width,
        fit: boxFit,
        errorBuilder: (context, error, stackTrace) =>
            SizedBox(height: height, width: width),
      );
    }
  }
}
