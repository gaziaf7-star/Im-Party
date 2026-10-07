import 'package:general/src/core/index.dart';

class ShowLuckyBannerBodyWidget extends StatelessWidget {
  final Map<String, dynamic> bannerLuckyBoxModel;
  const ShowLuckyBannerBodyWidget({
    super.key,
    required this.bannerLuckyBoxModel,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: 350.h,
        height: 60.h,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetsManager.luckyBoxBanner),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: 12.5.h,
            left: 15.w,
            right: 15.w,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UserImage(
                image: bannerLuckyBoxModel['ownerBoxImage'],
                displayName: bannerLuckyBoxModel['ownerBoxName'] ?? '',
                imageSize: 45.sp,
              ),
              SizedBox(width: 6.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  5.hBox,
                  SizedBox(
                    width: 145.h,
                    child: Text(
                      bannerLuckyBoxModel['ownerBoxName'] ?? '',
                      style: TextStyle(
                        fontSize: 12.h,
                        fontFamily: StringManager.fontFamily,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                        color: ColorManager.white,
                        height: 0.9,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  5.hBox,
                  Row(
                    children: [
                      Text(
                        StringManager.sendASpecialBox.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: StringManager.fontFamily,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                          height: 0.9,
                        ),
                      ),
                      SizedBox(
                        width: 60.h,
                        child: Text(
                          ' ${bannerLuckyBoxModel['coins'] ?? ''}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontFamily: StringManager.fontFamily,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                            color: ColorManager.white,
                            height: 0.9,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
