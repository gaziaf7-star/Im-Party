import 'package:general/src/core/index.dart';

class IdWithCopyIcon extends StatelessWidget {
  final String userId;
  final String? img;
  final String? specialImg;
  final String? color;
  final bool? isNeedCopyIcon;
  final bool? isSpecial;
  final TextStyle? idStyle;
  final MainAxisAlignment? mainAxisAlignment;
  final Color? idColor;
  final double? specialImgWidth;
  final double? specialImgHeight;

  const IdWithCopyIcon({
    required this.userId,
    this.color,
    this.img,
    this.idStyle,
    this.specialImg,
    this.isNeedCopyIcon = true,
    super.key,
    this.isSpecial,
    this.mainAxisAlignment,
    this.idColor,
    this.specialImgWidth,
    this.specialImgHeight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: userId.toString()));
        Methods.showToast(
          context,
          message: StringManager.theTextHasBeenCopied.tr(),
        );
      },
      child: specialImg != null && specialImg != ''
          ? Row(
              mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
              children: [
                ImageViewWidget(
                  url: specialImg ?? '',
                  height: specialImgHeight ?? 20.h,
                  width: specialImgWidth ?? 50.w,
                  boxFit: BoxFit.fill,
                ),
                if (isNeedCopyIcon ?? false) ...[
                  3.wBox,
                  ImageWidget(
                    height: 18.h,
                    width: 18.w,
                    color: Methods.safeHexColor(color) ??
                        ColorManager.greyColor.withValues(alpha: 0.70),
                    image: AssetsManager.copyId,
                  ),
                ]
              ],
            )
          : color != null && color != ''
              ? Row(
                  mainAxisAlignment:
                      mainAxisAlignment ?? MainAxisAlignment.center,
                  children: [
                    if (img != null && img != '')
                      ImageViewWidget(
                        url: img ?? '',
                        height: 20.h,
                        width: 20.w,
                        boxFit: BoxFit.cover,
                      ),
                    TextWidget(
                      ' ${userId.toString()}',
                      style: idStyle ??
                          Theme.of(context).textTheme.labelMedium!.copyWith(
                                fontSize: 15.sp,
                                height: 2.h,
                                color: Methods.safeHexColor(color) ??
                                    ColorManager.secondaryText,
                              ),
                    ),
                    2.5.wBox,
                    if (isNeedCopyIcon != false)
                      ImageWidget(
                        height: 18.h,
                        width: 18.w,
                        color: ColorManager.greyColor.withValues(alpha: 0.70),
                        image: AssetsManager.copyId,
                      ),
                  ],
                )
              : Row(
                  mainAxisAlignment:
                      mainAxisAlignment ?? MainAxisAlignment.center,
                  children: [
                    TextWidget(
                      'ID: ${userId.toString()}',
                      style: idStyle ??
                          Theme.of(context).textTheme.labelMedium!.copyWith(
                                fontSize: 15.sp,
                                height: 2.h,
                                color: idColor ?? ColorManager.secondaryText,
                              ),
                    ),
                    2.5.wBox,
                    if (isNeedCopyIcon != false)
                      ImageWidget(
                        height: 18.h,
                        width: 18.w,
                        color: idColor ??
                            ColorManager.greyColor.withValues(alpha: 0.70),
                        image: AssetsManager.copyId,
                      ),
                  ],
                ),
    );
  }
}
