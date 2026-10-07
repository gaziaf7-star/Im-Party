import '../../../../../../core/index.dart';

class CpRankSliderWidget extends StatelessWidget {
  final String img1;
  final String img2;
  final String icon;
  final String title;
  final List<Color> color;
  final int? viewIndex;

  const CpRankSliderWidget({
    super.key,
    this.viewIndex,
    required this.icon,
    required this.color,
    required this.title,
    required this.img1,
    required this.img2,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamedRoute(Routes.cpRank);
      },
      child: Container(
        margin: context.paddingSymmetric(
          horizontal: 0,
        ),
        width: ScreenUtil().screenWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: color,
          ),
          borderRadius: 10.radius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextWidget(
              title,
              style: context.bodyLarge.bold.colorExt(ColorManager.textPrimary),
            ),
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        ImageViewWidget(
                          url: img1,
                          height: 40.h,
                          width: 40.w,
                          shape: BoxShape.circle,
                        ),
                        // Image.asset(
                        //   AssetsManager.top1CpHome,
                        //   height: 50.h,
                        //   width:50.w,
                        // ),
                      ],
                    ),
                    5.wBox,
                    Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        ImageViewWidget(
                          url: img2,
                          height: 40.h,
                          width: 40.w,
                          shape: BoxShape.circle,
                        ),
                        // Image.asset(
                        //   AssetsManager.top1CpHome,
                        //   height: 50.h,
                        //   width: 50.w,
                        // ),
                      ],
                    ),
                  ],
                ),
                Image.asset(
                  icon,
                  height: icon == AssetsManager.heartCp ? 25 : 40,
                  width: icon == AssetsManager.heartCp ? 25 : 40,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
