import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/data/model/enter_room_model.dart';
import 'package:general/src/features/room/presentation/share/bloc/share_room_bloc.dart';
import 'package:general/src/features/room/presentation/share/bloc/share_room_event.dart';
import 'package:general/src/features/room/presentation/share/bloc/share_room_state.dart';
import 'package:general/src/features/chats/presentation/chats/bloc/manager_get_users_chat/get_users_chat_bloc.dart';
import 'package:general/src/features/messages/presentation/messages/blocs/send_message_all/send_message_all_bloc.dart';
import 'package:general/src/core/widgets/user_info_row.dart';
import 'package:general/src/features/agency/presentation/charge_agency/view/component/host_withdrawel_screen/bloc/get_setting_manager/get_setting_bloc.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_bloc.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_events.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_states.dart';

part 'components/room_friends_card.dart';
part 'components/room_select_all_friends.dart';
part 'components/room_friends_search_bar.dart';

class ShareRoomInternalScreen extends StatefulWidget {
  const ShareRoomInternalScreen({super.key, required this.roomEntity});
  final EnterRoomModel? roomEntity;

  @override
  State<ShareRoomInternalScreen> createState() =>
      _ShareRoomInternalScreenState();
}

class _ShareRoomInternalScreenState extends State<ShareRoomInternalScreen> {
  @override
  void initState() {
    di<GetSettingBloc>().add(const GetSettingsEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShareRoomBloc, ShareRoomState>(
      bloc: di<ShareRoomBloc>(),
      buildWhen: (prev, curr) => prev.searchController != curr.searchController || prev.secretKey != curr.secretKey || prev.idsAndBool != curr.idsAndBool || prev.selectAll != curr.selectAll || prev.selectedIds != curr.selectedIds,
      builder: (context, shareState) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBarWidget(
            title: StringManager.friends.tr(),
          ),
          body: SafeArea(
            child: BlocListener<GetSettingBloc, GetSettingState>(
              bloc: di<GetSettingBloc>(),
              listener: (context, state) {
                if (state.state.isLoaded) {
                  di<ShareRoomBloc>().add(InitializeShareRoom(
                      secretKey: state.settingModel?.sharedKey ?? "-"));
                }
              },
              child: BlocListener<SendMessageAllBloc, SendMessageAllState>(
                  bloc: di<SendMessageAllBloc>(),
                  listener: (context, state) {
                    if (state.reqState.isLoaded) {
                      di<FetchUsersChatBloc>().add(const GetChatUsersEvent(
                        userId: null,
                      ));
                      Methods.showToast(
                        context,
                        message: StringManager.success.tr(),
                      );
                      Navigator.pop(context);
                    } else if (state.reqState.isError) {
                      Methods.showToast(
                        context,
                        isError: true,
                        message: state.errorMessage!,
                      );
                    } else {
                      Methods.showToast(context, isLoading: true);
                    }
                  },
                  child: BlocBuilder<SearchBloc, SearchStates>(
                      bloc: di<SearchBloc>(),
                      buildWhen: (prev, curr) => prev.reqState != curr.reqState || prev.data != curr.data,
                      builder: (context, state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _RoomFriendsSearchBar(
                              searchController: shareState.searchController,
                            ),
                            10.hBox,
                            Padding(
                              padding: context.paddingOnly(start: 20),
                              child: Text(
                                StringManager.friends.tr(),
                                style: context.bodyMedium
                                    .colorExt(ColorManager.textPrimary)
                                    .size(15)
                                    .bold,
                              ),
                            ),
                            HandlingDataWidget(
                              reqState: state.reqState,
                              title: StringManager.noFriends.tr(),
                              subTitle: StringManager.subtitleFriend.tr(),
                              onTap: () {
                                di<SearchBloc>().add(
                                  const SearchEvent(
                                    keyWord: ' ',
                                    isFriend: true,
                                    page: '1',
                                  ),
                                );
                              },
                              child: Expanded(
                                child: _RoomFriendsCard(
                                  users: state.data?.users ?? [],
                                  room: widget.roomEntity!,
                                  idsAndBool: shareState.idsAndBool,
                                  selectAll: shareState.selectAll,
                                  selectedIds: shareState.selectedIds,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                ),
              ),
            ),
          bottomNavigationBar: Container(
            color: ColorManager.white,
            child: _RoomSelectAllFriends(
              room: widget.roomEntity!,
              idsAndBool: shareState.idsAndBool,
              selectAll: shareState.selectAll,
              selectedIds: shareState.selectedIds,
            ),
          ),
        );
      },
    );
  }
}
