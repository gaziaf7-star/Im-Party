import '../../../../../core/index.dart';

class CreateFamilyEntryPage extends StatelessWidget {
  const CreateFamilyEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBarWidget(
        backgroundColor: ColorManager.scaffoldBg,
        title: StringManager.family.tr(),
      ),
      body: Container(
        padding: context.paddingSymmetric(horizontal: 12),
        height: ScreenUtil().screenHeight,
        width: ScreenUtil().screenWidth,
        // decoration: BoxDecoration(
        //     image: DecorationImage(
        //         image: AssetImage(AssetsManager.createFamilyBG),
        //         fit: BoxFit.fill)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 100.hBox,
            Align(
              alignment: Alignment.center,
              child: Image.asset(
               " AssetsManager.createFamilyFriendsImage",
                scale: 4,
              ),
            ),
            TextWidget(
              StringManager.createFamilyTitle1.tr(),
              style: context.bodyLarge.w600.size(20),
            ),
            8.hBox,
            TextWidget(
              StringManager.createFamilySubTitle1.tr(),
              style: context.bodyLarge.size(15),
            ),
            16.hBox,
            TextWidget(
              StringManager.createFamilyTitle2.tr(),
              style: context.bodyLarge.w600.size(20),
            ),
            8.hBox,
            TextWidget(
              StringManager.createFamilySubTitle2.tr(),
              style: context.bodyLarge.size(15),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.center,
              child: ButtonWidget(
                onPressed: () {
                  Navigator.pushNamed(context, Routes.createFamilyScreen);
                },
                title: StringManager.createFamily.tr(),
                height: 60.h,
                radius: 15.r,
                width: 280.w,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                titleColor: Colors.black,
              ),
            ),
            20.hBox,
          ],
        ),
      ),
    );
  }
}
