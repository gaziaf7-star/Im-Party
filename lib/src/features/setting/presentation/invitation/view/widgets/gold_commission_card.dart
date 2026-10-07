import 'package:general/src/features/setting/presentation/invitation/bloc/invite_bloc.dart';

import '../../../../../../core/index.dart';

class GoldCommissionCard extends StatelessWidget {
  const GoldCommissionCard({super.key, required this.onShare});

  final Future<void> Function() onShare;

  @override
  Widget build(BuildContext context) {
    final code = MyDataModel.getInstance().uuid.toString();

    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _HeaderRibbon(title: StringManager.invitationRewards.tr()),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 18.h),
            child: BlocBuilder<SendInviteBloc, SendInviteState>(
              bloc: di<SendInviteBloc>(),
              buildWhen: (prev, curr) =>
              prev.getMyEarnInviteSuccess != curr.getMyEarnInviteSuccess,
              builder: (context, state) {
                final percent =
                    state.getMyEarnInviteSuccess?.commissionPercent ?? 0;

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _RewardMetric(
                            icon: Icons.monetization_on_rounded,
                            value: '$percent%',
                            label: StringManager.commissionPercent.tr(),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 72.h,
                          color: const Color(0xFFFFC68B),
                        ),
                        Expanded(
                          child: _RewardMetric(
                            icon: Icons.card_giftcard_rounded,
                            value: StringManager.inviteBonus.tr(),
                            label: StringManager.invitationRewards.tr(),
                            compactValue: true,
                          ),
                        ),
                      ],
                    ),
                    18.hBox,
                    _CodeRow(code: code),
                    18.hBox,
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.share_rounded,
                            label: StringManager.shareInviteCode.tr(),
                            onTap: () => onShare(),
                          ),
                        ),
                        10.wBox,
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.copy_rounded,
                            label: StringManager.invitationCode.tr(),
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: code));
                              Methods.showToast(
                                context,
                                message:
                                StringManager.theTextHasBeenCopied.tr(),
                              );
                            },
                          ),
                        ),
                        10.wBox,
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.edit_note_rounded,
                            label: StringManager.fillInInvitationCode.tr(),
                            onTap: () => _showRedeemDialog(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showRedeemDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          titlePadding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 8.h),
          contentPadding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
          actionsPadding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
          title: Column(
            children: [
              Container(
                width: 52.w,
                height: 52.w,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFC940), Color(0xFFFF7043)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.redeem_rounded,
                  color: Colors.white,
                  size: 28.h,
                ),
              ),
              12.hBox,
              TextWidget(
                StringManager.receiveAward.tr(),
                textAlign: TextAlign.center,
                style: context.bodyLarge
                    .size(18)
                    .bold
                    .colorExt(ColorManager.black),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextWidget(
                StringManager.enterInvitationCode.tr(),
                textAlign: TextAlign.center,
                style: context.bodyMedium
                    .size(13)
                    .colorExt(Colors.black54),
              ),
              14.hBox,
              TextField(
                controller: controller,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: StringManager.enterCode.tr(),
                  filled: true,
                  fillColor: const Color(0xFFFFF7EC),
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: const BorderSide(color: Color(0xFFFFD09C)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide:
                    const BorderSide(color: Color(0xFFFF874E), width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            GestureDetector(
              onTap: () {
                final inviteCode = controller.text.trim();
                Navigator.pop(ctx);
                if (inviteCode.isNotEmpty) {
                  di<SendInviteBloc>().add(AddInviteEvent(code: inviteCode));
                } else {
                  Methods.showToast(
                    context,
                    isError: true,
                    message: StringManager.enterValidCode.tr(),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                height: 48.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB240), Color(0xFFFF5D57)],
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF7043).withValues(alpha: 0.25),
                      blurRadius: 12.r,
                      offset: Offset(0, 5.h),
                    ),
                  ],
                ),
                child: TextWidget(
                  StringManager.submit.tr(),
                  style: context.bodyMedium
                      .size(15)
                      .bold
                      .colorExt(ColorManager.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24.r),
    border: Border.all(color: Colors.white, width: 1.5),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFFB35A20).withValues(alpha: 0.13),
        blurRadius: 18.r,
        offset: Offset(0, 8.h),
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.90),
        blurRadius: 2.r,
        offset: Offset(0, -1.h),
      ),
    ],
  );
}

class _HeaderRibbon extends StatelessWidget {
  const _HeaderRibbon({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFFF5C54),
            Color(0xFFFF7D4E),
            Color(0xFFFFAA3D),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(23.r)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF714C).withValues(alpha: 0.20),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: TextWidget(
        title,
        textAlign: TextAlign.center,
        style: context.bodyLarge
            .size(18)
            .bold
            .colorExt(ColorManager.white),
      ),
    );
  }
}

class _RewardMetric extends StatelessWidget {
  const _RewardMetric({
    required this.icon,
    required this.value,
    required this.label,
    this.compactValue = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool compactValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 46.w,
          height: 46.w,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFE573), Color(0xFFFF9B32)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFA126).withValues(alpha: 0.28),
                blurRadius: 10.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 25.h),
        ),
        8.hBox,
        TextWidget(
          value,
          isTranslate: false,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.bodyLarge
              .size(compactValue ? 13 : 25)
              .bold
              .colorExt(const Color(0xFFFF5C35)),
        ),
        3.hBox,
        TextWidget(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.bodyMedium.size(11).colorExt(Colors.black54),
        ),
      ],
    );
  }
}

class _CodeRow extends StatelessWidget {
  const _CodeRow({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFBF4), Color(0xFFFFF0D8)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFFFCC8A)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFA44A).withValues(alpha: 0.10),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: const BoxDecoration(
              color: Color(0xFFFFA23A),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.confirmation_number_rounded,
                color: Colors.white, size: 19.h),
          ),
          10.wBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  StringManager.invitationCode.tr(),
                  style: context.bodyMedium.size(10).colorExt(Colors.black54),
                ),
                2.hBox,
                TextWidget(
                  code,
                  isTranslate: false,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodyMedium
                      .size(16)
                      .bold
                      .colorExt(ColorManager.black),
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: () {
              Clipboard.setData(ClipboardData(text: code));
              Methods.showToast(
                context,
                message: StringManager.theTextHasBeenCopied.tr(),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Icon(
                Icons.copy_rounded,
                color: const Color(0xFFFF7043),
                size: 20.h,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: onTap,
      child: Container(
        height: 76.h,
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8EF),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFFFD4A4)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFFF7043), size: 24.h),
            5.hBox,
            TextWidget(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: context.bodyMedium
                  .size(9.5)
                  .w600
                  .colorExt(const Color(0xFF574A46)),
            ),
          ],
        ),
      ),
    );
  }
}
