import 'package:general/reels_viewer/reels_viewer.dart';
import 'package:general/reels_viewer/src/share/bloc/share_reel_bloc.dart';
import 'package:general/reels_viewer/src/share/bloc/share_reel_event.dart';
import 'package:general/reels_viewer/src/share/bloc/share_reel_state.dart';
import 'package:general/src/features/chats/presentation/chats/bloc/manager_get_users_chat/get_users_chat_bloc.dart';
import 'package:general/src/features/messages/presentation/messages/blocs/send_message_all/send_message_all_bloc.dart';

import '../../../src/core/widgets/user_info_row.dart';
import '../../../src/features/agency/presentation/charge_agency/view/component/host_withdrawel_screen/bloc/get_setting_manager/get_setting_bloc.dart';
import '../../../src/features/auth/domain/entities/user_entity.dart';
import '../../../src/features/home/presentation/search_screen/bloc/search_manager/search_bloc.dart';
import '../../../src/features/home/presentation/search_screen/bloc/search_manager/search_events.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_states.dart';
part 'components/friends_card.dart';
part 'components/select_all_friends.dart';
part 'components/friends_search_bar.dart';

class ShareReelInternalScreen extends StatefulWidget {
  const ShareReelInternalScreen({super.key, required this.reelEntity});
  final ReelsEntity? reelEntity;

  @override
  State<ShareReelInternalScreen> createState() =>
      _ShareReelInternalScreenState();
}

class _ShareReelInternalScreenState extends State<ShareReelInternalScreen> {
  @override
  void initState() {
    di<GetSettingBloc>().add(const GetSettingsEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShareReelBloc, ShareReelState>(
      bloc: di<ShareReelBloc>(),
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
                  di<ShareReelBloc>().add(
                    InitializeShareReel(
                      seckretKey: state.settingModel?.sharedKey ?? "-",
                    ),
                  );
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
                        message: state.errorMessage ?? "-",
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
                            _FriendsSearchBar(
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
                                child: _FriendsCard(
                                  users: state.data?.users ?? [],
                                  reel: widget.reelEntity!,
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
            color: ColorManager.surfaceCardColor,
            child: _SelectAllFriends(
              reel: widget.reelEntity!,
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
