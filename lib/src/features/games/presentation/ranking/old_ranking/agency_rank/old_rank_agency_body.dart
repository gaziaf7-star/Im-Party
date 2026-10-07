part of '../old_rank_screen.dart';

class OldRankAgencyBody extends StatefulWidget {
  final TabController controller;
  final TabController rankController;
  final RequestState reqStateHour;
  final RequestState reqStateDay;
  final RequestState reqStateWeak;
  final RequestState reqStateMonth;
  final int index;
  final String imageRank;
  final Color color;
  final List<AgencyRankingEntity>? usersAgencyRankHour;
  final List<AgencyRankingEntity>? usersAgencyRankDay;
  final List<AgencyRankingEntity>? usersAgencyRankWeek;
  final List<AgencyRankingEntity>? usersAgencyRankMonth;
  final VoidCallback? onTapHour;
  final VoidCallback? onTapDay;
  final VoidCallback? onTapWeek;
  final VoidCallback? onTapMonthly;
  final bool isPhoto;

  const OldRankAgencyBody({
    super.key,
    required this.controller,
    required this.rankController,
    required this.usersAgencyRankHour,
    required this.reqStateHour,
    required this.usersAgencyRankDay,
    required this.reqStateDay,
    required this.usersAgencyRankWeek,
    required this.reqStateWeak,
    required this.usersAgencyRankMonth,
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
  State<OldRankAgencyBody> createState() => _OldRankAgencyBodyState();
}

class _OldRankAgencyBodyState extends State<OldRankAgencyBody>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final dayTop3 = (widget.usersAgencyRankDay?.length ?? 0) < 3
        ? widget.usersAgencyRankDay ?? []
        : widget.usersAgencyRankDay!.take(3).toList();
    final dayRest = widget.usersAgencyRankDay != null
        ? widget.usersAgencyRankDay!.skip(3).toList()
        : <AgencyRankingEntity>[];

    final weekTop3 = (widget.usersAgencyRankWeek?.length ?? 0) < 3
        ? widget.usersAgencyRankWeek ?? []
        : widget.usersAgencyRankWeek!.take(3).toList();
    final weekRest = widget.usersAgencyRankWeek != null
        ? widget.usersAgencyRankWeek!.skip(3).toList()
        : <AgencyRankingEntity>[];

    final monthTop3 = (widget.usersAgencyRankMonth?.length ?? 0) < 3
        ? widget.usersAgencyRankMonth ?? []
        : widget.usersAgencyRankMonth!.take(3).toList();
    final monthRest = widget.usersAgencyRankMonth != null
        ? widget.usersAgencyRankMonth!.skip(3).toList()
        : <AgencyRankingEntity>[];

    final hourTop3 = (widget.usersAgencyRankHour?.length ?? 0) < 3
        ? widget.usersAgencyRankHour ?? []
        : widget.usersAgencyRankHour!.take(3).toList();
    final hourRest = widget.usersAgencyRankHour != null
        ? widget.usersAgencyRankHour!.skip(3).toList()
        : <AgencyRankingEntity>[];

    return Column(
      children: [
        15.hBox,
        OldInnerTabBar(
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
                  reqState: widget.reqStateHour == RequestState.empty
                      ? RequestState.loaded
                      : widget.reqStateHour,
                  title: StringManager.noUsersHour,
                  subTitle: StringManager.noUsersHourMsg,
                  onTap: widget.onTapHour,
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
                              child: Padding(
                                padding:
                                    context.paddingSymmetric(horizontal: 20),
                                child: ValueListenableBuilder<int>(
                                  valueListenable:
                                      OldRankScreenState.innerTabNotifier,
                                  builder: (context, innerIndex, _) {
                                    return RepaintBoundary(
                                      child: OldTopThreeAgencyWidget(
                                        agencyEntity: hourTop3,
                                        imageRank: widget.imageRank,
                                        isCharm: widget.index == 0,
                                        isCp: widget.index == 3,
                                        isWealth: widget.index == 1,
                                        isPhoto: innerIndex != 0,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: context
                                    .paddingSymmetric(horizontal: 00)
                                    .copyWith(top: 10),
                                child: OldAgencyRankContainerWidget(
                                  agenciesEntity: hourRest,
                                  bgColor: const Color(0xFF7C7045),
                                  isCp: widget.index == 3,
                                  isSender: widget.index == 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                HandlingDataWidget(
                  reqState: widget.reqStateDay == RequestState.empty
                      ? RequestState.loaded
                      : widget.reqStateDay,
                  title: StringManager.noUsersToday,
                  subTitle: StringManager.noUsersTodayMsg,
                  onTap: widget.onTapDay,
                  child: Stack(
                    children: [
                      RefreshIndicatorWidget(
                        onRefresh: () async {
                          widget.onTapDay!();
                        },
                        child: CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    context.paddingSymmetric(horizontal: 20),
                                child: ValueListenableBuilder<int>(
                                  valueListenable:
                                      OldRankScreenState.innerTabNotifier,
                                  builder: (context, innerIndex, _) {
                                    return RepaintBoundary(
                                      child: OldTopThreeAgencyWidget(
                                        agencyEntity: dayTop3,
                                        imageRank: widget.imageRank,
                                        isCharm: widget.index == 0,
                                        isCp: widget.index == 3,
                                        isWealth: widget.index == 1,
                                        isPhoto: innerIndex != 1,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: context
                                    .paddingSymmetric(horizontal: 00)
                                    .copyWith(top: 10),
                                child: OldAgencyRankContainerWidget(
                                  agenciesEntity: dayRest,
                                  bgColor: const Color(0xFF7C7045),
                                  isCp: widget.index == 3,
                                  isSender: widget.index == 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                HandlingDataWidget(
                  reqState: widget.reqStateWeak == RequestState.empty
                      ? RequestState.loaded
                      : widget.reqStateWeak,
                  title: StringManager.noUsersWeekly,
                  subTitle: StringManager.noUsersWeeklyMsg,
                  onTap: widget.onTapWeek,
                  child: Stack(
                    children: [
                      RefreshIndicatorWidget(
                        onRefresh: () async {
                          widget.onTapWeek!();
                        },
                        child: CustomScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    context.paddingSymmetric(horizontal: 20),
                                child: ValueListenableBuilder<int>(
                                  valueListenable:
                                      OldRankScreenState.innerTabNotifier,
                                  builder: (context, innerIndex, _) {
                                    return RepaintBoundary(
                                      child: OldTopThreeAgencyWidget(
                                        agencyEntity: weekTop3,
                                        imageRank: widget.imageRank,
                                        isCharm: widget.index == 0,
                                        isCp: widget.index == 3,
                                        isWealth: widget.index == 1,
                                        isPhoto: innerIndex != 2,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: context
                                    .paddingSymmetric(horizontal: 0)
                                    .copyWith(top: 10),
                                child: OldAgencyRankContainerWidget(
                                  agenciesEntity: weekRest,
                                  bgColor: const Color(0xFF7C7045),
                                  isCp: widget.index == 3,
                                  isSender: widget.index == 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                HandlingDataWidget(
                  reqState: widget.reqStateMonth == RequestState.empty
                      ? RequestState.loaded
                      : widget.reqStateMonth,
                  title: StringManager.noUsersMonthly,
                  subTitle: StringManager.noUsersMonthlyMsg,
                  onTap: widget.onTapMonthly,
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
                              child: Padding(
                                padding:
                                    context.paddingSymmetric(horizontal: 20),
                                child: ValueListenableBuilder<int>(
                                  valueListenable:
                                      OldRankScreenState.innerTabNotifier,
                                  builder: (context, innerIndex, _) {
                                    return RepaintBoundary(
                                      child: OldTopThreeAgencyWidget(
                                        agencyEntity: monthTop3,
                                        imageRank: widget.imageRank,
                                        isCharm: widget.index == 0,
                                        isCp: widget.index == 3,
                                        isWealth: widget.index == 1,
                                        isPhoto: innerIndex != 3,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: context
                                    .paddingSymmetric(horizontal: 00)
                                    .copyWith(top: 10),
                                child: OldAgencyRankContainerWidget(
                                  agenciesEntity: monthRest,
                                  bgColor: const Color(0xFF7C7045),
                                  isCp: widget.index == 3,
                                  isSender: widget.index == 0,
                                ),
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
