import 'package:general/src/features/setting/presentation/invitation/bloc/invite_bloc.dart';

import '../../../../../../core/index.dart';

class GoldInvitationsCard extends StatelessWidget {
  const GoldInvitationsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: _revenueCardDecoration(),
      child: BlocBuilder<SendInviteBloc, SendInviteState>(
        bloc: di<SendInviteBloc>(),
        buildWhen: (prev, curr) =>
        prev.getMyEarnInviteRequest != curr.getMyEarnInviteRequest ||
            prev.getMyEarnInviteSuccess != curr.getMyEarnInviteSuccess,
        builder: (context, state) {
          final data = state.getMyEarnInviteSuccess;

          return Column(
            children: [
              Container(
                width: 235.w,
                padding: EdgeInsets.symmetric(vertical: 11.h, horizontal: 18.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5C54), Color(0xFFFFA63E)],
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF754B).withValues(alpha: 0.24),
                      blurRadius: 12.r,
                      offset: Offset(0, 5.h),
                    ),
                  ],
                ),
                child: TextWidget(
                  StringManager.myInvitations.tr(),
                  textAlign: TextAlign.center,
                  style: context.bodyLarge
                      .size(18)
                      .bold
                      .colorExt(ColorManager.white),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 20.h, 14.w, 14.h),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _RevenueStat(
                            icon: Icons.savings_rounded,
                            value: data?.totalEarned ?? 0,
                            label: StringManager.totalEarned.tr(),
                          ),
                        ),
                        _VerticalDivider(),
                        Expanded(
                          child: _RevenueStat(
                            icon: Icons.today_rounded,
                            value: data?.dayEarned ?? 0,
                            label: StringManager.dayEarned.tr(),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Divider(
                        height: 1,
                        color: const Color(0xFFFFDAB2),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _RevenueStat(
                            icon: Icons.groups_2_rounded,
                            value: data?.totalInvited ?? 0,
                            label: StringManager.totalInvited.tr(),
                          ),
                        ),
                        _VerticalDivider(),
                        Expanded(
                          child: _RevenueStat(
                            icon: Icons.person_add_alt_1_rounded,
                            value: data?.dayInvited ?? 0,
                            label: StringManager.dayInvited.tr(),
                          ),
                        ),
                      ],
                    ),
                    16.hBox,
                    InkWell(
                      borderRadius: BorderRadius.circular(20.r),
                      onTap: () =>
                          Navigator.pushNamed(context, Routes.inviteUser),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 9.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEEE2),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: const Color(0xFFFFC392)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextWidget(
                              StringManager.watch.tr(),
                              style: context.bodyMedium
                                  .size(12)
                                  .bold
                                  .colorExt(const Color(0xFFFF6A3D)),
                            ),
                            5.wBox,
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: const Color(0xFFFF6A3D),
                              size: 12.h,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

BoxDecoration _revenueCardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24.r),
    border: Border.all(color: Colors.white, width: 1.5),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFFB35A20).withValues(alpha: 0.12),
        blurRadius: 18.r,
        offset: Offset(0, 8.h),
      ),
    ],
  );
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 62.h,
      color: const Color(0xFFFFDAB2),
    );
  }
}

class _RevenueStat extends StatelessWidget {
  const _RevenueStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFD45D), Color(0xFFFF8E35)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFA02D).withValues(alpha: 0.18),
                  blurRadius: 7.r,
                  offset: Offset(0, 3.h),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 19.h),
          ),
          9.wBox,
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  value.toString(),
                  isTranslate: false,
                  maxLines: 1,
                  style: context.bodyLarge
                      .size(22)
                      .bold
                      .colorExt(const Color(0xFFFF663B)),
                ),
                2.hBox,
                TextWidget(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodyMedium
                      .size(10)
                      .colorExt(const Color(0xFF6D6260)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
