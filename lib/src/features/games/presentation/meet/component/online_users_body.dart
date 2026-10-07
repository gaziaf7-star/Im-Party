import 'package:general/src/features/games/presentation/meet/bloc/online_users/online_users_bloc.dart';

import '../../../../../core/index.dart';
import '../widgets/profile_card_item.dart';

class OnlineUsersBody extends StatelessWidget {
  const OnlineUsersBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnlineUsersBloc, OnlineUsersStates>(
      bloc: di<OnlineUsersBloc>(),
      buildWhen: (prev, curr) => prev.reqState != curr.reqState || prev.users != curr.users,
      builder: (context, state) {
        return SizedBox(
          height: state.reqState == RequestState.empty ? null : 200.h,
          child: HandlingDataWidget(
            reqState: state.reqState,
            title: StringManager.noUsers.tr(),
            subTitle: StringManager.noUsersMsg.tr(),
            onTap: () {
              di<OnlineUsersBloc>()
                  .add(const GetUsersOnlineEvent(isFirstLoading: true));
            },
            child: ListView.separated(
              controller: state.scrollController,
              itemCount: state.users.length,
              scrollDirection: Axis.horizontal,
              padding: context.paddingSymmetric(horizontal: 10),
              itemBuilder: (context, index) {
                return ProfileCardItem(
                  data: state.users[index],
                  index: index,
                );
              },
              separatorBuilder: (context, index) {
                return 10.wBox;
              },
            ),
          ),
        );
      },
    );
  }
}
