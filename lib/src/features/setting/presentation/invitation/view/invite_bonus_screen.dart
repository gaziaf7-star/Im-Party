import 'package:general/src/core/services/dynamic_link_handler.dart';
import 'package:general/src/features/setting/presentation/invitation/bloc/invite_bloc.dart';
import 'package:general/src/features/setting/presentation/invitation/view/widgets/gold_commission_card.dart';
import 'package:general/src/features/setting/presentation/invitation/view/widgets/gold_income_card.dart';
import 'package:general/src/features/setting/presentation/invitation/view/widgets/gold_invitations_card.dart';
import 'package:general/src/features/setting/presentation/invitation/view/widgets/gold_rules_card.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/index.dart';

class InviteBonusScreen extends StatefulWidget {
  const InviteBonusScreen({super.key});

  @override
  State<InviteBonusScreen> createState() => _InviteBonusScreenState();
}

class _InviteBonusScreenState extends State<InviteBonusScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = di<SendInviteBloc>();
    if (!bloc.state.explainInviteRequest.isLoaded) {
      bloc.add(ExplainInviteEvent());
    }
    if (!bloc.state.getMyEarnInviteRequest.isLoaded) {
      bloc.add(GetMyEarnInviteEvent());
    }
  }

  Future<void> _shareCode() async {
    final code = MyDataModel.getInstance().uuid.toString();
    final link = await DynamicLinkHandler.instance.createDynamicLink(
      code,
      'invitation_code',
    );
    await SharePlus.instance.share(ShareParams(uri: Uri.parse(link)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE9CE),
      extendBodyBehindAppBar: true,
      appBar: AppBarWidget(
        backgroundColor: ColorManager.transparent,
        iconColor: ColorManager.white,
        titleStyle: context.bodyLarge.bold.colorExt(ColorManager.white),
        title: StringManager.inviteFriendsTitle.tr(),
      ),
      body: BlocListener<SendInviteBloc, SendInviteState>(
        bloc: di<SendInviteBloc>(),
        listenWhen: (prev, curr) =>
        prev.extractCoinsRequest != curr.extractCoinsRequest ||
            prev.claimBonusRequest != curr.claimBonusRequest ||
            prev.addInviteRequest != curr.addInviteRequest,
        listener: (context, state) {
          if (state.extractCoinsRequest.isLoading ||
              state.claimBonusRequest.isLoading ||
              state.addInviteRequest.isLoading) {
            Methods.showToast(context, isLoading: true);
            return;
          }
          if (state.extractCoinsRequest.isLoaded) {
            Methods.showToast(context, message: state.extractCoinsMessage);
          } else if (state.extractCoinsRequest.isError) {
            Methods.showToast(
              context,
              isError: true,
              message: state.extractCoinsMessage,
            );
          } else if (state.claimBonusRequest.isLoaded) {
            Methods.showToast(context, message: state.claimBonusMessage);
          } else if (state.claimBonusRequest.isError) {
            Methods.showToast(
              context,
              isError: true,
              message: state.claimBonusMessage,
            );
          } else if (state.addInviteRequest.isLoaded) {
            Methods.showToast(context, message: state.addInviteMessage);
          } else if (state.addInviteRequest.isError) {
            Methods.showToast(
              context,
              isError: true,
              message: state.addInviteMessage,
            );
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE9CE),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFF754D),
                      Color(0xFFFFA34A),
                      Color(0xFFFFE2BB),
                      Color(0xFFFFEEDB),
                    ],
                    stops: [0.0, 0.20, 0.48, 1.0],
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: 128.h),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 360.h,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          AssetsManager.inviteBg,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x14000000),
                                Color(0x00000000),
                                Color(0x00FFFFFF),
                              ],
                              stops: [0.0, 0.55, 1.0],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 24.w,
                          right: 24.w,
                          bottom: 10.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _HeroTag(
                                icon: Icons.groups_rounded,
                                text: StringManager.inviteFriendsTitle.tr(),
                              ),
                              _HeroTag(
                                icon: Icons.workspace_premium_rounded,
                                text: StringManager.invitationRewards.tr(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    child: Column(
                      children: [
                        GoldCommissionCard(onShare: _shareCode),
                        14.hBox,
                        const GoldInvitationsCard(),
                        14.hBox,
                        const GoldIncomeCard(),
                        14.hBox,
                        const GoldRulesCard(),
                        14.hBox,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: EdgeInsets.fromLTRB(18.w, 6.h, 18.w, 10.h),
        child: _InviteBottomButton(onPressed: _shareCode),
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  const _HeroTag({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 155.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16.h),
          6.wBox,
          Flexible(
            child: TextWidget(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.bodyMedium
                  .size(11)
                  .bold
                  .colorExt(ColorManager.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteBottomButton extends StatelessWidget {
  const _InviteBottomButton({required this.onPressed});

  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed(),
      child: Container(
        height: 62.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFB547),
              Color(0xFFFF7043),
              Color(0xFFFF376D),
            ],
          ),
          borderRadius: BorderRadius.circular(32.r),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF5A45).withValues(alpha: 0.34),
              blurRadius: 20.r,
              offset: Offset(0, 8.h),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.38),
              blurRadius: 3.r,
              offset: Offset(0, -1.h),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWidget(
              StringManager.inviteNow.tr(),
              style: context.bodyLarge
                  .size(18)
                  .bold
                  .colorExt(ColorManager.white),
            ),
            10.wBox,
            Icon(Icons.ios_share_rounded, color: Colors.white, size: 24.h),
          ],
        ),
      ),
    );
  }
}
