import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/home.dart';
import 'package:general/src/features/home/presentation/home/bloc/home_manager/home_bloc.dart';
import 'package:general/src/features/theme2_app/home/presentation/view/components/theme2_room_card.dart';

class Theme2RelatedBody extends StatefulWidget {
  final HomeBloc bloc;
  const Theme2RelatedBody({super.key, required this.bloc});

  @override
  State<Theme2RelatedBody> createState() => _Theme2RelatedBodyState();
}

class _Theme2RelatedBodyState extends State<Theme2RelatedBody>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  late final TabController _subTabController;

  static final _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 10.h,
    crossAxisSpacing: 10.w,
    childAspectRatio: 0.75,
  );

  @override
  void initState() {
    super.initState();
    // 4 tabs: الكل (follow) | انضم (friends) | متابعاتي (follow) | مؤخرا (lastCreate)
    _subTabController = TabController(length: 4, vsync: this);

    // Load follow rooms by default (tab 0 = الكل)
    if (!widget.bloc.state.reqStateFollow.isLoaded) {
      widget.bloc.add(const FetchFollowRoomsEvent());
    }
    widget.bloc.add(const FollowAddListenerEvent());

    _subTabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_subTabController.indexIsChanging) return;

    switch (_subTabController.index) {
      case 0: // الكل - All (follow rooms)
        if (!widget.bloc.state.reqStateFollow.isLoaded) {
          widget.bloc.add(const FetchFollowRoomsEvent());
        }
        break;
      case 1: // انضم - Joined (friends rooms)
        if (!widget.bloc.state.reqStateFriends.isLoaded) {
          widget.bloc.add(const FetchFriendsRoomsEvent());
          widget.bloc.add(const FriendsAddListenerEvent());
        }
        break;
      case 2: // متابعاتي - My Following (follow rooms)
        if (!widget.bloc.state.reqStateFollow.isLoaded) {
          widget.bloc.add(const FetchFollowRoomsEvent());
        }
        break;
      case 3: // مؤخرا - Recently (last created rooms)
        if (!widget.bloc.state.reqStateLastCreate.isLoaded) {
          widget.bloc.add(const FetchLastCreateRoomsEvent());
          widget.bloc.add(const LastCreateLAddListenerEvent());
        }
        break;
    }
  }

  @override
  void dispose() {
    _subTabController.removeListener(_onTabChanged);
    _subTabController.dispose();
    widget.bloc.add(const FriendsRemoveListenerEvent());
    widget.bloc.add(const LastCreateRemoveListenerEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        // ─── Create Room Banner ──────────────────────
        //  _buildCreateRoomBanner(context),

        // Only the TabBar (active-tab styling) rebuilds on tab change, so the
        // 4-child TabBarView below is not rebuilt on tab taps.
        AnimatedBuilder(
          animation: _subTabController,
          builder: (context, _) {
            return TabBar(
              controller: _subTabController,
              isScrollable: true,
              labelPadding: EdgeInsets.symmetric(horizontal: 3.w),
              dividerHeight: 0,
              overlayColor: WidgetStateColor.transparent,
              indicatorSize: TabBarIndicatorSize.label,
              indicator: const BoxDecoration(),
              labelStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: ColorManager.theme2TextPrimary,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: ColorManager.theme2TabInactive,
              ),
              tabs: [
                _buildSubTab(
                    StringManager.theme2All.tr(), _subTabController.index == 0),
                _buildSubTab(StringManager.theme2Joined.tr(),
                    _subTabController.index == 1),
                _buildSubTab(StringManager.theme2MyFollowing.tr(),
                    _subTabController.index == 2),
                _buildSubTab(StringManager.theme2Recently.tr(),
                    _subTabController.index == 3),
              ],
            );
          },
        ),

        8.hBox,

        // ─── Tab Content ─────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [
              // Tab 0: الكل - All (follow rooms)
              _buildRoomGrid(
                roomsSelector: (state) => state.follow,
                reqStateSelector: (state) => state.reqStateFollow,
                onRetry: () => widget.bloc.add(const FetchFollowRoomsEvent()),
                keyPrefix: 'jo_all',
              ),
              // Tab 1: انضم - Joined (friends rooms)
              _buildRoomGrid(
                roomsSelector: (state) => state.friends,
                reqStateSelector: (state) => state.reqStateFriends,
                onRetry: () => widget.bloc.add(const FetchFriendsRoomsEvent()),
                keyPrefix: 'jo_joined',
              ),
              // Tab 2: متابعاتي - My Following (follow rooms)
              _buildRoomGrid(
                roomsSelector: (state) => state.follow,
                reqStateSelector: (state) => state.reqStateFollow,
                onRetry: () => widget.bloc.add(const FetchFollowRoomsEvent()),
                keyPrefix: 'jo_following',
              ),
              // Tab 3: مؤخرا - Recently (last created rooms)
              _buildRoomGrid(
                roomsSelector: (state) => state.lastCreate,
                reqStateSelector: (state) => state.reqStateLastCreate,
                onRetry: () =>
                    widget.bloc.add(const FetchLastCreateRoomsEvent()),
                keyPrefix: 'jo_recent',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomGrid({
    required List<RoomEntity> Function(HomeState) roomsSelector,
    required RequestState Function(HomeState) reqStateSelector,
    required VoidCallback onRetry,
    required String keyPrefix,
  }) {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: widget.bloc,
      buildWhen: (prev, curr) =>
          roomsSelector(prev) != roomsSelector(curr) ||
          reqStateSelector(prev) != reqStateSelector(curr),
      builder: (context, state) {
        final rooms = roomsSelector(state);
        final reqState = reqStateSelector(state);

        if (reqState.isLoading) {
          return const Center(child: LoadingWidget());
        }

        if (rooms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.nights_stay_outlined,
                  color: ColorManager.theme2AccentLight,
                  size: 60.h,
                ),
                16.hBox,
                Text(
                  StringManager.theme2Empty.tr(),
                  style: TextStyle(
                    color: ColorManager.theme2TextSecondary,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicatorWidget(
          onRefresh: () async => onRetry(),
          child: ConstantsManager.isShowGridView
              ? GridView.builder(
                  padding: context.paddingSymmetric(horizontal: 10),
                  cacheExtent: 250,
                  gridDelegate: _gridDelegate,
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    return RepaintBoundary(
                      child: Theme2RoomCard(
                        key: ValueKey('${keyPrefix}_${rooms[index].id}'),
                        roomEntity: rooms[index],
                      ),
                    );
                  },
                )
              : ListView.separated(
                  padding: context.paddingSymmetric(horizontal: 0),
                  itemCount: rooms.length,
                  separatorBuilder: (_, __) => 10.hBox,
                  itemBuilder: (context, index) {
                    return RepaintBoundary(
                      child: GestureDetector(
                        onTap: () {
                          // Video live is removed: live rooms are not
                          // enterable. Ignore the tap.
                          if (rooms[index].streamType == "live") return;
                          if (di<FetchUserDataBloc>()
                              .state
                              .reqState
                              .isLoaded) {
                            di<RoomStateManager>().navigateToRoom(
                              RoomEntryRequest(
                                context: context,
                                roomData: rooms[index],
                                isLive: false,
                              ),
                            );
                          }
                        },
                        child: CardLiveWidget(
                          key: ValueKey('${keyPrefix}_${rooms[index].id}'),
                          roomEntity: rooms[index],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildSubTab(String title, bool isActive) {
    return Container(
      padding: context.paddingSymmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isActive
            ? ColorManager.theme2FilterActive
            : ColorManager.theme2FilterBg,
        borderRadius: 20.radius,
      ),
      child: Text(title),
    );
  }
}
