import 'package:general/src/features/games/games.dart';
import 'package:general/src/features/games/presentation/meet/bloc/online_users/online_users_bloc.dart';
import 'package:general/src/features/games/presentation/meet/component/online_users_body.dart';
import 'package:general/src/features/games/presentation/meet/get_users_profile/get_user_profile_bloc.dart';

import 'widgets/meet_item_info_row.dart';

class MeetPage extends StatefulWidget {
  const MeetPage({super.key});

  @override
  State<MeetPage> createState() => _MeetPageState();
}

class _MeetPageState extends State<MeetPage> {
  @override
  void initState() {
    di<OnlineUsersBloc>().add(const AddListenerOnlineUsersEvent());
    di<GetUserProfilesBloc>().add(const AddListenerUsersProfileEvent());

    if (!di<OnlineUsersBloc>().state.reqState.isLoaded) {
      di<OnlineUsersBloc>()
          .add(const GetUsersOnlineEvent(isFirstLoading: true));
    }

    if (!di<GetUserProfilesBloc>().state.reqState.isLoaded) {
      di<GetUserProfilesBloc>()
          .add(const GetUserProfileEvent(isFirstLoading: true));
    }
    super.initState();
  }

  @override
  void dispose() {
    di<OnlineUsersBloc>().add(const RemoveListenerOnlineUsersEvent());
    di<GetUserProfilesBloc>().add(const RemoveListenerUsersProfileEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicatorWidget(
        onRefresh: () async {
          di<OnlineUsersBloc>()
              .add(const GetUsersOnlineEvent(isFirstLoading: false));
          di<GetUserProfilesBloc>()
              .add(const GetUserProfileEvent(isFirstLoading: false));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
                //height: 200.h,
                child: OnlineUsersBody()),
            15.hBox,
            Padding(
              padding: context.paddingSymmetric(horizontal: 10),
              child: TextWidget(
                StringManager.recommended.tr(),
                style: context.bodyMedium.bold.colorExt(ColorManager.textPrimary),
              ),
            ),
            10.hBox,
            Expanded(
              child: BlocBuilder<GetUserProfilesBloc, GetUserProfilesState>(
                bloc: di<GetUserProfilesBloc>(),
                buildWhen: (prev, curr) => prev.reqState != curr.reqState || prev.userProfileModel != curr.userProfileModel,
                builder: (context, state) {
                  return HandlingDataWidget(
                    reqState: state.reqState,
                    title: StringManager.noUsers.tr(),
                    subTitle: StringManager.noUsersMsg.tr(),
                    child: ListView.separated(
                      padding: context.paddingSymmetric(
                          horizontal: 10, vertical: 10),
                      itemCount: state.userProfileModel.length,
                      separatorBuilder: (context, state) {
                        return 10.hBox;
                      },
                      controller: state.scrollController,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Routes.messages,
                              arguments: MessagesParameter(
                                hasColorName: false,
                                name: state.userProfileModel[index].name ?? '',
                                image:
                                    state.userProfileModel[index].image ?? '',
                                userId: '${state.userProfileModel[index].id}',
                                message: StringManager.sayHello.tr(),
                              ),
                            );
                          },
                          child: MeetItemInfoRow(
                            name: state.userProfileModel[index].name,
                            bio: state.userProfileModel[index].bio,
                            image: state.userProfileModel[index].image,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
