import '../../../../../../core/index.dart';

class CreateFamilyButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const CreateFamilyButton({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ButtonWidget(
      onPressed:onTap
      //     () {
      //   if (MyDataModel.getInstance().familyId == 0 ||
      //       MyDataModel.getInstance().familyId == null) {
      //     onTap.call();
      //   } else {
      //     Navigator.pushNamed(context, Routes.familyScreen,
      //         arguments: MyDataModel.getInstance().familyId.toString());
      //   }
      // }
      ,
      title: (MyDataModel.getInstance().familyId == 0 ||
              MyDataModel.getInstance().familyId == null)
          ? title
          : StringManager.myFamily.tr(),
      height: 50.h,
      radius: 25.r,
      width: 280.w,
      backgroundColor: ColorManager.primary,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      titleColor: Colors.white,
    );
  }
}
