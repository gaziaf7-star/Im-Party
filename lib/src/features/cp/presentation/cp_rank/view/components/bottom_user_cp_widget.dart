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
              // Drawn, not an asset: cp_love_avatar.png isn't bundled.
              Container(
                height: 30.h,
                width: 30.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF7EB3), Color(0xFFE8527F)],
                  ),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 17.h,
                ),
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
            width: 111,
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
