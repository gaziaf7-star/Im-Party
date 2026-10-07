import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';

class OfficialMessageCard extends StatelessWidget {
  final String content;
  final String created;
  final String img;
  final String url;
  final String title;

  const OfficialMessageCard({
    super.key,
    required this.content,
    required this.title,
    required this.created,
    required this.img,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Methods.safeLaunchUrl(url),
      child: Padding(
        padding: context.paddingSymmetric(vertical: 5),
        child: Column(
          children: [
            Text(
              Methods.formatTime(created),
              // Fixed light-black (was the medium-grey secondaryText).
              style: context.bodyMedium.colorExt(
                ColorManager.momentPostTextColor.withValues(alpha: (0.6)),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: context.paddingOnly(start: 15, top: 5),
                  child: Container(
                    width: 50.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(
                          AssetsManager.logo,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                5.wBox,
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 295.w,
                  ),
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    margin:
                    context.paddingSymmetric(horizontal: 5, vertical: 10),
                    decoration: BoxDecoration(
                      // Fixed white card + a soft shadow for depth (was the
                      // mutable, panel-overridable surfaceCardColor with no
                      // shadow) — matches the professional look used across
                      // the app.
                      color: ColorManager.white,
                      borderRadius: BorderRadius.only(
                        topRight: 15.radiusCircular,
                        topLeft: 15.radiusCircular,
                        bottomRight: 10.radiusCircular,
                        bottomLeft: 10.radiusCircular,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ColorManager.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (img.isNotEmpty)
                          InkWell(
                            onTap: () {
                              bottomDailog(
                                context: context,
                                widget: Scaffold(
                                  backgroundColor: ColorManager.black,
                                  appBar: AppBarWidget(
                                    title: '',
                                    backgroundColor: ColorManager.transparent,
                                    iconColor: ColorManager.white,
                                  ),
                                  body: InteractiveViewer(
                                    child: Container(
                                      padding: context.paddingAll(10),
                                      child: Center(
                                        child: ImageViewWidget(
                                          url: img,
                                          boxFit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              height: 200.h,
                              width: ScreenUtil().screenWidth,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: 15.radiusCircular,
                                  topRight: 15.radiusCircular,
                                ),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: ImageViewWidget(
                                url: img,
                                boxFit: BoxFit.cover,
                              ),
                            ),
                          ),
                        Padding(
                          padding: context.paddingAll(10),
                          child: Text(
                            title,
                            // Fixed light-black (was the medium-grey
                            // secondaryText).
                            style: context.bodyMedium.size(14).colorExt(
                                ColorManager.momentPostTextColor
                                    .withValues(alpha: 0.8)),
                          ),
                        ),
                        const Divider(
                          color: ColorManager.grey2,
                          thickness: 0.5,
                          height: 1,
                          indent: 0,
                          endIndent: 0,
                        ),
                        Padding(
                          padding: context.paddingAll(15),
                          child: Text(
                            content,
                            // Fixed light-black (was the panel-driven
                            // textPrimary).
                            style: context.bodyMedium
                                .size(14)
                                .colorExt(ColorManager.momentPostTextColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}