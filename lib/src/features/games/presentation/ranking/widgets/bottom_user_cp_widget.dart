/*
import 'package:general/src/core/widgets/level_container.dart';
import 'package:general/src/features/games/domain/entities/cp_entity.dart';
import 'package:general/src/features/games/games.dart';

class BottomUserCpWidget extends StatelessWidget {
  const BottomUserCpWidget({super.key, required this.userEntity});

  final MyUserCpEntity? userEntity;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      padding: context.paddingSymmetric(horizontal: 20),
      decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: ColorManager.bottomCardRankGradient,
      )),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextWidget(
            'NO',
            style: context.bodyMedium.bold.colorExt(ColorManager.grey),
          ),
          8.wBox,
          UserImage(
            image: userEntity?.image ?? "",
            displayName: userEntity?.name ?? '',
            imageSize: 40.w,
          ),
          15.wBox,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                userEntity?.name ?? "",
              ),
              5.hBox,
              Row(
                children: [
                  LevelContainer(
                    image: userEntity?.receiverImage ?? "",
                    width: 30,
                    height: 10,
                    boxFit: BoxFit.fill,
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Image.asset(
            AssetsManager.diamondIcon,
            scale: 3.5,
          ),
          5.wBox,
          TextWidget(
            userEntity?.exp.toString() ?? "",
            style: context.bodySmall.w700,
          ),
        ],
      ),
    );
  }
}
*/
