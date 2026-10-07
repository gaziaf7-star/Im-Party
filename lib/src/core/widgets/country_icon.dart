import '../index.dart';

// REMOVE
class CountryIcon extends StatelessWidget {
  final String country;

  final String? countryId;

  final double? imageSize;
  final double? width;
  final double? height;
  final BoxFit? boxFit;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;

  const CountryIcon({
    required this.country,
    this.countryId,
    this.boxFit,
    this.imageSize,
    this.width,
    this.height,
    this.border,
    this.borderRadius,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? 5.radius,
      child: ImageViewWidget(
        url: country,
        boxFit: boxFit ?? BoxFit.cover,
        width: imageSize ?? width ?? 25.w,
        height: imageSize ?? height ?? 22.w,
      ),
    );
  }
}
