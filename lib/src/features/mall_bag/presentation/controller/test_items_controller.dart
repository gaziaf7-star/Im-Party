import 'dart:ui';

import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/cache/cache_alpha_widget.dart';
import 'package:general/src/core/widgets/cache/cache_vap_widget.dart';
import 'package:general/src/core/widgets/cache/cache_video_widget.dart';
import 'package:general/src/core/widgets/id_with_copy.dart';
import 'package:general/src/features/mall_bag/presentation/component/custom_avatar.dart';

class TestItemsController {
  // Create a private constructor
  TestItemsController._privateConstructor();

  // Create a static instance variable
  static final TestItemsController _instance =
  TestItemsController._privateConstructor();

  // Provide a static getter to access the singleton instance
  static TestItemsController get instance => _instance;

  /// Builds the player for [source], picked from the file itself rather than
  /// from the ware's `image_type` column — see [AssetPreviewSource] for why the
  /// column cannot be trusted.
  ///
  /// [width] / [height] are passed straight through; leaving both null lets the
  /// animation fill whatever box the dialog gives it.
  static Widget buildPreview(
      AssetPreviewSource source, {
        double? width,
        double? height,
      }) {
    switch (source.kind) {
      case AssetPreviewKind.svga:
        return CacheSvgaWidget(
          url: source.url,
          width: width,
          height: height,
          boxFit: BoxFit.contain,
        );
      case AssetPreviewKind.vap:
        return IgnorePointer(
          child: CachedVapWidget(
            url: EndPoints.getImage(source.url),
            width: width,
            height: height,
            isLoop: true,
          ),
        );
      case AssetPreviewKind.alpha:
        return CacheAlphaWidget(
          url: EndPoints.getImage(source.url),
          width: width,
          height: height,
          isLoop: true,
        );
      case AssetPreviewKind.mp4:
        return CacheVideoWidget(
          videoUrl: EndPoints.getImage(source.url),
          width: width,
          height: height,
          isReels: true,
        );
      case AssetPreviewKind.still:
        return ImageViewWidget(
          url: source.url,
          width: width,
          height: height,
          boxFit: BoxFit.contain,
        );
      case AssetPreviewKind.none:
      // The item ships no file at all. Every player would return an empty
      // box here, which reads as a frozen app — say so instead.
        return _NoPreviewNotice(width: width, height: height);
    }
  }

  /// The file this item previews, resolved once per tap.
  static AssetPreviewSource sourceOf(TestMallBagParam param) =>
      AssetPreviewSource.resolve(
        animated: param.svg,
        still: param.image,
        declaredType: param.type,
      );

  void onMallCardTap(
      BuildContext context,
      TestMallBagParam param,
      MallOrBagType type,
      ) {
    if (type == MallOrBagType.intro) {
      _showSvgDialog(context, param);
    }
    if (type == MallOrBagType.frame) {
      _showFrameDialog(context, param);
    }
    if (type == MallOrBagType.bubble) {
      _showBubbleDialog(context, param);
    }
    if (type == MallOrBagType.specialId) {
      _showSpecialIdDialog(context, param);
    }
    if (type == MallOrBagType.profileFrame) {
      _showProfileFrameDialog(context, param);
    }
  }

