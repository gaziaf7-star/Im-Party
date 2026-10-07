import 'package:general/src/core/index.dart';

class CustomItemImageProfile extends StatelessWidget {
  const CustomItemImageProfile({super.key,required this.title,required this.image, this.textStyle, this.padding,});

  final String image;
  final String title;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        ImageWidget(height: 50.h, width: 100.w, image: image
        ),
        Padding(
          padding: padding??EdgeInsets.zero,
          child: TextWidget(
            title,
            style: textStyle??context.bodySmall.bold.colorExt(ColorManager.textPrimary),
          ),
        ),
      ],
    );
  }
}
