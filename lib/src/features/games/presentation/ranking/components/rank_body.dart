part of '../rank_screen.dart';

class RankBody extends StatefulWidget {
  final TabController controller;
  final TabController rankController;
  final RankingEntity? usersRankHour;
  final RequestState reqStateHour;
  final RankingEntity? usersRankDay;
  final RequestState reqStateDay;
  final RankingEntity? usersRankWeak;
  final RequestState reqStateWeak;
  final RankingEntity? usersRankMonth;
  final RequestState reqStateMonth;
  final VoidCallback? onTapHour;
  final VoidCallback? onTapDay;
  final VoidCallback? onTapWeek;
  final VoidCallback? onTapMonthly;
  final int index;
  final String imageRank;
  final Color color;
  final bool isPhoto;

  const RankBody({
    super.key,
    required this.controller,
    required this.rankController,
    required this.usersRankHour,
    required this.reqStateHour,
    required this.usersRankDay,
    required this.reqStateDay,
    required this.usersRankWeak,
    required this.reqStateWeak,
    required this.usersRankMonth,
    required this.reqStateMonth,
    required this.index,
    required this.imageRank,
    required this.color,
    required this.onTapHour,
    required this.onTapDay,
    required this.onTapWeek,
    required this.onTapMonthly,
    required this.isPhoto,
  });

  @override
  State<RankBody> createState() => _RankBodyState();
}

class _RankBodyState extends State<RankBody>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        15.hBox,
        InnerTabBar(
          tabController: widget.controller,
          color: widget.color,
          index: widget.index,
        ),
        7.5.hBox,
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification is OverscrollNotification) {
                if ((notification.dragDetails?.delta.dx ?? 0) < 0 &&
                    widget.rankController.index !=
                        widget.rankController.length - 1 &&
                    widget.controller.index == widget.controller.length - 1) {
                  widget.rankController.animateTo(widget.index + 1,
                      curve: Curves.decelerate,
                      duration: const Duration(milliseconds: 200));
                }
                if ((notification.dragDetails?.delta.dx ?? 0) > 0 &&
                    widget.rankController.index != 0 &&
                    widget.controller.index == 0) {
                  widget.rankController.animateTo(widget.index - 1);
                }
              }
              return true;
            },
            child: TabBarView(
              controller: widget.controller,
              children: [
                HandlingDataWidget(
                  reqState: widget.reqStateHour,
                  title: StringManager.noUsersHour.tr(),
                  subTitle: StringManager.noUsersHourMsg.tr(),
                  onTap: () {},
                  child: Stack(
                    children: [
                      RefreshIndicatorWidget(
                        onRefresh: () async {
                          widget.onTapHour!();
                        },
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: ValueListenableBuilder<int>(
                                valueListenable:
                                    RankScreenState.innerTabNotifier,
                                builder: (context, innerIndex, _) {
                                  return RepaintBoundary(
                                      child: TopThreeWidget(
                                    usersEntity:
                                        widget.usersRankHour?.usersEntity ?? [],
                                    imageRank: widget.imageRank,
                                    isRoomRank: widget.index == 0,
                                    isCharm: widget.index == 2,
                                    isCp: widget.index == 3,
                                    isWealth: widget.index == 1,
                                    isPhoto: innerIndex != 0,
                                  ));
                                },
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: RankContainerWidget(
                                usersRank: widget.usersRankHour,
                                bgColor: widget.color,
                                isWealth: widget.index == 1,
                                isRankRoom: widget.index == 0,
                                isCharm: widget.index == 2,
                                isCp: widget.index == 3,
                                isSender: widget.index == 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                HandlingDataWidget(
                  reqState: widget.reqStateDay,
                  title: StringManager.noUsersToday.tr(),
                  subTitle: StringManager.noUsersTodayMsg.tr(),
                  onTap: () {},
                  child: RefreshIndicatorWidget(
                    onRefresh: () async {
                      widget.onTapDay!();
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: ValueListenableBuilder<int>(
                            valueListenable: RankScreenState.innerTabNotifier,
                            builder: (context, innerIndex, _) {
                              return RepaintBoundary(
                                  child: TopThreeWidget(
                                usersEntity:
                                    widget.usersRankDay?.usersEntity ?? [],
                                imageRank: widget.imageRank,
                                isRoomRank: widget.index == 0,
                                isCharm: widget.index == 2,
                                isCp: widget.index == 3,
                                isWealth: widget.index == 1,
                                isPhoto:
                                    innerIndex != 1, // ✅ dynamic & performant
                              ));
                            },
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: RankContainerWidget(
                            usersRank: widget.usersRankDay,
                            bgColor: widget.color,
                            isWealth: widget.index == 1,
                            isRankRoom: widget.index == 0,
                            isCharm: widget.index == 2,
                            isCp: widget.index == 3,
                            isSender: widget.index == 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                HandlingDataWidget(
                  reqState: widget.reqStateWeak,
                  title: StringManager.noUsersWeekly.tr(),
                  subTitle: StringManager.noUsersWeeklyMsg.tr(),
                  onTap: () {},
                  child: Stack(
                    children: [
                      RefreshIndicatorWidget(
                        onRefresh: () async {
                          widget.onTapWeek!();
                        },
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: ValueListenableBuilder<int>(
                                valueListenable:
                                    RankScreenState.innerTabNotifier,
                                builder: (context, innerIndex, _) {
                                  return TopThreeWidget(
                                    usersEntity:
                                        widget.usersRankWeak?.usersEntity ?? [],
                                    imageRank: widget.imageRank,
                                    isRoomRank: widget.index == 0,
                                    isCharm: widget.index == 2,
                                    isCp: widget.index == 3,
                                    isWealth: widget.index == 1,
                                    isPhoto: innerIndex !=
                                        2, // ✅ dynamic & performant
                                  );
                                },
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: RankContainerWidget(
                                usersRank: widget.usersRankWeak,
                                bgColor: widget.color,
                                isWealth: widget.index == 1,
                                isRankRoom: widget.index == 0,
                                isCharm: widget.index == 2,
                                isCp: widget.index == 3,
                                isSender: widget.index == 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                HandlingDataWidget(
                  reqState: widget.reqStateMonth,
                  title: StringManager.noUsersMonthly.tr(),
                  subTitle: StringManager.noUsersMonthlyMsg.tr(),
                  onTap: () {},
                  child: Stack(
                    children: [
                      RefreshIndicatorWidget(
                        onRefresh: () async {
                          widget.onTapMonthly!();
                        },
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: ValueListenableBuilder<int>(
                                valueListenable:
                                    RankScreenState.innerTabNotifier,
                                builder: (context, innerIndex, _) {
                                  return TopThreeWidget(
                                    usersEntity:
                                        widget.usersRankMonth?.usersEntity ??
                                            [],
                                    imageRank: widget.imageRank,
                                    isRoomRank: widget.index == 0,
                                    isCharm: widget.index == 2,
                                    isCp: widget.index == 3,
                                    isWealth: widget.index == 1,
                                    isPhoto: innerIndex != 3,
                                  );
                                },
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: RankContainerWidget(
                                usersRank: widget.usersRankMonth,
                                bgColor: widget.color,
                                isWealth: widget.index == 1,
                                isRankRoom: widget.index == 0,
                                isCharm: widget.index == 2,
                                isCp: widget.index == 3,
                                isSender: widget.index == 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
