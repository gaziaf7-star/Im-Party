import 'package:general/src/core/index.dart';
// import 'package:general/src/core/widgets/cache/cache_vap_widget.dart';
// import 'package:general/src/core/widgets/cache/cache_video_widget.dart';
import 'package:general/src/core/widgets/show_svga.dart';

class WinnerDialog extends StatelessWidget {
  final String gift;
  final String giftType;
  const WinnerDialog({super.key, required this.gift, required this.giftType});

  Widget _buildGiftWidget(String type, String gift) {
    switch (type.toLowerCase()) {
      case "svga":
        return CacheSvgaWidget(
          url: gift,
        );
      /*  case "alpha":
        return ImageViewWidget(
          url: gift,
          boxFit: BoxFit.contain,
        );
      case "vap":
        return CachedVapWidget(
          url: gift,
          typesCache: TypesCache.gift,
        );
      case "mp4":
        return CacheVideoWidget(
          videoUrl: gift,
          isShowGift: true,
          typesCache: TypesCache.gift,
        ); */
      default:
        return ImageViewWidget(
          url: gift,
          boxFit: BoxFit.contain,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320.h,
      padding: context.paddingOnly(bottom: 10),
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color: const Color(0xFF293663),
        borderRadius: 15.radius,
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: ImageViewWidget(
                  url: MyDataModel.getInstance().profile?.image ?? '',
                  displayName: MyDataModel.getInstance().name ?? '',
                  width: 50.h,
                  height: 50.h,
                  radius: 100.r,
                ),
              ),
              Text(
                MyDataModel.getInstance().name ?? "",
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: ColorManager.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              20.hBox,
              Center(
                child: Text(
                  StringManager.congratulationsYouWin.tr(),
                  style: TextStyle(
                    color: ColorManager.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              15.hBox,
              SizedBox(
                width: 150.w,
                height: 150.h,
                child: _buildGiftWidget(
                  gift.split(".").last,
                  gift,
                ),
              ),
            ],
          ),
          ShowSVGA(
            svgaAssetPath: AssetsManager.fireWorks,
            fit: BoxFit.contain,
          )
        ],
      ),
    );
  }
}
