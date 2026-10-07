part of '../family_rank_page.dart';

class HeaderBody extends StatelessWidget {
  const HeaderBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().screenWidth,
      height: ScreenUtil().screenHeight * 0.55,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(

           " AssetsManager.familyBackground",
          ),
          fit: BoxFit.fill,
        ),
      ),
      // child: AppBarWidget(
      //   title: StringManager.familyRank,
      //   titleStyle:
      //       context.bodyLarge.w600.colorExt(ColorManager.textPrimary).size(20),
      //   iconColor: Colors.white,
      // ),
    );
  }
}
