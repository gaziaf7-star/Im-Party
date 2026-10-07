part of 'package:general/src/features/family/presentation/create_family/view/create_family_intro.dart';

class CreateFamilyBody extends StatelessWidget {
  const CreateFamilyBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: ScreenUtil().screenWidth,
          height: 120.h,
          child: Padding(
            padding: context.paddingAll(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  StringManager.createFamily.tr(),
                  style: context.bodyLarge.bold.colorExt(ColorManager.onDark),
                ),
                TextWidget(
                  StringManager.createFamilyBody.tr(),
                  style: context.bodyLarge.w400.colorExt(ColorManager.onDark),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: ScreenUtil().screenWidth,
            padding: context.paddingAll(10),
            decoration: BoxDecoration(
              color: ColorManager.offWhite,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.r),
                topRight: Radius.circular(25.r),
              ),
            ),
            child: Column(
              children: [
                Image.asset(
                  AssetsManager.familyCreateIc,
                  scale: 1,
                  width: 125.w,
                  height: 125.h,
                ),
                10.hBox,
                _ListTileBody(
                  title: StringManager.familyMember.tr(),
                  subtitle: StringManager.familyMemberDescription.tr(),
                  icon: AssetsManager.familyCreatePeopleIc,
                ),
                _ListTileBody(
                  title: StringManager.rateOfReturn.tr(),
                  subtitle: StringManager.rateOfReturnDescription.tr(),
                  icon: AssetsManager.familyCreateIncomeIc,
                ),
                _ListTileBody(
                  title: StringManager.dailySignin.tr(),
                  subtitle: StringManager.dailySigninDescription.tr(),
                  icon: AssetsManager.familyCreateTaskIc,
                ),
                // _ListTileBody(
                //   title: StringManager.requirement.tr(),
                //   subtitle: StringManager.requirementDescription.tr(),
                //   icon: AssetsManager.familyCreateRequireIc,
                // ),
                20.hBox,
                CreateFamilyButton(
                  title: StringManager.nextSteps.tr(),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.createFamilyScreen,
                    );
                  },
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
