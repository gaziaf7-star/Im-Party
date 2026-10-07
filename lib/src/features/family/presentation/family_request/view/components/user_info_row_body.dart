part of '../family_requests_page.dart';

class _UserInfoRowBody extends StatelessWidget {
  final UserEntity userEntity;
  final Widget? endIcon;

  const _UserInfoRowBody({
    required this.userEntity,
    this.endIcon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Methods().userProfileNavigator(
            context: context,
            userId: userEntity.id.toString(),
            user_: userEntity);
      },
      child: Container(
        padding: context.paddingSymmetric(horizontal: 8, vertical: 10),
        margin: context.paddingAll(5),
        decoration: BoxDecoration(
            borderRadius: 5.radius,
            border:
            Border.all(width: 1, color: ColorManager.whiteGrey5)),
        child: Padding(
          padding: context.paddingSymmetric(horizontal: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              UserImage(
                image: userEntity.profile!.image!,
                displayName: userEntity.name ?? '',
                boxFit: BoxFit.cover,
                imageSize: 45.w,
              ),
              10.wBox,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GradientName(child: TextWidget(
                    userEntity.name ?? "",
                    style: context.bodyLarge.w700
                        .colorExt(ColorManager.textPrimary.withValues(alpha: (0.7 ))),
                  )),
                  IdWithCopyIcon(
                    userId: userEntity.uuid??'',
                    isNeedCopyIcon: true,
                    isSpecial: (userEntity.specialId != null && (userEntity.specialId??'')!=''),
                    specialImg: userEntity.idImage??'',
                    color: userEntity.imageColorEntity?.color,
                    img: userEntity.imageColorEntity?.image,
                    idStyle: context.bodyMedium.w400
                        .colorExt(ColorManager.secondaryText)
                        .copyWith(height: 0.1, fontSize: 11.sp),
                  ),
                ],
              ),
              const Spacer(),
              endIcon ?? const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
