part of '../medals_page.dart';

class _PersonalTabViewBody extends StatefulWidget {
  const _PersonalTabViewBody({
    required this.controller,
    required this.state,
  });

  final TabController controller;
  final GetBadgesStates state;

  @override
  State<_PersonalTabViewBody> createState() => _PersonalTabViewBodyState();
}

class _PersonalTabViewBodyState extends State<_PersonalTabViewBody> {
  @override
  void initState() {
    if (widget.state.rechargeBadgeRequest != RequestState.loaded) {
      di<GetBadgesBloc>().add(const RechargeEvent());
    }
    widget.controller.addListener(() {
      if (widget.controller.index == 1) {
        if (widget.state.activityBadgeRequest != RequestState.loaded) {
          di<GetBadgesBloc>().add(const ActivityEvent());
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    //widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: ScreenUtil().screenHeight * 0.75,
        width: ScreenUtil().screenHeight,
        decoration: BoxDecoration(
          color: ColorManager.scaffoldBg,
          borderRadius: 25.radius,
        ),
        child: Column(
          children: [
            5.hBox,
            MedalsTabBar(
              titles: [
                StringManager.achievementBadge.tr(),
                StringManager.specialBadge.tr(),
              ],
              controller: widget.controller,
            ),
            SizedBox(
              height: 570.h,
              child: TabBarView(
                controller: widget.controller,
                children: [
                  RefreshIndicatorWidget(
                    onRefresh: () async {
                      di<GetBadgesBloc>()
                          .add(const RechargeEvent(isLoading: false));
                    },
                    child: MedalsTabBarView(
                      type: '1',
                      badges: widget.state.rechargeBadge,
                      reqState: widget.state.rechargeBadgeRequest,
                      error: widget.state.rechargeBadgeMessage,
                    ),
                  ),
                  RefreshIndicatorWidget(
                    onRefresh: () async {
                      di<GetBadgesBloc>()
                          .add(const ActivityEvent(isLoading: false));
                    },
                    child: MedalsTabBarView(
                      type: '4',
                      badges: widget.state.activityBadge,
                      reqState: widget.state.activityBadgeRequest,
                      error: widget.state.activityBadgeMessage,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
