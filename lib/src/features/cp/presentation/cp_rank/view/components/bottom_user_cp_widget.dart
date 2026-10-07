import 'package:general/src/core/index.dart';
import 'package:general/src/features/cp/domain/entities/cp_entity.dart';

class BottomUserCpWidget extends StatelessWidget {
  const BottomUserCpWidget({super.key, required this.userEntity});

  final MyUserCpEntity? userEntity;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.h,
      padding: context.paddingSymmetric(horizontal: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: 15.radiusCircular,
            topRight: 15.radiusCircular,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: ColorManager.bottomCardCpRank,
          )),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          8.wBox,
          Stack(
            alignment: Alignment.center,
            children: [
              Row(
                children: [
                  ImageViewWidget(
                    url: userEntity?.image ?? "",
                    displayName: userEntity?.name ?? '',
                    height: 50.h,
                    width: 50.w,
                    padding: EdgeInsetsDirectional.zero,
                    radius: 60.r,
                  ),
                  ImageViewWidget(
                    isCp: true,
                    url: userEntity?.otherUserCpEntity?.image ??
                        AssetsManager.seatCpRank,
                    displayName: userEntity?.otherUserCpEntity?.name ?? '',
                    height: 50.h,
                    width: 50.w,
                    padding: EdgeInsetsDirectional.zero,
                    radius: 60.r,
                  ),
                ],
              ),
              Image.asset(
                AssetsManager.cpLoveAvatar,
                height: 35.h,
                width: 35.w,
              ),
            ],
          ),
          const Spacer(),
          ButtonWidget(
            onPressed: () {
              Methods().userProfileNavigator(
                context: context,
                userId: userEntity?.id.toString(),
              );
            },
            width: 111.w,
            paddingButton: context.paddingZero(),
            title: TextWidget(
              StringManager.bindCp.tr(),
              style: context.bodyMedium.w500
                  .colorExt(ColorManager.pink.withValues(alpha: 0.5)),
            ),
            backgroundColor: ColorManager.scaffoldBg,
          )
        ],
      ),
    );
  }
}
