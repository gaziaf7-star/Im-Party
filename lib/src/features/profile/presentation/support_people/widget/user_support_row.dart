import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/data/model/top.dart';

class UserSupportRow extends StatelessWidget {
  final Top? user;
  final VoidCallback? select;
  final int? index;
  final String? userId;
  const UserSupportRow(
      {required this.user, super.key, this.select, this.index, this.userId});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: select ??
          () {
            context.popRoute();
            context.popRoute();
            Navigator.pushNamed(
              context,
              Routes.userProfile,
              arguments: UserProfileParameter(userId: '${user?.id ?? 0}'),
            );
          },
      child: Container(
        margin: context.paddingSymmetric(horizontal: 5.w, vertical: 2.h),
        padding: context.paddingSymmetric(vertical: 2.5.h, horizontal: 5.w),
        decoration: BoxDecoration(
          borderRadius: 6.radius,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextWidget(
              "${index! + 4}",
              style: context.bodyLarge.colorExt(ColorManager.textPrimary),
            ),
            10.wBox,
            UserImage(
              borderRadius: 50.radius,
              imageSize: 60.h,
              border: Border.all(color: ColorManager.primary, width: 2),
              image: EndPoints.getImage(
                user?.image ?? '',
              ),
              displayName: user?.name ?? '',
            ),
            10.wBox,
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 100.w,
                minWidth: 1.w,
              ),
              child: TextWidget(
                user?.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            8.wBox,
            Container(
              height: 25.h,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: ColorManager.grey.withValues(alpha: (0.4)),
                borderRadius: 20.radius,
              ),
              child: IntrinsicWidth(
                child: Row(
                  children: [
                    TextWidget(
                      user?.countryModel?.iso ?? '',
                      style: context.bodyMedium.w500
                          .copyWith(fontSize: 10.sp, height: 0.6),
                    ),
                    user?.countryModel?.iso == '' ? const SizedBox() : 5.wBox,
                    ImageViewWidget(
                      url: EndPoints.getImage('${user?.countryModel?.photo}'),
                      height: 17.5,
                      width: 17.5,
                      boxFit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            TextWidget(
              user?.total ?? '',
              style: context.bodyLarge.colorExt(ColorManager.primary),
            ),
          ],
        ),
      ),
    );
  }
}
