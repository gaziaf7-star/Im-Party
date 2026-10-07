import 'package:flutter/cupertino.dart';
import 'package:general/src/core/index.dart';


class CustomRowWidget extends StatelessWidget {

  final Widget child;
  final String title;
  final Color? color;
  final bool? isNeedArrow;
  final dynamic iconName;
  final void Function()? onTap;
  final double? scale;

  const CustomRowWidget({
    super.key,

    required this.child,
    required this.title,
    required this.onTap,
    this.scale,
    this.color,
    this.isNeedArrow = true,
    required this.iconName,

  });

  @override
  Widget build(BuildContext context) {
    return InkWell(

      onTap: onTap,

      child: Row(
        children: [
          (iconName is String) ?
          Image.asset(
            iconName,
            color: color,
            scale: scale ?? 4,
          ) : iconName,
          5.wBox,
          TextWidget(title),
          const Spacer(),
          child,
          5.wBox,
          isNeedArrow == true ?
          Icon(
            CupertinoIcons.right_chevron,
            size: 16.w,
          ) : const SizedBox(),
        ],
      ),
    );
  }
}
