

import '../../../../../../core/index.dart';


class BannerBody extends StatelessWidget {
  const BannerBody({
    super.key,
    required this.image,
  });

  final String? image;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingOnly(start: 15,end: 15),
      width:ScreenUtil().screenWidth,
      height: 100.h,
      child: Image.asset(
        image ??"" ,
        fit: BoxFit.fill,
        width: 80.h,
        height: 80.h,
      ),
    );
  }
}

