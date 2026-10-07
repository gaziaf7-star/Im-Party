part of '../activity_message_page.dart';

class ActivityChatCard extends StatelessWidget {
  final String? img;
  final String? title;
  final String? content;
  final String? createdAt;
  const ActivityChatCard({
    required this.createdAt,
    required this.title,
    required this.content,
    required this.img,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: context.paddingAll(8),
            child: Text(
              createdAt ?? '',
              style: context.bodyMedium.colorExt(ColorManager.secondaryText),
            ),
          ),
          Container(
            width: ScreenUtil().screenWidth,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
              bottomLeft: 10.radiusCircular,
              bottomRight: 10.radiusCircular,
            )),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ImageViewWidget(
                  radius: 10,
                  url: img ?? '',
                  height: 120.h,
                  width: ScreenUtil().screenWidth,
                  boxFit: BoxFit.fill,
                ),
                5.hBox,
                Row(
                  children: [
                    Container(
                      height: 40.h,
                      width: 40.w,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage(AssetsManager.logo))),
                    ),
                    10.wBox,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: context.paddingSymmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: ColorManager.surfaceCardColor,
                              borderRadius: 6.radius,
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  minWidth: 10.w, maxWidth: 250.w),
                              child: Text(
                                title ?? '',
                                style: Theme.of(context).textTheme.bodyMedium,
                                overflow: TextOverflow.clip,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                10.hBox,
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: InkWell(
                //     onTap: () {},
                //     child: Row(
                //       children: [
                //         Text(
                //           StringManager.go.tr(),
                //           style: TextStyle(
                //               color: ColorManager.orangIndcator,
                //               fontWeight: FontWeight.bold,
                //               fontSize: ConfigSize.defaultSize! * 2),
                //         ),
                //         const Spacer(),
                //         const Icon(
                //           Icons.arrow_forward_ios_rounded,
                //           color: ColorManager.orangIndcator,
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
