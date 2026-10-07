import '../../../../../../core/index.dart';

class CpRankDiscoverWidget extends StatelessWidget {
  final String img1;
  final String img2;
  final String icon;
  final String title;
  final List<Color> color;
  final int? viewIndex;

  const CpRankDiscoverWidget({
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
    return Container(
      margin: context.paddingSymmetric(
        horizontal: 0,
      ),
      width: ScreenUtil().screenWidth,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          SizedBox(
            width: 108.h,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                if (img1.isNotEmpty)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: ImageViewWidget(
                      url: img1,
                      height: 54.h,
                      width: 54.w,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (img2.isNotEmpty)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: ImageViewWidget(
                      url: img2,
                      height: 54.h,
                      width: 54.w,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
          Image.asset(
            icon,
            height: 130.h,
            width: 130.h,
          ),
        ],
      ),
    );
  }
}
