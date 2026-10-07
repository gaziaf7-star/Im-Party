import 'package:general/src/core/index.dart';

class TextButtonWidget extends StatelessWidget {
  const TextButtonWidget({
    super.key,
    required this.onTap,
    this.content,
    this.fontSize,
    this.fontWeight,
    this.fontColor,
    this.backgroundColor,
    this.padding,
  });
  final VoidCallback onTap;
  final dynamic content;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? fontColor;
  final WidgetStateProperty<Color?>? backgroundColor;
  final WidgetStatePropertyAll<EdgeInsetsGeometry?>? padding;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style:  ButtonStyle(
          backgroundColor:backgroundColor,
        padding:padding?? const WidgetStatePropertyAll(EdgeInsets.zero),
      ),
      
      onPressed: onTap,
      child: content is String
          ? TextWidget(
              content,
              style: context.bodyMedium.copyWith(
                fontSize: fontSize?.sp,
                fontWeight: fontWeight,
                color: fontColor,
              ),
            )
          :content
    );
  }
}
