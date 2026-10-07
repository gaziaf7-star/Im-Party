import 'package:general/src/features/chats/chats.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_bloc.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_event.dart';
import 'package:general/src/core/widgets/level_container.dart';
import 'package:general/src/core/widgets/vip_container.dart';
import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_bloc.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_event.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_state.dart';

part '../components/tab_bar_view_body.dart';
part '../components/tab_bar_widget.dart';
part '../components/fffv_user_info_row.dart';

class FFFScreen extends StatefulWidget {
  final int index;

  const FFFScreen({super.key, required this.index});

  @override
  State<FFFScreen> createState() => _FFFScreenState();
}

class _FFFScreenState extends State<FFFScreen> with TickerProviderStateMixin {
  final GetFollowerOrFollowingBloc _bloc = di<GetFollowerOrFollowingBloc>();

  bool _isInitial = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isInitial) {
        _isInitial = false;

        _bloc
            .add(ChangeAppBarTitleEvent(title: _getTitleByIndex(widget.index)));
        _handleEventsByIndex(widget.index);
      }
    });
  }

  String _getTitleByIndex(int index) {
    switch (index) {
      case 0:
        return StringManager.following.tr();
      case 1:
        return StringManager.followers.tr();
      case 2:
        return StringManager.friends.tr();
      case 3:
        return StringManager.visitors.tr();
      case 4:
        return StringManager.friendRequest.tr();
      default:
        return '';
    }
  }

  void _handleEventsByIndex(int index) {
    switch (index) {
      case 0:
        _bloc.add(GetFollowersThemEvent(
            loading: _bloc.state.getFollowingRequest != RequestState.loaded));
        break;
      case 1:
        _bloc.add(GetFollowersEvent(
            loading: _bloc.state.getFollowersRequest != RequestState.loaded));
        break;
      case 2:
        _bloc.add(GetFriendsEvent(
            loading: _bloc.state.getFriendsRequest != RequestState.loaded));
        break;
      case 3:
        _bloc.add(GetVisitorsEvent(
            loading: _bloc.state.getVisitorsRequest != RequestState.loaded));
        break;
      case 4:
        _bloc.add(GetFriendsRequestEvent(
            loading: _bloc.state.friendsRequestState != RequestState.loaded));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetFollowerOrFollowingBloc, GetFollowerOrFollowingState>(
      bloc: _bloc,
      buildWhen: (prev, curr) =>
      prev.appBarTitle != curr.appBarTitle ||
          prev.getFollowingRequest != curr.getFollowingRequest ||
          prev.getFollowersRequest != curr.getFollowersRequest ||
          prev.getFriendsRequest != curr.getFriendsRequest ||
          prev.getVisitorsRequest != curr.getVisitorsRequest ||
          prev.friendsRequestState != curr.friendsRequestState ||
          prev.getFollowers != curr.getFollowers ||
          prev.getFollowing != curr.getFollowing ||
          prev.getFriends != curr.getFriends ||
          prev.getVisitors != curr.getVisitors ||
          prev.dataFriendsRequest != curr.dataFriendsRequest ||
          prev.isPaginatingFollowing != curr.isPaginatingFollowing ||
          prev.isPaginatingFollowers != curr.isPaginatingFollowers ||
          prev.isPaginatingFriends != curr.isPaginatingFriends ||
          prev.isPaginatingVisitors != curr.isPaginatingVisitors ||
          prev.isPaginatingFriendsRequest != curr.isPaginatingFriendsRequest,
      builder: (context, state) {
        return Scaffold(
          // Fixed brand-gradient app bar (was plain white/black), on
          // request, for this Visitors/Following/Followers/Friends/
          // Friend-Request page reached from the Chats page.
          backgroundColor: ColorManager.white,
          // Reverted to the default (no explicit height:) -- an earlier
          // attempt at a "taller" appbar here caused the toolbar to
          // shrink/overlap the status bar on some devices, so this now
          // matches every other AppBarWidget usage in the app again.
          appBar: AppBarWidget(
            title: state.appBarTitle,
            backgroundGradient: ColorManager.brandGradient,
            titleStyle: context.titleLarge.bold
                .size(18)
                .colorExt(ColorManager.onBrandGradient),
            iconColor: ColorManager.onBrandGradient,
          ),
          body: Column(
            children: [
              Expanded(
                child: (() {
                  switch (widget.index) {
                    case 0:
                      return HandlingDataWidget(
                        title: StringManager.titleFollowing.tr(),
                        subTitle: StringManager.subtitleFollowers.tr(),
                        reqState: state.getFollowingRequest,
                        // Fixed black "no data" text + gradient refresh
                        // button, on request.
                        titleStyle:
                        context.bodyLarge.w600.colorExt(ColorManager.black),
                        subTitleStyle: context.bodyMedium
                            .colorExt(ColorManager.black.withValues(alpha: 0.6)),
                        buttonBackgroundColors: ColorManager.brandGradientColors,
                        buttonBorderColor: ColorManager.transparent,
                        onTap: () {
                          _bloc.add(const GetFollowersThemEvent(loading: true));
                        },
                        child: TabViewBody(
                          entity: state.getFollowing,
                          fType_: RelationType.following,
                          reqState: state.getFollowingRequest,
                          localList: state.localSearch,
                          isPaginating: state.isPaginatingFollowing,
                        ),
                      );
                    case 1:
                      return HandlingDataWidget(
                        title: StringManager.titleFollowers.tr(),
                        subTitle: StringManager.subtitleFollowers.tr(),
                        reqState: state.getFollowersRequest,
                        titleStyle:
                        context.bodyLarge.w600.colorExt(ColorManager.black),
                        subTitleStyle: context.bodyMedium
                            .colorExt(ColorManager.black.withValues(alpha: 0.6)),
                        buttonBackgroundColors: ColorManager.brandGradientColors,
                        buttonBorderColor: ColorManager.transparent,
                        onTap: () {
                          _bloc.add(const GetFollowersEvent(loading: true));
                        },
                        child: TabViewBody(
                          entity: state.getFollowers,
                          fType_: RelationType.followers,
                          reqState: state.getFollowersRequest,
                          localList: state.localSearch,
                          isPaginating: state.isPaginatingFollowers,
                        ),
                      );
                    case 2:
                      return HandlingDataWidget(
                        title: StringManager.titleFriend.tr(),
                        subTitle: StringManager.subtitleFriend.tr(),
                        reqState: state.getFriendsRequest,
                        titleStyle:
                        context.bodyLarge.w600.colorExt(ColorManager.black),
                        subTitleStyle: context.bodyMedium
                            .colorExt(ColorManager.black.withValues(alpha: 0.6)),
                        buttonBackgroundColors: ColorManager.brandGradientColors,
                        buttonBorderColor: ColorManager.transparent,
                        onTap: () {
                          _bloc.add(const GetFriendsEvent(loading: true));
                        },
                        child: TabViewBody(
                          entity: state.getFriends,
                          fType_: RelationType.friends,
                          reqState: state.getFriendsRequest,
                          localList: state.localSearch,
                          isPaginating: state.isPaginatingFriends,
                        ),
                      );
                    case 3:
                      return HandlingDataWidget(
                        title: StringManager.titleVisitors.tr(),
                        subTitle: StringManager.subtitleVisitors.tr(),
                        reqState: state.getVisitorsRequest,
                        titleStyle:
                        context.bodyLarge.w600.colorExt(ColorManager.black),
                        subTitleStyle: context.bodyMedium
                            .colorExt(ColorManager.black.withValues(alpha: 0.6)),
                        buttonBackgroundColors: ColorManager.brandGradientColors,
                        buttonBorderColor: ColorManager.transparent,
                        onTap: () {
                          _bloc.add(const GetVisitorsEvent(loading: true));
                        },
                        child: TabViewBody(
                          entity: state.getVisitors,
                          fType_: RelationType.visitors,
                          reqState: state.getVisitorsRequest,
                          localList: state.localSearch,
                          isPaginating: state.isPaginatingVisitors,
                        ),
                      );
                    case 4:
                      return HandlingDataWidget(
                        title: StringManager.friendRequest.tr(),
                        subTitle: StringManager.subTitleFriendRequest.tr(),
                        reqState: state.friendsRequestState,
                        titleStyle:
                        context.bodyLarge.w600.colorExt(ColorManager.black),
                        subTitleStyle: context.bodyMedium
                            .colorExt(ColorManager.black.withValues(alpha: 0.6)),
                        buttonBackgroundColors: ColorManager.brandGradientColors,
                        buttonBorderColor: ColorManager.transparent,
                        onTap: () {
                          _bloc
                              .add(const GetFriendsRequestEvent(loading: true));
                        },
                        child: TabViewBody(
                          entity: state.dataFriendsRequest,
                          fType_: RelationType.friendsRequest,
                          reqState: state.friendsRequestState,
                          localList: state.localSearch,
                          isPaginating: state.isPaginatingFriendsRequest,
                        ),
                      );
                    default:
                      return const SizedBox();
                  }
                }()),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({
    super.key,
    required this.onSubmit,
    required this.onChanged,
    required this.onPress,
    this.controller,
  });

  final void Function(String)? onSubmit;
  final void Function(String?)? onChanged;
  final VoidCallback onPress;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().screenWidth,
      padding: EdgeInsets.zero,
      margin: context.paddingSymmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: 10.radius,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextInputWidget(
              StringManager.searchById.tr(),
              controller: controller,
              keyboardType: TextInputType.number,
              fillColor: ColorManager.white,
              onChanged: onChanged,
              onSubmitted: onSubmit,
              textColor: ColorManager.secondaryText.withValues(alpha: (0.3)),
              border: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: ColorManager.white,
                  width: 1,
                ),
                borderRadius: 5.radius,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: ColorManager.white,
                  width: 1,
                ),
                borderRadius: 5.radius,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: ColorManager.white,
                  width: 1,
                ),
                borderRadius: 5.radius,
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: ColorManager.redAccount,
                  width: 1,
                ),
                borderRadius: 5.radius,
              ),
              prefixIcon: Image.asset(
                AssetsManager.searchIcon,
                scale: 3,
              ),
              hintStyle: context.bodyMedium
                  .colorExt(ColorManager.textPrimary.withValues(alpha: (0.3))),
              textStyle: context.bodyLarge.colorExt(ColorManager.textPrimary),
              contentPadding: context.paddingOnly(
                top: 0,
                end: 0,
                bottom: 0,
                start: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}