  void _showProfileFrameDialog(BuildContext context, TestMallBagParam param) {
    Widget buildVipWidget() => buildPreview(
      sourceOf(param),
      width: ScreenUtil().screenWidth,
    );

    svgDialog(
      context: context,
      widget: Stack(
        alignment: Alignment.center,
        children: [
          // Blurred background
          Positioned.fill(
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: ScreenUtil().screenWidth,
                  height: ScreenUtil().screenHeight,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),

          Positioned.fill(
            top: ScreenUtil().screenHeight * 0.2,
            child: Padding(
              padding: context.paddingOnly(
                top: 0.h,
              ),
              child: buildVipWidget(),
            ),
          ),

          // Profile Information
          Positioned.fill(
            child: Padding(
              padding: context.paddingSymmetric(horizontal: 40),
              child: Column(
                children: [
                  (ScreenUtil().screenHeight * 0.37).hBox,
                  CustomAvatar(
                    image: MyDataModel.getInstance().profile?.image ?? "",
                    name: MyDataModel.getInstance().name ?? '',
                    size: 80.h,
                  ),
                  25.hBox,
                  GradientName(child: TextWidget(
                    MyDataModel.getInstance().name ?? '',
                    style: context.bodyMedium.copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: (MyDataModel.getInstance().vip1?.colorName ??
                          '') !=
                          ''
                          ? Color(
                        int.parse(
                          (MyDataModel.getInstance().vip1?.colorName ??
                              '')
                              .replaceFirst('#', '0xff'),
                        ),
                      )
                          : Colors.white,
                    ),
                  )),
                  5.hBox,
                  Row(
                    children: [
                      const Spacer(),
                      IdWithCopyIcon(
                        userId: MyDataModel.getInstance().uuid ?? '',
                        isNeedCopyIcon: true,
                        isSpecial:
                        (((MyDataModel.getInstance().specialId ?? 0) != 0)),
                        specialImg:
                        MyDataModel.getInstance().specialIdImage ?? '',
                        color:
                        MyDataModel.getInstance().imageColorEntity?.color,
                        img: MyDataModel.getInstance().imageColorEntity?.image,
                        mainAxisAlignment: MainAxisAlignment.start,
                        idColor: ColorManager.greyTextColor,
                        idStyle: context.bodyMedium.bold
                            .colorExt(
                          Methods.safeHexColor(MyDataModel.getInstance()
                              .imageColorEntity
                              ?.color) ??
                              ColorManager.textPrimary,
                        )
                            .copyWith(height: 0.1, fontSize: 11.sp),
                      ),
                      const Spacer(),
                    ],
                  ),
                  25.hBox,
                  ...List.generate(2, (_) {
                    return Column(
                      children: [
                        ClipRRect(
                          borderRadius: 10.radius,
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              height: 65.h,
                              padding: context.paddingSymmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: 10.radius,
                              ),
                            ),
                          ),
                        ),
                        5.hBox,
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFrameDialog(BuildContext context, TestMallBagParam param) {
    final previewSize = ScreenUtil().screenWidth * 0.88;
    final avatarSize = previewSize * 0.43;

    svgDialog(
      context: context,
      widget: SizedBox(
        width: ScreenUtil().screenWidth,
        height: ScreenUtil().screenHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: SizedBox(
                width: previewSize,
                height: previewSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomAvatar(
                      image:
                      MyDataModel.getInstance().profile?.image ?? "",
                      name: MyDataModel.getInstance().name ?? '',
                      size: avatarSize,
                    ),
                    SizedBox(
                      width: previewSize,
                      height: previewSize,
                      child: buildPreview(
                        sourceOf(param),
                        width: previewSize,
                        height: previewSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 16.h,
              right: 16.w,
              child: Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.42),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 22.h,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSvgDialog(BuildContext context, TestMallBagParam param) {
    // An entrance effect is authored to sweep across the whole screen, so it is
    // given the whole screen. Both dimensions are explicit: the players size
    // themselves from their box, and a null one collapsed the animation to
    // nothing inside the dialog's loose constraints.
    svgDialog(
      context: context,
      widget: buildPreview(
        sourceOf(param),
        width: ScreenUtil().screenWidth,
        height: ScreenUtil().screenHeight,
      ),
    );
  }

  void _showBubbleDialog(BuildContext context, TestMallBagParam param) {
    // A bubble is a nine-patch behind a line of chat text, so it always
    // previews as its still art — never as the animated field.
    if ((param.image ?? '').trim().isEmpty) {
      _showNoPreviewDialog(context);
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            // 60.hBox,
            ImageViewWidget(
              url: param.image ?? '',
              boxFit: BoxFit.fill,
              isBubble: true,
              child: Padding(
                padding: context.paddingAll(5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 30.w, right: 30.w),
                      child: TextWidget(
                        StringManager.helloEveryone,
                        style: context.bodyMedium.bold
                            .colorExt(ColorManager.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Align(
            //   alignment: AlignmentDirectional.bottomCenter,
            //   child: Text( param.name?? "",
            //       style:  context.bodyMedium.w600
            //           .colorExt(
            //           ColorManager.textPrimary)),
            // ),
            // 25.hBox,
            // ImageViewWidget(
            //     url: param.image ?? '',
            //     boxFit: BoxFit.fill,
            //     isBubble: true,
            //
            //     child: Padding(
            //     padding: context.paddingAll(5),
            // child: Column(
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Padding(
            //       padding: EdgeInsets.only(
            //           left: 8.w, right: 8.w),
            //       child: TextWidget(
            //         StringManager.niceToMeetYou,
            //         style:  context.bodyMedium
            //             .size(13)
            //             .colorExt(
            //             ColorManager.textPrimary),
            //       ),
            //     ),
            //   ],
            // ),
            //     ),
            // ),
          ],
        );
      },
    );
  }

  void _showSpecialIdDialog(BuildContext context, TestMallBagParam param) {
    if ((param.image ?? '').trim().isEmpty) {
      _showNoPreviewDialog(context);
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: ImageViewWidget(
            url: param.image ?? '',
            height: ScreenUtil().screenHeight * 0.3,
            width: ScreenUtil().screenWidth * 0.9,
            boxFit: BoxFit.contain,
          ),
        );
      },
    );
  }

  /// Shown instead of an empty dialog when the item carries no artwork, so a
  /// missing asset reads as a missing asset rather than as a dead tap.
  void _showNoPreviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const Center(child: _NoPreviewNotice()),
    );
  }

  Future<void> svgDialog({
    required BuildContext context,
    required Widget widget,
    Color? color,
  }) {
    return showGeneralDialog(
      context: context,
      barrierLabel: "",
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 400),
      barrierColor: Colors.black.withValues(alpha: (0.5)),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return fromBottom(animation, secondaryAnimation, child);
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        // A full-screen entrance effect covers the barrier, so `barrierDismissible`
        // alone would leave the preview with no way out. Tapping the preview
        // itself closes it.
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).maybePop(),
          child: Align(
            alignment: const Alignment(0, 1),
            child: Material(
              type: MaterialType.transparency,
              child: widget,
            ),
          ),
        );
      },
    );
  }

  fromBottom(Animation<double> animation, Animation<double> secondaryAnimation,
      Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        end: Offset.zero,
        begin: const Offset(1.0, 0.0),
      ).animate(animation),
      child: child,
    );
  }
}

/// Placeholder for an item the panel sells but ships no artwork for.
class _NoPreviewNotice extends StatelessWidget {
  const _NoPreviewNotice({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 48.h,
              color: ColorManager.white,
            ),
            12.hBox,
            TextWidget(
              StringManager.noPreviewAvailable.tr(),
              textAlign: TextAlign.center,
              style: context.bodyMedium.w600.colorExt(ColorManager.white),
            ),
          ],
        ),
      ),
    );
  }
}
