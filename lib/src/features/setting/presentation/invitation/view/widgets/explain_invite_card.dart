import 'package:general/src/features/setting/presentation/invitation/bloc/invite_bloc.dart';

import '../../../../../../core/index.dart';

class ExplainInviteCard extends StatelessWidget {
  const ExplainInviteCard({super.key});

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
            color: const Color(0xFFB85C25).withValues(alpha: 0.10),
            blurRadius: 11.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFFFF5A53),
                  Color(0xFFFF7548),
                  Color(0xFFFFA43F),
                ],
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(18.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 27.w,
                  height: 27.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.36),
                    ),
                  ),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 15.h,
                  ),
                ),
                7.wBox,
                Expanded(
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      text: StringManager.howToGainFreeCoins.tr(),
                      style: context.bodyMedium
                          .size(11)
                          .bold
                          .colorExt(Colors.white)
                          .copyWith(fontFamily: 'AppFont'),
                      children: <TextSpan>[
                        TextSpan(
                          text: StringManager.freeCoins.tr(),
                          style: context.bodyMedium
                              .size(12)
                              .bold
                              .colorExt(const Color(0xFFFFF06C))
                              .copyWith(fontFamily: 'AppFont'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 9.h, 12.w, 10.h),
            child: BlocBuilder<SendInviteBloc, SendInviteState>(
              bloc: di<SendInviteBloc>(),
              buildWhen: (prev, curr) =>
              prev.explainInviteRequest != curr.explainInviteRequest ||
                  prev.explainInviteSuccess != curr.explainInviteSuccess,
              builder: (context, state) {
                return HandlingDataWidget(
                  reqState: state.explainInviteRequest,
                  title: '',
                  subTitle: '',
                  child: TextWidget(
                    state.explainInviteSuccess.toString(),
                    isTranslate: false,
                    textAlign: TextAlign.start,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: context.bodyMedium
                        .size(10.5)
                        .w400
                        .colorExt(const Color(0xFF5F5552))
                        .copyWith(height: 1.28, fontFamily: 'AppFont'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
