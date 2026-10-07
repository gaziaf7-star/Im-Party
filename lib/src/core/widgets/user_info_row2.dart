import 'package:general/src/core/widgets/gradient_name.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/id_with_copy.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';

class UserInfoRow extends StatelessWidget {
  final UserEntity userData;

  final double? imageSize;

  final Widget? underName;

  final Widget? endIcon;

  final Widget? idOrNot;

  final String? flag;
  final String? itemId;

  final void Function()? onTap;

  const UserInfoRow({
    this.onTap,
    required this.userData,
    this.endIcon,
    this.underName,
    this.imageSize,
    this.idOrNot,
    this.flag,
    this.itemId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
      height: 8.7.h,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: ColorManager.surfaceCardColor),
      child: InkWell(
        onTap: onTap ??
            () {
              Methods().userProfileNavigator(
                  context: context, userId: userData.id.toString());
            },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // ImageWidget(
            //  /* frame: userData.frame,
            //   frameId: userData.frameId,
            //   imageSize: imageSize,*/
            //   image: userData.profile!.image!,
            //   height: 40.h,
            //   width: 40.w,
            // ),
            10.wBox,

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GradientName(child: Text(userData.name ?? "")),
                IdWithCopyIcon(
                  isSpecial: (userData.specialId != 0 &&
                      (userData.specialId ?? '') != ''),
                  specialImg: userData.idImage ?? '',
                  color: userData.imageColorEntity?.color,
                  img: userData.imageColorEntity?.image,
                  userId: userData.uuid ?? '',
                  idStyle: context.bodyMedium
                      .size(8)
                      .w500
                      .colorExt(ColorManager.secondaryText),
                ),
              ],
            ),
            const Spacer(),
            // if (flag == null)
            //   endIcon ??
            // Image.asset(
            //   AssetsManager.homeIcon,
            //   scale: 2.5,
            // ),
            if (flag != null)
              InkWell(
                onTap: () {},
                child: Container(
                  width: 7.1.w,
                  height: 3.1.h,
                  decoration: BoxDecoration(
                    color: ColorManager.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: TextWidget(
                      '',
                      //   AssetsManager.homeIcon,
                      style:
                          context.bodyMedium.colorExt(ColorManager.textPrimary),
                    ),
                  ),
                ),
              ),
            5.wBox
          ],
        ),
      ),
    );
  }
}
