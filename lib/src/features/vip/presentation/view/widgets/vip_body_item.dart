part of '../vip_screen.dart';

class VipBodyItem extends StatelessWidget {
  const VipBodyItem({
    super.key,
    required this.color,
    required this.vipCenterEntity,
  });

  final VipCenterEntity vipCenterEntity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetVipThemeSettingsBloc, GetVipThemeSettingsState>(
      bloc: di<GetVipThemeSettingsBloc>(),
      buildWhen: (prev, curr) => prev.data != curr.data,
      builder: (context, themeState) {
        // Per-tier index into ColorManager.vipBackgroundColor so each SVIP
        // level (SVIP1, SVIP2, ...) gets its own dark tint fallback.
        final vipBackgroundIndex = vipCenterEntity.level == 0
            ? 1
            : (vipCenterEntity.level ?? 0) > ColorManager.vipBackgroundColor.length
            ? ColorManager.vipBackgroundColor.length - 1
            : (vipCenterEntity.level ?? 1) - 1;

        // SVIP tier number (1-indexed) used to pick the local asset file
        // name, e.g. tier 1 -> assets/icons/svip1.png.
        final svipTier = vipBackgroundIndex + 1;

        return Scaffold(
          body: Stack(
            children: [
              // Background layer — the SVIP decorative image (on request:
              // "background image ta full page ar height neba") now
              // covers the FULL page height again, always loaded from the
              // app's own local assets, never from the admin panel/backend
              // API. The flat tier color sits behind it as a fallback in
              // case the image fails to load.
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorManager.vipBackgroundColor[vipBackgroundIndex],
                    image: DecorationImage(
                      image: AssetImage(
                        AssetsManager.svipBackground(vip: svipTier),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // "SVIP Identity" panel — a solid rounded-top container that
              // sits over roughly the bottom half of the page, on top of
              // the full-height background image, with a premium gold top
              // border (on request: "container ta page a ordhak a
              // dhakba, container ar top border radius hoba, border
              // primium color dhakba").
              Positioned(
                // Moved down a bit further from the top on request
                // ("base ta top thak akto niche namba").
                top: MediaQuery.of(context).size.height * 0.5,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorManager.backgroundBottomVip,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.r),
                      topRight: Radius.circular(24.r),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: ColorManager.defaultTextVip,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              // Content layer
              Padding(
                padding: context.paddingSymmetric(horizontal: 15),
                child: SizedBox(
                  height: ScreenUtil().screenHeight,
                  width: ScreenUtil().screenWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      170.hBox,
                      (vipCenterEntity.img1 ?? "").contains(".svga") ||
                          (vipCenterEntity.img1 ?? "").contains(".zz") ||
                          (vipCenterEntity.img1 ?? "").contains(".zzz")
                          ? CacheSvgaWidget(
                        url: EndPoints.getImage(
                            vipCenterEntity.img1 ?? ""),
                        width: 230.w,
                        height: 120.h,
                        boxFit: BoxFit.cover,
                      )
                          : Center(
                        child: ImageViewWidget(
                          url: EndPoints.getImage(
                              vipCenterEntity.img1 ?? ""),
                          width: 230.w,
                          height: 120.h,
                          boxFit: BoxFit.cover,
                        ),
                      ),
                      (ScreenUtil().screenHeight / 8).hBox,
                      65.hBox,
                      Expanded(
                        child: SizedBox(
                          width: ScreenUtil().screenWidth,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AssetsManager.titleIconPrivilege,
                                      height: 25.h,
                                      width: 25.w,
                                    ),
                                    10.wBox,
                                    Padding(
                                      padding: context.paddingOnly(bottom: 5),
                                      child: TextWidget(
                                        // Hardcoded to "SVIP Identity" on
                                        // request, matching the reference
                                        // image exactly — the previous
                                        // StringManager.aristocracyPrivileges
                                        // key ("Aristocracy Privileges")
                                        // never resolved to that text.
                                          'SVIP Identity',
                                          style:
                                          context.bodyMedium.bold.colorExt(
                                            ColorManager.defaultTextVip,
                                          )),
                                    ),
                                    10.wBox,
                                    Transform.flip(
                                      flipX: true,
                                      child: Image.asset(
                                        AssetsManager.titleIconPrivilege,
                                        height: 25.h,
                                        width: 25.w,
                                      ),
                                    ),
                                  ],
                                ),
                                // The "(active/total)" counter line is
                                // removed here — the reference image shows
                                // the "SVIP Identity" header followed
                                // directly by the icon grid, with no
                                // counter text between them.
                                15.hBox,
                                GridView.builder(
                                  shrinkWrap: true,
                                  itemCount:
                                  vipCenterEntity.privilgesData?.length ??
                                      0,
                                  physics: const NeverScrollableScrollPhysics(),
                                  // Removed this grid's own extra 15
                                  // horizontal padding (on top of the 15
                                  // the whole page content already has) —
                                  // that double padding was squeezing the
                                  // 3 columns together and reading as too
                                  // big a gap between them. Icons now
                                  // spread further left/right, matching
                                  // the reference image.
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context, __) {
                                    return InkWell(
                                      borderRadius: 8.radius,
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => AnimatedDialog(
                                            title: vipCenterEntity
                                                .privilgesData?[__]
                                                .privileg
                                                ?.name,
                                            description: vipCenterEntity
                                                .privilgesData?[__]
                                                .privileg
                                                ?.title,
                                            isHideConfirm: true,
                                            onTap: () => context.popRoute(),
                                            child: Padding(
                                              padding: context.paddingOnly(
                                                  bottom: 10),
                                              child: Methods().isSvgaFile(vipCenterEntity
                                                  .privilgesData?[__]
                                                  .privileg
                                                  ?.image ??
                                                  '')
                                                  ? CacheSvgaWidget(
                                                url: vipCenterEntity
                                                    .privilgesData?[
                                                __]
                                                    .privileg
                                                    ?.image ??
                                                    '',
                                                boxFit: BoxFit.fill,
                                                height: 80,
                                                width: 90,
                                              )
                                                  : (vipCenterEntity
                                                  .privilgesData?[
                                              __]
                                                  .privileg
                                                  ?.imageType ??
                                                  '') ==
                                                  'mp4'
                                                  ? CacheVideoWidget(
                                                videoUrl: vipCenterEntity
                                                    .privilgesData?[
                                                __]
                                                    .privileg
                                                    ?.image ??
                                                    '',
                                                height: 80,
                                                width: 90,
                                                isReels: true,
                                              )
                                                  : (vipCenterEntity.privilgesData?[__].privileg?.imageType ??
                                                  '') ==
                                                  'vap' &&
                                                  Methods.isVideoFile(
                                                      vipCenterEntity
                                                          .privilgesData?[__]
                                                          .privileg
                                                          ?.image ??
                                                          '')
                                                  ? CachedVapWidget(
                                                isLoop: true,
                                                url: vipCenterEntity
                                                    .privilgesData?[
                                                __]
                                                    .privileg
                                                    ?.image ??
                                                    '',
                                                height: 80,
                                                width: 90,
                                              )
                                                  : (vipCenterEntity.privilgesData?[__].privileg?.imageType ?? '') == 'alpha'
                                                  ? CacheAlphaWidget(
                                                url: vipCenterEntity
                                                    .privilgesData?[
                                                __]
                                                    .privileg
                                                    ?.image ??
                                                    '',
                                                height: 80,
                                                width: 90,
                                                isLoop: true,
                                              )
                                                  : ImageViewWidget(
                                                url: vipCenterEntity
                                                    .privilgesData?[
                                                __]
                                                    .privileg
                                                    ?.image ??
                                                    '',
                                                boxFit: BoxFit
                                                    .contain,
                                                height: 80,
                                                width: 90,
                                                heightLoading:
                                                100.h,
                                                widthLoading:
                                                90,
                                                isRoomProfile:
                                                true,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: MainPrivilegesItem(
                                        image1: vipCenterEntity
                                            .privilgesData?[__].img1 ??
                                            '',
                                        image2: vipCenterEntity
                                            .privilgesData?[__].img2 ??
                                            '',
                                        title: vipCenterEntity
                                            .privilgesData?[__].name ??
                                            '',
                                        isActive: vipCenterEntity
                                            .privilgesData?[__].active ??
                                            false,
                                      ),
                                    );
                                  },
                                  gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    // Lowered from 1.3 -> 1.05 (taller cells)
                                    // to give the new rounded-top icon card
                                    // (added on request) enough room and
                                    // fix the "BOTTOM OVERFLOWED" error it
                                    // was causing at the old ratio.
                                    childAspectRatio: 1.05,
                                    mainAxisSpacing: 8.h,
                                    crossAxisSpacing: 5.w,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: VipBottomBar(
            color: color,
            vipBadge: vipCenterEntity.img1 ?? '',
            expire: vipCenterEntity.expire.toString(),
            id: vipCenterEntity.id.toString(),
            price: vipCenterEntity.price.toString(),
            name: vipCenterEntity.name.toString(),
          ),
        );
      },
    );
  }
}