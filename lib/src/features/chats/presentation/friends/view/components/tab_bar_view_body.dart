part of '../friends_page.dart';

class TabViewBody extends StatefulWidget {
  final List<UserEntity> entity;
  final RelationType fType_;

  final RequestState reqState;
  final TextEditingController controller;

  // When set, overrides the relation-based scroll controller (used so the
  // friends-search results paginate through the SearchBloc instead of the
  // contacts list cursor).
  final ScrollController? scrollControllerOverride;

  const TabViewBody({
    super.key,
    required this.entity,
    required this.fType_,
    required this.reqState,
    required this.controller,
    this.scrollControllerOverride,
  });

  @override
  State<TabViewBody> createState() => _TabViewBodyState();
}

class _TabViewBodyState extends State<TabViewBody> {
  final _bloc = di<GetFollowerOrFollowingBloc>();

  @override
  void initState() {
    super.initState();
    // Contacts-list pagination only when not driven by an external (search)
    // controller — search pagination is owned by the SearchBloc listener.
    if (widget.scrollControllerOverride == null) {
      _bloc.add(AddListenerFriendsEvent());
    }
  }

  @override
  void dispose() {
    if (widget.scrollControllerOverride == null) {
      _bloc.add(RemoveListenerFriendsEvent());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return RefreshIndicatorWidget(
      onRefresh: () async {
        di<GetFollowerOrFollowingBloc>()
            .add(const GetFriendsEvent(loading: false));
      },
      child: ListView.builder(
        itemCount: widget.entity.length,
        padding: context.paddingSymmetric(vertical: 15, horizontal: 0),
        physics: const AlwaysScrollableScrollPhysics(),
        controller: widget.scrollControllerOverride ??
            (widget.fType_ == RelationType.following
                ? _bloc.state.scrollControllerFollowing
                : widget.fType_ == RelationType.followers
                    ? _bloc.state.scrollControllerFollowers
                    : widget.fType_ == RelationType.friends
                        ? _bloc.state.scrollControllerFriends
                        : _bloc.state.scrollControllerVisitor),
       
        itemBuilder: (context, index) {

          return FFFVUserInfoRow(
            padding: EdgeInsets.symmetric(vertical: 7.5.h, horizontal: 0),
            user: widget.entity[index],
            margin: EdgeInsets.symmetric(horizontal: 10.w),
            endIcon: ButtonWidget(
              onPressed: () {
                di<FetchUsersChatBloc>().add(
                  UpdateTotalMessages(
                    userId: widget.entity[index].uuid
                        .toString(),
                    isIncreased: false,
                  ),
                );
                Navigator.pushNamed(
                  context,
                  Routes.messages,
                  arguments: MessagesParameter(
                    hasColorName: widget.entity[index].hasColorName??false,
                    name:widget.entity[index].name??'',
                    image: widget.entity[index].profile?.image??'',
                    userId:
                    '${widget.entity[index].id}',
                  ),
                );
              },
              radius: 30.r,
              width: 43.w,
              paddingButton: context.paddingZero(),
              height: 22.h,
              titleColor: ColorManager.whiteColor,
              endGradient: AlignmentDirectional.centerEnd,
              beginGradient: AlignmentDirectional.centerStart,
              backgroundColors: [
                ColorManager.lightGreen.withValues(alpha: (0.9 )),
                ColorManager.lightGreen,
                ColorManager.primary,
              ],
              title: Image.asset(
                AssetsManager.chatFriends,
                color: ColorManager.white,
                height: 18.h,
                width: 20.w,
              ),
              fontSize: 14.sp,

              isFittedBox: false,
              fontWeight: FontWeight.w500,
            ),
          );
        },
      ),
    );
  }
}
