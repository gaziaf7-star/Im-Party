import 'package:general/src/core/index.dart';

class UserLevelContainer extends StatelessWidget {
  final double height;
  final double width;
  final String image;
  final bool? noNeedCustomError;

  const UserLevelContainer({
    required this.height,
    required this.width,
    required this.image,
    this.noNeedCustomError,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ImageViewWidget(
      url: image,
      boxFit: BoxFit.contain,
      width: width,
      height: height,
    );
  }
}
