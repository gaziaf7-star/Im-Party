import 'package:general/src/features/profile/data/model/top.dart';

import '../../../../../core/index.dart';

class StackWidgetSupport extends StatelessWidget {
  final Top? topSupport;
  final String cover;
  final String frame;
  final String top;
  final double padding;
  final double positioned;
  final double width;
  final double? textSize;
  final double imageSize;
  final double? space;
  final double widthFrame;

  const StackWidgetSupport(
      {super.key,
      this.topSupport,
      required this.cover,
      required this.frame,
      required this.padding,
      required this.positioned,
      required this.width,
      required this.top,
      required this.widthFrame,
      this.textSize,
      this.space,
      required this.imageSize});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingOnly(top: padding.h),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Image.asset(
            cover,
            fit: BoxFit.contain,
            width: width.w,
          ),
          Positioned(
            top: -positioned.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                TextWidget(top,
                    style: context.bodyMedium.w600
                        .colorExt(ColorManager.colorTextSup)
                        .copyWith(fontSize: 20.sp, height: 1.5.h)),
                4.hBox,
                Stack(
                  alignment: Alignment.center,
                  children: [
                    (topSupport?.image ?? '') != ''
                        ? UserImage(
                            borderRadius: 50.radius,
                            imageSize: imageSize.h,
                            border: Border.all(
                                color: ColorManager.primary, width: 2),
                            image: topSupport?.image ?? '',
                            displayName: topSupport?.name ?? '',
                          )
                        : Container(
                            width: imageSize.w,
                            height: imageSize.h,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            )),
                    Image.asset(
                      frame,
                      width: widthFrame.w,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 70.w,
                        minWidth: 1.w,
                      ),
                      child: TextWidget(
                        topSupport?.name ?? '',
                        maxLines: 1,
                        style: context.bodyMedium.bold
                            .colorExt(ColorManager.primary)
                            .copyWith(fontSize: textSize?.sp ?? 14.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    7.wBox,
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: ColorManager.grey.withValues(alpha: (0.4)),
                        borderRadius: 20.radius,
                      ),
                      child: IntrinsicWidth(
                        child: Row(
                          children: [
                            TextWidget(
                              topSupport?.countryModel?.iso ?? '',
                              style: context.bodyMedium.w500
                                  .copyWith(fontSize: 10.sp, height: 0.6),
                            ),
                            topSupport?.countryModel?.iso == ''
                                ? const SizedBox()
                                : 5.wBox,
                            ImageViewWidget(
                              url: topSupport?.countryModel?.photo ?? '',
                              height: 17.5,
                              width: 17.5,
                              boxFit: BoxFit.cover,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: space ?? 20.h,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextWidget(
                      topSupport?.total ?? '',
                      style: context.bodyMedium.bold
                          .colorExt(ColorManager.textPrimary)
                          .copyWith(fontSize: textSize?.sp ?? 14.sp),
                    ),
                    5.wBox,
                    // Image.asset(
                    //   AssetsManager.coinss,
                    //   width: 20.w,
                    // ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
