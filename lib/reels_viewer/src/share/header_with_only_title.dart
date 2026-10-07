import 'package:general/src/core/index.dart';

class HeaderWithOnlyTitle extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final Color? arrowColor;
  final Widget? endIcon;
  const HeaderWithOnlyTitle({
    this.endIcon,
    this.arrowColor,
    this.titleColor,
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        20.wBox,
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 25,
            color: arrowColor ?? Theme.of(context).iconTheme.color,
          ),
          color: titleColor ?? ColorManager.whiteColor,
        ),
        titleColor == null
            ? Text(title, style: context.bodyLarge)
            : Text(
                title,
                style: context.bodyMedium
                    .size(20)
                    .colorExt(titleColor ?? ColorManager.blackColor),
              ),
        const Spacer(),
        if (endIcon != null) endIcon!,
        10.wBox,
      ],
    );
  }
}
