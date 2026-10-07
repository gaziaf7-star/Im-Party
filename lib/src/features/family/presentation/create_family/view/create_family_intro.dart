import 'package:general/src/core/index.dart';

import '../../family_rank/view/widgets/create_family_button.dart';

part 'components/create_family_body.dart';
part 'components/list_tile_body.dart';

class CreateFamilyIntro extends StatelessWidget {
  const CreateFamilyIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().screenWidth,
      decoration: BoxDecoration(
          image: DecorationImage(
              alignment: Alignment.topCenter,
              fit: BoxFit.contain,
              image: AssetImage(AssetsManager.familyBackground1))),
      child: Scaffold(
        backgroundColor: WidgetStateColor.transparent,
        appBar: AppBarWidget(
          backgroundColor: ColorManager.transparent,
          title: StringManager.family.tr(),
          titleStyle: context.bodyLarge.w600.colorExt(ColorManager.onDark),
          iconColor: ColorManager.white,
        ),
        body: const CreateFamilyBody(),
      ),
    );
  }
}
