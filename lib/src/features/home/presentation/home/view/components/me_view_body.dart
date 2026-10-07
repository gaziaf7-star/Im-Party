part of 'package:general/src/features/home/presentation/home/view/home_page.dart';

class _MeViewBody extends StatefulWidget {
  const _MeViewBody({required this.bloc, required this.controller});
  final TabController controller;
  final HomeBloc bloc;

  @override
  State<_MeViewBody> createState() => _MeViewBodyState();
}

class _MeViewBodyState extends State<_MeViewBody>
    with TickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    _controller = TabController(length: 3, vsync: this, initialIndex: 1);
    if (!widget.bloc.state.reqStateFollow.isLoaded) {
      widget.bloc.add(const FetchFollowRoomsEvent());
    }
    _controller.addListener(_listener);
    widget.bloc.add(const LastCreateLAddListenerEvent());
    widget.bloc.add(const FriendsAddListenerEvent());
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    _controller.dispose();
    widget.bloc.add(const FriendsRemoveListenerEvent());
    widget.bloc.add(const LastCreateRemoveListenerEvent());
    super.dispose();
  }

  void _listener() {
    if (_controller.index == 0) {
      if (!widget.bloc.state.reqStateFriends.isLoaded) {
        widget.bloc.add(const FetchFriendsRoomsEvent());
      }
    }
    if (_controller.index == 1) {
      if (!widget.bloc.state.reqStateFollow.isLoaded) {
        widget.bloc.add(const FetchFollowRoomsEvent());
      }
    }
    if (_controller.index == 2) {
      if (!widget.bloc.state.reqStateLastCreate.isLoaded) {
        widget.bloc.add(const FetchLastCreateRoomsEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is OverscrollNotification) {
          if ((notification.dragDetails?.delta.dx ?? 0) < 0 &&
              _controller.index == _controller.length - 1) {
            widget.controller.animateTo(1);
          }
        }
        return true;
      },
      child: DefaultTabController(
        length: 3,
        initialIndex: 1,
        child: RefreshIndicatorWidget(
          onRefresh: () async {
            di<FetchMyRoomDataBloc>().add(const FetchMyRoomDataEvent());
            if (_controller.index == 0) {
              widget.bloc.add(const FetchFriendsRoomsEvent());
            }
            if (_controller.index == 1) {
              widget.bloc.add(const FetchFollowRoomsEvent());
            }
            if (_controller.index == 2) {
              widget.bloc.add(const FetchLastCreateRoomsEvent());
            }
          },
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const MyRoomCard(),
                      _MeTabBarBody(controller: _controller),
                      15.hBox,
                    ],
                  ),
                ),
              ];
            },
            // Performance fix: wrap TabBarView with BlocBuilder to listen
            // to state changes instead of reading widget.bloc.state directly.
            body: BlocBuilder<HomeBloc, HomeState>(
              bloc: widget.bloc,
              buildWhen: (prev, curr) =>
              prev.friends != curr.friends ||
                  prev.reqStateFriends != curr.reqStateFriends ||
                  prev.follow != curr.follow ||
                  prev.reqStateFollow != curr.reqStateFollow ||
                  prev.lastCreate != curr.lastCreate ||
                  prev.reqStateLastCreate != curr.reqStateLastCreate,
              builder: (context, state) {
                return TabBarView(
                  controller: _controller,
                  children: [
                    _rooms(
                      reqState: state.reqStateFriends,
                      list: state.friends,
                      scrollController: state.friendsScrollCtrl,
                      onFetch: () =>
                          widget.bloc.add(const FetchFriendsRoomsEvent()),
                    ),
                    _rooms(
                      reqState: state.reqStateFollow,
                      list: state.follow,
                      scrollController: state.followScrollCtrl,
                      onFetch: () =>
                          widget.bloc.add(const FetchFollowRoomsEvent()),
                    ),
                    _rooms(
                      reqState: state.reqStateLastCreate,
                      list: state.lastCreate,
                      scrollController: state.lastCreateScrollCtrl,
                      onFetch: () =>
                          widget.bloc.add(const FetchLastCreateRoomsEvent()),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Performance fix: moved BlocBuilder outside ListView.separated to avoid
// creating N BlocBuilder listeners (one per item). Now only 1 listener wraps all items.
Widget _rooms({
  required RequestState reqState,
  required List<RoomEntity> list,
  required ScrollController scrollController,
  required VoidCallback onFetch,
}) {
  return HandlingDataWidget(
    reqState: reqState,
    title: StringManager.noRooms.tr(),
    subTitle: StringManager.noRoomsMsg.tr(),
    onTap: onFetch,
    child: BlocBuilder<FetchUserDataBloc, FetchUserDataState>(
      bloc: di<FetchUserDataBloc>(),
      buildWhen: (prev, curr) => prev.reqState != curr.reqState,
      builder: (context, state) {
        final isLoaded = state.reqState == RequestState.loaded;
        return ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.only(bottom: 70),
          itemCount: list.length,
          separatorBuilder: (context, index) => 10.hBox,
          itemBuilder: (context, index) {
            return RepaintBoundary(
              child: MultiTapCard(
                onTap: () {
                  if (isLoaded) {
                    di<RoomStateManager>().navigateToRoom(
                      RoomEntryRequest(
                        context: context,
                        roomData: list[index],
                        isLive: list[index].streamType == "live",
                      ),
                    );
                  }
                },
                // Text forced black + a real white card (border + shadow),
                // on request -- was fully transparent with panel-driven text
                // colors that could go invisible under a custom body theme.
                child: CardLiveWidget(
                  roomEntity: list[index],
                  forceBlackText: true,
                ),
              ),
            );
          },
        );
      },
    ),
  );
}

class _MeTabBarBody extends StatelessWidget {
  const _MeTabBarBody({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Padding(
        padding: context.paddingSymmetric(horizontal: 15),
        child: TabBar(
          controller: controller,
          dividerHeight: 0.0,
          physics: const AlwaysScrollableScrollPhysics(),
          indicator: MDIndicator(
            // Fixed brand gradient (was the panel-driven lightBlack), on
            // request -- MDIndicator already supports a gradient fill.
            indicatorGradient: ColorManager.brandGradient,
            indicatorWidth: 17.w,
            indicatorHeight: 4.h,
            radius: 20,
          ),
          // horizontal removed: with indicatorSize.tab + zero labelPadding, a
          // short tab narrower than the inset throws "indicatorPadding insets
          // should be less than Tab Size". The MDIndicator is fixed-width and
          // centered, so vertical-only is visually identical and crash-safe.
          indicatorPadding: EdgeInsets.symmetric(vertical: -2.5.h),
          // Fixed black text (was the panel-driven textPrimary), on request.
          unselectedLabelStyle: context.bodyLarge.w500
              .colorExt(Colors.black.withValues(alpha: 0.6)),
          labelStyle: context.bodyLarge.bold.colorExt(Colors.black),
          labelPadding: context.paddingZero(),
          tabs: [
            Text(StringManager.friends.tr()),
            Text(StringManager.following.tr()),
            Text(StringManager.createRoom.tr()),
          ],
        ),
      ),
    );
  }
}