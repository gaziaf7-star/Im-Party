part of '../medals_page.dart';

class MedalsTabBarView extends StatelessWidget {
  const MedalsTabBarView({
    super.key,
    required this.type,
    required this.badges,
    required this.reqState,
    required this.error,
  });

  final String type;
  final List<AchievementLevelEntity> badges;
  final RequestState reqState;
  final String error;

  @override
  Widget build(BuildContext context) {
    return HandlingDataWidget(
      reqState: reqState,
      title: StringManager.noAchievements.tr(),
      subTitle: StringManager.noAchievementSubtitle.tr(),
      titleStyle: context.bodyMedium.w700.colorExt(ColorManager.textPrimary),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10.h,
          crossAxisSpacing: 10.w,
          // Taller, uniform HD card look, on request -- was a bare image +
          // one text line with no card chrome.
          childAspectRatio: 0.82,
        ),
        itemCount: badges.length,
        padding: context.paddingAll(15),
        itemBuilder: (context, index) {
          final badge = badges[index];
          final locked = badge.enable != 1;
          final imgSrc = type == "4"
              ? badge.image
              : badge.enable == 1
                  ? badge.validImage
                  : badge.image;
          // Was a Column with a name label below the card -- removed
          // entirely, on request ("card ar nesa kono text dhakba nah"): the
          // card alone is the grid tile again, no wrapper needed.
          return Material(
            color: ColorManager.transparent,
            shadowColor: ColorManager.transparent,
            elevation: 0,
            child: InkWell(
              borderRadius: 16.radius,
              onTap: () => _showDescriptionDialog(context, type: type, badge: badge),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: 16.radius,
                  // Top-to-bottom gradient fill + a thicker border, on
                  // request -- matching the "My medal" card above.
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF3A2408), Color(0xFF1C1004)],
                  ),
                  border: Border.all(color: const Color(0xCCFFD98A), width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Faint repeating diamond pattern, matching the "My
                    // medal" card's texture.
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.08,
                        child: CustomPaint(painter: _DiamondPatternPainter()),
                      ),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: context.paddingAll(8),
                        child: ClipRRect(
                          borderRadius: 12.radius,
                          child: imgSrc.contains('.svga')
                              ? CacheSvgaWidget(
                                  url: imgSrc,
                                  boxFit: BoxFit.contain,
                                )
                              : ImageViewWidget(
                                  url: imgSrc,
                                  boxFit: BoxFit.contain,
                                ),
                        ),
                      ),
                    ),
                    if (locked)
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45)),
                          child: Center(
                            child: Icon(Icons.lock_rounded, color: Colors.white.withValues(alpha: 0.9), size: 34.h),
                          ),
                        ),
                      ),
                    // Small "tap to preview" play icon, top-right corner --
                    // on request.
                    Positioned(
                      top: 6.h,
                      right: 6.w,
                      child: Container(
                        padding: context.paddingAll(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black38,
                        ),
                        child: Icon(Icons.play_arrow_rounded,
                            color: const Color(0xFFFFD98A), size: 14.h),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDescriptionDialog(
    BuildContext context, {
    required String type,
    required AchievementLevelEntity badge,
  }) {
    final locked = badge.enable != 1;
    final img = badge.validImage.isNotEmpty ? badge.validImage : badge.image;
    final target = badge.target;
    final progressLabel = type == "4"
        ? badge.description
        : target.isEmpty
            ? badge.description
            : '${locked ? 0 : target}/$target recharge coins';
    showDialog(
      context: context,
      useSafeArea: false,
      barrierDismissible: true,
      builder: (_) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            height: ScreenUtil().screenHeight,
            color: ColorManager.black.withValues(alpha: (0.75)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    ShowSVGA(
                      svgaAssetPath: AssetsManager.backgroundMedalsSvga,
                      height: 250.h,
                      width: 250.w,
                    ),
                    img.contains('.svga')
                        ? CacheSvgaWidget(
                            url: EndPoints.getImage(img),
                            height: 200.h,
                            width: 300.w,
                            boxFit: BoxFit.contain,
                          )
                        : img.contains('.vap')
                            ? CachedVapWidget(
                                url: EndPoints.getImage(img),
                                height: 200.h,
                                width: 300.w,
                              )
                            : ImageViewWidget(
                                url: img,
                                height: 200.h,
                                width: 300.w,
                                boxFit: BoxFit.contain,
                              ),
                  ],
                ),
                10.hBox,
                TextWidget(
                  badge.name.isNotEmpty ? badge.name : badge.description,
                  style: context.bodyLarge.bold.colorExt(ColorManager.textPrimary),
                  textAlign: TextAlign.center,
                  padding: context.paddingSymmetric(horizontal: 25),
                ),
                14.hBox,
                if (progressLabel.isNotEmpty)
                  TextWidget(
                    progressLabel,
                    isTranslate: false,
                    style: context.bodyMedium.colorExt(ColorManager.textPrimary),
                  ),
                10.hBox,
                Padding(
                  padding: context.paddingSymmetric(horizontal: 40),
                  child: ClipRRect(
                    borderRadius: 10.radius,
                    child: LinearProgressIndicator(
                      value: locked ? 0 : 1,
                      minHeight: 8.h,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation(
                        locked ? Colors.white38 : ColorManager.primary,
                      ),
                    ),
                  ),
                ),
                8.hBox,
                TextWidget(
                  locked ? 'Not obtained' : 'Obtained',
                  isTranslate: false,
                  style: context.bodySmall.colorExt(
                    locked ? Colors.white54 : ColorManager.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
