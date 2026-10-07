import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/get_user_support/get_user_support_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/get_user_support/get_user_support_state.dart';

import '../../../../core/index.dart';
import 'widget/support_widgets/support_container_widget.dart';
import 'widget/support_widgets/top_three_widget.dart';

class SupportScreen extends StatelessWidget {
  final SupportScreenParam param;
  const SupportScreen({super.key, required this.param});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetSupporterBloc, GetUserSupporterState>(
      bloc: param.getSupporterBloc,
      buildWhen: (prev, curr) =>
          prev.requestState != curr.requestState ||
          prev.topSupport != curr.topSupport ||
          prev.requestOtherUsersState != curr.requestOtherUsersState,
      builder: (BuildContext context, GetUserSupporterState state) {
        return Scaffold(
          appBar: AppBarWidget(
            backgroundColor: ColorManager.scaffoldBg,
            title:
                "${StringManager.support.tr()} (${((state.topSupport?.topUser.length ?? 0) + (state.topSupport?.otherUsers.length ?? 0)).toString()})",
            titleStyle:
                context.bodyLarge.bold.colorExt(ColorManager.appBarTitlegrey),
          ),
          backgroundColor: ColorManager.scaffoldBg,
          body: HandlingDataWidget(
            reqState: state.requestState,
            title: StringManager.titleEmptySupport.tr(),
            subTitle: StringManager.subTitleEmptySupport.tr(),
            child: Column(
              children: [
                Padding(
                  padding: context.paddingOnly(start: 20, end: 20, top: 15),
                  child: SupportTopThreeWidget(
                    usersEntity: state.topSupport!.topUser,
                  ),
                ),
                10.hBox,
                HandlingDataWidget(
                  reqState: state.requestOtherUsersState,
                  title: '',
                  subTitle: '',
                  child: Expanded(
                    child: Padding(
                      padding: context
                          .paddingSymmetric(horizontal: 10)
                          .copyWith(top: 10),
                      child: SupportContainerWidget(
                        topSupport: state.topSupport,
                        bgColor: const Color(0xffe0d6ff),
                        isSender: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
