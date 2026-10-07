import 'package:general/src/core/index.dart';

class CustomAvatar extends StatelessWidget {
  final String image;
  final double border;
  final double size;
  final Color? borderColor;
  final int? frameId;
  final String? frame;
  final String? name;
  final void Function()? onPressed;
  const CustomAvatar({
    this.frame,
    this.frameId,
    this.onPressed,
    this.borderColor,
    required this.image,
    this.border = 0,
    required this.size,
    this.name,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Stack(
        children: [
          UserImage(
            imageSize: size,
            image: image,
            displayName: name,
            borderRadius: 80.radius,
          ),
          frameId == null || frameId == 0
              ? const SizedBox()
              : frame!.contains('png')
                  ? ImageViewWidget(
                      url: frame ?? '',
                      height: size,
                      radius: 50,
                    )
                  : CacheSvgaWidget(
                      url: frame ?? '',
                      height: size,
                    ),
        ],
      ),
    );
  }
}
