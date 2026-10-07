import 'package:general/src/core/services/dynamic_link_handler.dart';
import 'package:general/src/features/setting/presentation/invitation/bloc/invite_bloc.dart';
import 'package:general/src/features/setting/presentation/invitation/view/widgets/explain_invite_card.dart';
import 'package:general/src/features/setting/presentation/invitation/view/widgets/profit_card.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/index.dart';

class InviteScreenDetails extends StatefulWidget {
  const InviteScreenDetails({super.key});

  @override
  State<InviteScreenDetails> createState() => InviteScreenDetailsState();
}

class InviteScreenDetailsState extends State<InviteScreenDetails> {
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

  Future<void> _shareInvitation() async {
    final link = await DynamicLinkHandler.instance.createDynamicLink(
      MyDataModel.getInstance().uuid.toString(),
      'invitation_code',
    );

    await SharePlus.instance.share(
      ShareParams(uri: Uri.parse(link)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SendInviteBloc, SendInviteState>(
      bloc: di<SendInviteBloc>(),
      listener: (context, state) {
        if (state.addInviteRequest.isLoaded) {
          Methods.showToast(context, message: state.addInviteMessage);
          Navigator.pop(context);
        } else if (state.addInviteRequest.isError) {
          Methods.showToast(
            context,
            isError: true,
            message: state.addInviteMessage,
          );
          Navigator.pop(context);
        } else if (state.addInviteRequest.isLoading) {
          Methods.showToast(context, isLoading: true);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFE9D2),
        extendBodyBehindAppBar: true,
        appBar: AppBarWidget(
          backgroundColor: Colors.transparent,
          iconColor: Colors.white,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 21,
            shadows: [
              Shadow(
                color: Color(0x55000000),
                blurRadius: 7,
                offset: Offset(0, 2),
              ),
            ],
          ),
          title: StringManager.invitation.tr(),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                AssetsManager.inviteBg,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x00000000),
                      Color(0x00000000),
                      Color(0x08FFF4E7),
                      Color(0x20FFF4E7),
                    ],
                    stops: [0.0, 0.30, 0.62, 1.0],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: EdgeInsets.only(bottom: 14.h),
                child: Column(
                  children: [
                    // Compact hero area: keeps the coin/gift artwork visible
                    // while allowing the full invitation UI to sit much higher.
                    SizedBox(height: 250.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Column(
                        children: [
                          const RepaintBoundary(child: ProfitCard()),
                          9.hBox,
                          RepaintBoundary(
                            child: _InvitationCodeCard(
                              onShare: _shareInvitation,
                            ),
                          ),
                          9.hBox,
                          const RepaintBoundary(child: ExplainInviteCard()),
                          11.hBox,
                          _InviteUsersButton(onPressed: _shareInvitation),
                          10.hBox,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvitationCodeCard extends StatelessWidget {
  const _InvitationCodeCard({required this.onShare});

  final Future<void> Function() onShare;

  @override
  Widget build(BuildContext context) {
    final code = MyDataModel.getInstance().uuid.toString();

    return Container(
      width: double.infinity,
      decoration: _white3DDecoration(),
      child: Column(
        children: [
          _OrangeRibbon(
            icon: Icons.card_giftcard_rounded,
            title: StringManager.yourInvitationCode.tr(),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
            child: Column(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    Methods.showToast(
                      context,
                      message: StringManager.theTextHasBeenCopied.tr(),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF9EC), Color(0xFFFFE9C4)],
                      ),
                      borderRadius: BorderRadius.circular(13.r),
                      border: Border.all(color: const Color(0xFFFFBD56)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFA63D)
                              .withValues(alpha: 0.12),
                          blurRadius: 7.r,
                          offset: Offset(0, 3.h),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.monetization_on_rounded,
                          color: const Color(0xFFFF9D13),
                          size: 19.h,
                        ),
                        6.wBox,
                        TextWidget(
                          code,
                          isTranslate: false,
                          style: context.bodyLarge
                              .size(20)
                              .bold
                              .colorExt(const Color(0xFFFF5A32)),
                        ),
                        6.wBox,
                        Icon(
                          Icons.copy_rounded,
                          size: 16.h,
                          color: const Color(0xFFFF713D),
                        ),
                      ],
                    ),
                  ),
                ),
                7.hBox,
                TextWidget(
                  StringManager.invitationHint.tr(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodyMedium
                      .size(10.5)
                      .colorExt(const Color(0xFF6F625E))
                      .copyWith(height: 1.25, fontFamily: 'AppFont'),
                ),
                9.hBox,
                Row(
                  children: [
                    Expanded(
                      child: _GradientActionButton(
                        icon: Icons.ios_share_rounded,
                        title: StringManager.inviteFriends.tr(),
                        onTap: () => onShare(),
                      ),
                    ),
                    8.wBox,
                    Expanded(
                      child: _GradientActionButton(
                        icon: Icons.edit_note_rounded,
                        title: StringManager.fillInInvitationCode.tr(),
                        onTap: () => _showInviteCodeDialog(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInviteCodeDialog(BuildContext context) {
    final inviteCodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          titlePadding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 6.h),
          contentPadding: EdgeInsets.fromLTRB(18.w, 6.h, 18.w, 12.h),
          actionsPadding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 16.h),
          title: Column(
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFCB42), Color(0xFFFF6A42)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.redeem_rounded,
                  color: Colors.white,
                  size: 25.h,
                ),
              ),
              8.hBox,
              TextWidget(
                StringManager.receiveAward.tr(),
                textAlign: TextAlign.center,
                style: context.bodyLarge
                    .size(16)
                    .bold
                    .colorExt(const Color(0xFF29211F)),
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
                    .size(12)
                    .colorExt(const Color(0xFF6F625E)),
              ),
              10.hBox,
              TextField(
                controller: inviteCodeController,
                textAlign: TextAlign.center,
                cursorColor: Colors.black,
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: StringManager.enterCode.tr(),
                  hintStyle: TextStyle(
                    color: Colors.black.withValues(alpha: 0.45),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 11.h,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: Colors.black.withValues(alpha: 0.45),
                      width: 1.1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 1.6,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(
                      color: Color(0xFFFF4D4D),
                      width: 1.2,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(
                      color: Color(0xFFFF4D4D),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: 220.w,
              child: _GradientActionButton(
                icon: Icons.check_circle_rounded,
                title: StringManager.submit.tr(),
                onTap: () {
                  final code = inviteCodeController.text.trim();
                  if (code.isNotEmpty) {
                    di<SendInviteBloc>().add(AddInviteEvent(code: code));
                  } else {
                    Methods.showToast(
                      context,
                      isError: true,
                      message: StringManager.enterValidCode.tr(),
                    );
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OrangeRibbon extends StatelessWidget {
  const _OrangeRibbon({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFFF5B54),
            Color(0xFFFF7547),
            Color(0xFFFFA23E),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B48).withValues(alpha: 0.18),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18.h),
          6.wBox,
          Flexible(
            child: TextWidget(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.bodyLarge
                  .size(14)
                  .bold
                  .colorExt(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientActionButton extends StatelessWidget {
  const _GradientActionButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22.r),
        onTap: onTap,
        child: Ink(
          height: 40.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFB441),
                Color(0xFFFF7043),
                Color(0xFFFF425F),
              ],
            ),
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: Colors.white, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF624B).withValues(alpha: 0.22),
                blurRadius: 8.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: TextWidget(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.bodyMedium
                        .size(11)
                        .bold
                        .colorExt(Colors.white),
                  ),
                ),
                4.wBox,
                Icon(icon, color: Colors.white, size: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InviteUsersButton extends StatelessWidget {
  const _InviteUsersButton({required this.onPressed});

  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(27.r),
        onTap: () => onPressed(),
        child: Ink(
          width: 245.w,
          height: 49.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFC343),
                Color(0xFFFF7744),
                Color(0xFFFF375F),
              ],
            ),
            borderRadius: BorderRadius.circular(27.r),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF5A43).withValues(alpha: 0.25),
                blurRadius: 13.r,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextWidget(
                StringManager.inviteFriends.tr(),
                style: context.bodyLarge
                    .size(15)
                    .bold
                    .colorExt(Colors.white),
              ),
              7.wBox,
              Icon(Icons.ios_share_rounded, color: Colors.white, size: 19.h),
            ],
          ),
        ),
      ),
    );
  }
}

BoxDecoration _white3DDecoration() {
  return BoxDecoration(
    color: const Color(0xFFFFFEFC),
    borderRadius: BorderRadius.circular(18.r),
    border: Border.all(color: Colors.white, width: 1.2),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFFB85C25).withValues(alpha: 0.12),
        blurRadius: 12.r,
        offset: Offset(0, 5.h),
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.60),
        blurRadius: 2.r,
        offset: Offset(0, -1.h),
      ),
    ],
  );
}
