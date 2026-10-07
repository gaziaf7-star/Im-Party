import '../../../../../core/index.dart';

class GamesViewItem extends StatelessWidget {
  const GamesViewItem({
    super.key,
    required this.title,
    this.isAsset = false,
    required this.img,
    required this.isHot,
  });

  final String img;
  final String title;
  final int isHot;
  final bool isAsset;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topLeft,
          children: [
            isAsset
                ? Image.asset(
                    img,
                    height: 50.h,
                    width: 50.w,
                  )
                : ImageViewWidget(
                    url: img,
                    height: 50.h,
                    width: 50.w,
                    radius: 12.r,
                  ),
            if (isHot == 1)
              Positioned(
                bottom: 15.h,
                right: 15.w,
                child: Container(
                  height: 40.h,
                  width: 40.w,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage(
                        AssetsManager.hotDesign,
                      ),
                    ),
                  ),
                  child: Transform.rotate(
                    angle: 11.7,
                    child: TextWidget(
                      StringManager.hot,
                      style: context.bodyMedium.copyWith(
                          color: ColorManager.white,
                          fontSize: 7.sp,
                          fontWeight: FontWeight.bold),
                      padding: context.paddingOnly(top: 4, start: 13),
                    ),
                  ),
                ),
              ),
          ],
        ),
        10.hBox,
        TextWidget(
          title,
          style: context.bodySmall.bold.colorExt(ColorManager.white),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
