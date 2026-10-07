part of 'package:general/src/features/room/presentation/component/room_header/rank_room/view/rank_room_page.dart';

class _UsersBody extends StatelessWidget {
  final TabController dataController;
  final EnterRoomModel roomModel;
  final RankingEntity? dayUsersRank;
  final RequestState dayState;
  final RankingEntity? weekUsersRank;
  final RequestState weekState;
  final RankingEntity? monthUsersRank;
  final RequestState monthState;
  final TabController outerTabController;

  const _UsersBody({
    required this.roomModel,
    required this.dataController,
    required this.outerTabController,
    required this.dayUsersRank,
    required this.dayState,
    required this.weekUsersRank,
    required this.weekState,
    required this.monthUsersRank,
    required this.monthState,
  });

  void _onTap(int periodIndex) {
    final isCoinsTab = outerTabController.index == 0;
    final events = [
      [
        GetCoinsTopDayEvent(roomId: '${roomModel.id}'),
        GetCoinsTopWeeklyEvent(roomId: '${roomModel.id}'),
        GetCoinsTopMonthlyEvent(roomId: '${roomModel.id}')
      ],
      [
        GetDiamondsTopDayEvent(roomId: '${roomModel.id}'),
        GetDiamondsTopWeeklyEvent(roomId: '${roomModel.id}'),
        GetDiamondsTopMonthlyEvent(roomId: '${roomModel.id}')
      ]
    ];

    di<RankingRoomBloc>().add(events[isCoinsTab ? 0 : 1][periodIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is OverscrollNotification) {
            if ((notification.dragDetails?.delta.dx ?? 0) < 0 &&
                outerTabController.index != outerTabController.length - 1 &&
                dataController.index == dataController.length - 1) {
              outerTabController.animateTo(1);
            }
            if ((notification.dragDetails?.delta.dx ?? 0) > 0 &&
                outerTabController.index != 0 &&
                dataController.index == 0) {
              outerTabController.animateTo(0);
            }
          }
          return true;
        },
        child: TabBarView(
          controller: dataController,
          children: [
            _RankingTabBody(
              state: dayState,
              index: outerTabController.index,
              usersRank: dayUsersRank,
              title: StringManager.noUsersToday.tr(),
              subTitle: StringManager.noUsersTodayMsg.tr(),
              onTap: () => _onTap(0),
            ),
            _RankingTabBody(
              state: weekState,
              usersRank: weekUsersRank,
              index: outerTabController.index,
              title: StringManager.noUsersWeekly.tr(),
              subTitle: StringManager.noUsersWeeklyMsg.tr(),
              onTap: () => _onTap(1),
            ),
            _RankingTabBody(
              state: monthState,
              usersRank: monthUsersRank,
              index: outerTabController.index,
              title: StringManager.noUsersMonthly.tr(),
              subTitle: StringManager.noUsersMonthlyMsg.tr(),
              onTap: () => _onTap(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankingTabBody extends StatelessWidget {
  final RequestState state;
  final RankingEntity? usersRank;
  final String title;
  final String subTitle;
  final int index;
  final Function() onTap;

  const _RankingTabBody({
    required this.state,
    required this.usersRank,
    required this.title,
    required this.subTitle,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicatorWidget(
      onRefresh: () async => onTap.call(),
      child: HandlingDataWidget(
        reqState: state,
        title: title,
        subTitle: subTitle,
        onTap: onTap,
        child: SizedBox(
          width: ScreenUtil().screenWidth,
          child: Stack(
            children: [
              CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: TopThreeWidget(
                      usersEntity: usersRank?.usersEntity ?? [],
                      imageRank: AssetsManager.rankBase,
                      isCharm: index == 1,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: RankContainerWidget(
                      usersRank: (usersRank?.otherUsersEntity ?? []),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: 55.hBox,
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _UserProfileBody(
                  exp: usersRank?.userEntity.exp ?? "0",
                  index: index,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
