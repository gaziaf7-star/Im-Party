import '../../../../../../core/index.dart';

class RankSliderWidget extends StatelessWidget {
  final List data;
  final String background;
  final String title;
  final List<Color> color;
  final int? viewIndex;

  const RankSliderWidget({
    super.key,
    this.viewIndex,
    required this.data,
    required this.color,
    required this.background,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, Routes.rankScreen, arguments: viewIndex);
      },
      child: Container(
        width: ScreenUtil().screenWidth,
        height: 90.h,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(background)),
          borderRadius: 10.radius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWidget(
              title,
              style: context.bodyMedium.bold.colorExt(ColorManager.textPrimary),
            ),
            2.hBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (data.length > 1 && data[1] != '')
                      ImageViewWidget(
                        url: data.length > 1 ? data[1] : "",
                        displayName: '',
                        height: 30.h,
                        width: 30.w,
                        shape: BoxShape.circle,
                      ),
                    Image.asset(
                      AssetsManager.frameHomeTopTwo,
                      height: 40.h,
                      width: 40.w,
                      fit: BoxFit.fill,
                    ),
                  ],
                ),
                Padding(
                  padding: context.paddingSymmetric(
                    horizontal: 10,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (data.isNotEmpty && data[0] != '')
                        ImageViewWidget(
                          url: data.isNotEmpty ? data[0] : "null",
                          displayName: '',
                          height: 35.h,
                          width: 35.w,
                          shape: BoxShape.circle,
                        ),
                      Image.asset(
                        AssetsManager.frameHomeTopOne,
                        height: 50.h,
                        width: 50.w,
                        fit: BoxFit.fill,
                      ),
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (data.length > 2 && data[2] != '')
                      ImageViewWidget(
                        url: data.length > 2 ? data[2] : "null",
                        displayName: '',
                        height: 30.h,
                        width: 30.w,
                        shape: BoxShape.circle,
                      ),
                    Image.asset(
                      AssetsManager.frameHomeTopThree,
                      height: 40.h,
                      width: 40.w,
                      fit: BoxFit.fill,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
