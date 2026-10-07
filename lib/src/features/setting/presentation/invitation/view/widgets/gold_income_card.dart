import 'package:general/src/features/setting/presentation/invitation/bloc/invite_bloc.dart';

import '../../../../../../core/index.dart';

class GoldIncomeCard extends StatelessWidget {
  const GoldIncomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SendInviteBloc, SendInviteState>(
      bloc: di<SendInviteBloc>(),
      buildWhen: (prev, curr) =>
      prev.getMyEarnInviteRequest != curr.getMyEarnInviteRequest ||
          prev.getMyEarnInviteSuccess != curr.getMyEarnInviteSuccess ||
          prev.extractCoinsRequest != curr.extractCoinsRequest ||
          prev.claimBonusRequest != curr.claimBonusRequest,
      builder: (context, state) {
        final data = state.getMyEarnInviteSuccess;
        final income = data?.claimableIncome ?? 0;
        final bonus = data?.claimableBonus ?? 0;
        final limit = data?.withdrawalLimit ?? 50000;
        final percent = data?.commissionPercent ?? 0;
        final canExtract = income > 0;

        return Column(
          children: [
            _RewardSectionCard(
              number: '1',
              title: StringManager.commissionPercent.tr(),
              icon: Icons.monetization_on_rounded,
              value: '$percent%',
              description: StringManager.claimableNow.tr(),
              rightIcon: Icons.account_balance_wallet_rounded,
              rightValue: income.toString(),
              rightDescription: StringManager.myInviteIncome.tr(),
              footer: Column(
                children: [
                  14.hBox,
                  _GradientActionButton(
                    title: StringManager.extractCoins.tr(),
                    icon: Icons.wallet_rounded,
                    enabled: canExtract && !state.extractCoinsRequest.isLoading,
                    loading: state.extractCoinsRequest.isLoading,
                    onTap: () =>
                        di<SendInviteBloc>().add(ExtractInviteCoinsEvent()),
                  ),
                  8.hBox,
                  TextWidget(
                    '${StringManager.extractUpTo.tr()} $limit ${StringManager.coinsPerRequest.tr()}',
                    isTranslate: false,
                    textAlign: TextAlign.center,
                    style: context.bodyMedium
                        .size(10)
                        .colorExt(const Color(0xFF7D706B)),
                  ),
                  if (!canExtract) ...[
                    4.hBox,
                    TextWidget(
                      StringManager.noIncomeToExtract.tr(),
                      textAlign: TextAlign.center,
                      style: context.bodyMedium
                          .size(10)
                          .colorExt(Colors.black45),
                    ),
                  ],
                ],
              ),
            ),
            if (bonus > 0) ...[
              14.hBox,
              _RewardSectionCard(
                number: '2',
                title: StringManager.oneTimeBonus.tr(),
                icon: Icons.card_giftcard_rounded,
                value: bonus.toString(),
                description: StringManager.invitationRewards.tr(),
                rightIcon: Icons.workspace_premium_rounded,
                rightValue: StringManager.claimBonus.tr(),
                rightDescription: StringManager.inviteFriendsTitle.tr(),
                compactRightValue: true,
                footer: Padding(
                  padding: EdgeInsets.only(top: 14.h),
                  child: _GradientActionButton(
                    title: StringManager.claimBonus.tr(),
                    icon: Icons.redeem_rounded,
                    enabled: !state.claimBonusRequest.isLoading,
                    loading: state.claimBonusRequest.isLoading,
                    onTap: () =>
                        di<SendInviteBloc>().add(ClaimInviteBonusEvent()),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _RewardSectionCard extends StatelessWidget {
  const _RewardSectionCard({
    required this.number,
    required this.title,
    required this.icon,
    required this.value,
    required this.description,
    required this.rightIcon,
    required this.rightValue,
    required this.rightDescription,
    required this.footer,
    this.compactRightValue = false,
  });

  final String number;
  final String title;
  final IconData icon;
  final String value;
  final String description;
  final IconData rightIcon;
  final String rightValue;
  final String rightDescription;
  final Widget footer;
  final bool compactRightValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB35A20).withValues(alpha: 0.12),
            blurRadius: 16.r,
            offset: Offset(0, 7.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(12.w, 10.h, 16.w, 10.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFFFF5B58),
                  Color(0xFFFF754C),
                  Color(0xFFFFAE3B),
                ],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(21.r)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFFFE865), Color(0xFFFF9B2D)],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 7.r,
                        offset: Offset(0, 3.h),
                      ),
                    ],
                  ),
                  child: TextWidget(
                    number,
                    isTranslate: false,
                    style: context.bodyLarge
                        .size(22)
                        .bold
                        .colorExt(ColorManager.white),
                  ),
                ),
                10.wBox,
                Expanded(
                  child: TextWidget(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.bodyMedium
                        .size(14)
                        .bold
                        .colorExt(ColorManager.white),
                  ),
                ),
                Icon(
                  Icons.card_giftcard_rounded,
                  color: Colors.white.withValues(alpha: 0.92),
                  size: 30.h,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 16.h),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _RewardValueBox(
                        icon: icon,
                        value: value,
                        description: description,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: TextWidget(
                        '+',
                        isTranslate: false,
                        style: context.bodyLarge
                            .size(32)
                            .bold
                            .colorExt(const Color(0xFFFFA24A)),
                      ),
                    ),
                    Expanded(
                      child: _RewardValueBox(
                        icon: rightIcon,
                        value: rightValue,
                        description: rightDescription,
                        compactValue: compactRightValue,
                      ),
                    ),
                  ],
                ),
                footer,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardValueBox extends StatelessWidget {
  const _RewardValueBox({
    required this.icon,
    required this.value,
    required this.description,
    this.compactValue = false,
  });

  final IconData icon;
  final String value;
  final String description;
  final bool compactValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 105.h),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFCF7), Color(0xFFFFF0D4)],
        ),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: const Color(0xFFFFC880)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFA048).withValues(alpha: 0.10),
            blurRadius: 7.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFFFFA000), size: 27.h),
              7.wBox,
              Flexible(
                child: TextWidget(
                  value,
                  isTranslate: false,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodyLarge
                      .size(compactValue ? 12 : 21)
                      .bold
                      .colorExt(const Color(0xFFE63B24)),
                ),
              ),
            ],
          ),
          8.hBox,
          TextWidget(
            description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.bodyMedium
                .size(10)
                .colorExt(const Color(0xFF6F6461)),
          ),
        ],
      ),
    );
  }
}

class _GradientActionButton extends StatelessWidget {
  const _GradientActionButton({
    required this.title,
    required this.icon,
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: enabled ? 1 : 0.45,
        child: Container(
          height: 46.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFB13D), Color(0xFFFF674F)],
            ),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF7043).withValues(alpha: 0.22),
                blurRadius: 10.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: loading
              ? SizedBox(
            width: 20.w,
            height: 20.w,
            child: const CircularProgressIndicator(
              strokeWidth: 2.2,
              color: Colors.white,
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 19.h),
              7.wBox,
              Flexible(
                child: TextWidget(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodyMedium
                      .size(13)
                      .bold
                      .colorExt(ColorManager.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
