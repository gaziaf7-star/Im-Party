import 'package:general/src/core/index.dart';
import 'package:general/src/features/setting/domain/entities/invite_user_entity.dart';

class UserDetailsForParent extends StatelessWidget {
  final InvitationUsersEntity data;

  const UserDetailsForParent({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0xFFF0E6E1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 16.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFC343),
                      Color(0xFFFF7744),
                      Color(0xFFFF375F),
                    ],
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: UserImage(
                    image: data.image,
                    displayName: data.name,
                    imageSize: 52.w,
                  ),
                ),
              ),
              12.wBox,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GradientName(child: TextWidget(
                      data.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodyMedium
                          .size(16)
                          .bold
                          .colorExt(Colors.black),
                    )),
                    5.hBox,
                    Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 15.h,
                          color: Colors.black.withValues(alpha: 0.48),
                        ),
                        5.wBox,
                        Flexible(
                          child: TextWidget(
                            '${StringManager.userID.tr()}: ${data.invitedId}',
                            isTranslate: false,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.bodySmall
                                .size(12)
                                .colorExt(
                              Colors.black.withValues(alpha: 0.58),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 9.w,
                  vertical: 5.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2E9),
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(
                    color: const Color(0xFFFFD5BD),
                  ),
                ),
                child: TextWidget(
                  '${data.parentPercentage}%',
                  isTranslate: false,
                  style: context.bodySmall
                      .size(12)
                      .bold
                      .colorExt(const Color(0xFFFF5C3E)),
                ),
              ),
            ],
          ),
          13.hBox,
          Container(
            height: 1,
            color: const Color(0xFFF2F2F2),
          ),
          12.hBox,
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.monetization_on_rounded,
                  label: StringManager.coinsCharged.tr(),
                  value: data.userCharge.toString(),
                ),
              ),
              Container(
                width: 1,
                height: 42.h,
                margin: EdgeInsets.symmetric(horizontal: 8.w),
                color: const Color(0xFFF0F0F0),
              ),
              Expanded(
                child: _InfoTile(
                  icon: Icons.percent_rounded,
                  label: StringManager.percentage.tr(),
                  value: '${data.parentPercentage}%',
                ),
              ),
            ],
          ),
          if (data.date.trim().isNotEmpty) ...[
            11.hBox,
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 8.h,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(11.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14.h,
                    color: Colors.black.withValues(alpha: 0.45),
                  ),
                  7.wBox,
                  TextWidget(
                    '${StringManager.date.tr()}: ',
                    style: context.bodySmall
                        .size(11)
                        .colorExt(
                      Colors.black.withValues(alpha: 0.50),
                    ),
                  ),
                  Expanded(
                    child: TextWidget(
                      data.date,
                      isTranslate: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodySmall
                          .size(11)
                          .w600
                          .colorExt(
                        Colors.black.withValues(alpha: 0.72),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFF4D8),
                Color(0xFFFFE4D6),
              ],
            ),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            size: 18.h,
            color: const Color(0xFFFF6B43),
          ),
        ),
        8.wBox,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                value,
                isTranslate: false,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodyMedium
                    .size(15)
                    .bold
                    .colorExt(Colors.black),
              ),
              2.hBox,
              TextWidget(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodySmall
                    .size(10.5)
                    .colorExt(
                  Colors.black.withValues(alpha: 0.50),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
