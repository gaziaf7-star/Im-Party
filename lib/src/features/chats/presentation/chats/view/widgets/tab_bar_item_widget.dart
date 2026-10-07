part of '../chats_page.dart';

class TabBarItemWidget extends StatelessWidget {
  final String image;
  final String text;
  final String subtitle;
  final Color? textColor;
  final double? height;
  final double? width;
  final Widget? endWidget;
  final void Function()? onTap;
  const TabBarItemWidget({
    super.key,
    required this.image,
    required this.text,
    required this.subtitle,
    this.textColor,
    this.onTap,
    this.height,
    this.width,
    this.endWidget,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          if (image.contains('group'))
            Container(
              padding: context.paddingAll(11),
              margin: context.paddingOnly(start: 4, end: 2),
              decoration: const BoxDecoration(
                gradient: ColorManager.brandGradient,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                image,
                color: ColorManager.onBrandGradient,
                height: 37.h,
                width: 37.h,
              ),
            )
          else
            Image.asset(
              image,
              height: height ?? 68.h,
              width: width ?? 68.h,
            ),
          10.wBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  child: Text(
                    text,
                    maxLines: 1,
                    style: context.bodyLarge
                        .colorExt(
                      ColorManager.momentPostTextColor,
                    )
                        .w500,
                  ),
                ),
                3.hBox,
                TextWidget(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodyMedium.colorExt(
                    ColorManager.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          endWidget ?? const SizedBox(),
        ],
      ),
    );
  }
}