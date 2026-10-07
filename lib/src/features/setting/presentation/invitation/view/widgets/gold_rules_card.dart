import 'package:general/src/features/setting/presentation/invitation/bloc/invite_bloc.dart';

import '../../../../../../core/index.dart';

class GoldRulesCard extends StatelessWidget {
  const GoldRulesCard({super.key});

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
            color: const Color(0xFFB35A20).withValues(alpha: 0.10),
            blurRadius: 15.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFFFF684F), Color(0xFFFFA63E)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(21.r)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    shape: BoxShape.circle,
                    border:
                    Border.all(color: Colors.white.withValues(alpha: 0.45)),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 20.h,
                  ),
                ),
                10.wBox,
                Expanded(
                  child: TextWidget(
                    StringManager.invitationRules.tr(),
                    style: context.bodyMedium
                        .size(15)
                        .bold
                        .colorExt(ColorManager.white),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 17.h),
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
                  titleStyle:
                  context.bodyLarge.w600.colorExt(ColorManager.black),
                  subTitleStyle: context.bodyMedium.copyWith(
                    color: ColorManager.black,
                    height: 1.35,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8EF),
                      borderRadius: BorderRadius.circular(15.r),
                      border: Border.all(color: const Color(0xFFFFDFC0)),
                    ),
                    child: TextWidget(
                      state.explainInviteSuccess.toString(),
                      isTranslate: false,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.fade,
                      style: context.bodyMedium
                          .size(13)
                          .w400
                          .colorExt(const Color(0xFF665A56))
                          .copyWith(height: 1.45),
                    ),
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
