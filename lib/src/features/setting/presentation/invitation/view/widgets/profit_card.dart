import 'package:general/src/features/setting/presentation/invitation/bloc/invite_bloc.dart';

import '../../../../../../core/index.dart';

class ProfitCard extends StatelessWidget {
  const ProfitCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEFC),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB85C25).withValues(alpha: 0.12),
            blurRadius: 12.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: BlocBuilder<SendInviteBloc, SendInviteState>(
        bloc: di<SendInviteBloc>(),
        buildWhen: (prev, curr) =>
        prev.getMyEarnInviteRequest != curr.getMyEarnInviteRequest ||
            prev.getMyEarnInviteSuccess != curr.getMyEarnInviteSuccess,
        builder: (context, state) {
          return HandlingDataWidget(
            reqState: state.getMyEarnInviteRequest,
            title: '',
            subTitle: '',
            child: Column(
              children: [
                Container(
                  width: 190.w,
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF5A53),
                        Color(0xFFFF7348),
                        Color(0xFFFFA33E),
                      ],
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(17.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF7048)
                            .withValues(alpha: 0.18),
                        blurRadius: 8.r,
                        offset: Offset(0, 3.h),
                      ),
                    ],
                  ),
                  child: TextWidget(
                    StringManager.myInviteIncome.tr(),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.bodyLarge
                        .size(14)
                        .bold
                        .colorExt(Colors.white),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 9.h),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _RevenueStat(
                              icon: Icons.savings_rounded,
                              value: state.getMyEarnInviteSuccess?.totalEarned
                                  .toString() ??
                                  '0',
                              label: StringManager.totalEarned.tr(),
                            ),
                          ),
                          const _VerticalLine(),
                          Expanded(
                            child: _RevenueStat(
                              icon: Icons.calendar_month_rounded,
                              value: state.getMyEarnInviteSuccess?.dayEarned
                                  .toString() ??
                                  '0',
                              label: StringManager.dayEarned.tr(),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 7.h),
                        child: const Divider(
                          height: 1,
                          color: Color(0xFFFFD8AE),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _RevenueStat(
                              icon: Icons.groups_rounded,
                              value: state.getMyEarnInviteSuccess?.totalInvited
                                  .toString() ??
                                  '0',
                              label: StringManager.totalInvited.tr(),
                            ),
                          ),
                          const _VerticalLine(),
                          Expanded(
                            child: _RevenueStat(
                              icon: Icons.person_add_alt_1_rounded,
                              value: state.getMyEarnInviteSuccess?.dayInvited
                                  .toString() ??
                                  '0',
                              label: StringManager.dayInvited.tr(),
                            ),
                          ),
                        ],
                      ),
                      8.hBox,
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18.r),
                          onTap: () =>
                              Navigator.pushNamed(context, Routes.inviteUser),
                          child: Ink(
                            padding: EdgeInsets.symmetric(
                              horizontal: 17.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEEE1),
                              borderRadius: BorderRadius.circular(18.r),
                              border: Border.all(
                                color: const Color(0xFFFFC28B),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextWidget(
                                  StringManager.watch.tr(),
                                  style: context.bodyMedium
                                      .size(10)
                                      .bold
                                      .colorExt(const Color(0xFFFF6740)),
                                ),
                                4.wBox,
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 9.h,
                                  color: const Color(0xFFFF6740),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _VerticalLine extends StatelessWidget {
  const _VerticalLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 43.h,
      color: const Color(0xFFFFD8AE),
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
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 31.w,
            height: 31.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFD95A), Color(0xFFFF8B31)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFA02C).withValues(alpha: 0.16),
                  blurRadius: 5.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 16.h),
          ),
          6.wBox,
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextWidget(
                  value,
                  isTranslate: false,
                  maxLines: 1,
                  style: context.bodyLarge
                      .size(17)
                      .bold
                      .colorExt(const Color(0xFFFF5E37)),
                ),
                TextWidget(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodyMedium
                      .size(8.8)
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
