part of '../medals_page.dart';

class _RoomTabViewBody extends StatefulWidget {
  const _RoomTabViewBody({
    required this.controller,
    required this.state,
  });

  final TabController controller;
  final GetBadgesStates state;

  @override
  State<_RoomTabViewBody> createState() => _RoomTabViewBodyState();
}

class _RoomTabViewBodyState extends State<_RoomTabViewBody> {
  @override
  void initState() {
    if (widget.state.roomBadgeRequest != RequestState.loaded) {
      di<GetBadgesBloc>().add(const RoomEvent());
    }
    widget.controller.addListener((){
      if(widget.controller.index == 1){
        if (widget.state.giftBadgeRequest != RequestState.loaded) {
          di<GetBadgesBloc>().add(const GiftEvent());
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: ScreenUtil().screenHeight * 0.77,
        width: ScreenUtil().screenHeight,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: 25.radius,
        ),
        child: Column(
          children: [
            5.hBox,
            MedalsTabBar(
              titles: [
                StringManager.roomBadge.tr(),
                StringManager.giftBadge.tr(),
              ],
              controller: widget.controller,
            ),
            SizedBox(
              height: 570.h,
              child: TabBarView(
                controller: widget.controller,
                children: [
                  RefreshIndicatorWidget(
                    onRefresh: () async =>
                        di<GetBadgesBloc>().add(const RoomEvent(isLoading: false)),
                    child: MedalsTabBarView(
                      type: '2',
                      badges: widget.state.roomBadge,
                      reqState: widget.state.roomBadgeRequest,
                      error: widget.state.roomBadgeMessage,
                    ),
                  ),
                  RefreshIndicatorWidget(
                    onRefresh: () async =>
                        di<GetBadgesBloc>().add(const GiftEvent(isLoading: false)),
                    child: MedalsTabBarView(
                      type: '3',
                      badges: widget.state.giftBadge,
                      reqState: widget.state.giftBadgeRequest,
                      error: widget.state.giftBadgeMessage,
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
