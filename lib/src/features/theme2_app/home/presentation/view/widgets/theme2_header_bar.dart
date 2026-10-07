import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/md_indicator.dart';
import 'package:general/src/core/widgets/on_multiable_tab.dart';
import 'package:general/src/features/home/presentation/home/bloc/fetch_my_room_data_manager/fetch_my_room_data_bloc.dart';
import 'package:general/src/features/home/presentation/home/bloc/fetch_my_room_data_manager/fetch_my_room_data_state.dart';
import 'package:general/src/features/live_room/presentation/go_live_flow.dart';
import 'package:general/src/features/room/room.dart';

class Theme2HeaderBar extends StatelessWidget {
  final TabController controller;
  final HomeBloc bloc;

  const Theme2HeaderBar({
    super.key,
    required this.controller,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingOnly(top: 5, bottom: 5),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Start Live (camera) icon — far left
            if (ConstantsManager.isAudioRoomsEnabled ||
                ConstantsManager.isShowLive)
              BlocBuilder<FetchMyRoomDataBloc, FetchMyRoomDataState>(
                bloc: di<FetchMyRoomDataBloc>(),
                buildWhen: (prev, curr) =>
                    prev.requestState != curr.requestState,
                builder: (context, state) {
                  return state.requestState.isLoaded
                      ? MultiTapCard(
                          onTap: () => _handleRoomEntry(context, state),
                          child: Padding(
                            padding: context.paddingSymmetric(horizontal: 4),
                            child: Image.asset(
                              AssetsManager.icStartLive,
                              height: 24.h,
                              width: 24.w,
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                },
              ),

            // Trophy icon
            IconButton(
              onPressed: () =>
                  Navigator.pushNamed(context, Routes.rankScreen, arguments: 1),
              icon: Icon(
                Icons.emoji_events,
                color: ColorManager.iconColor,
                size: 30.h,
              ),
              iconSize: 30.h,
            ),

            // Search icon (moved to where the camera used to be)
            IconButton(
              onPressed: () =>
                  Navigator.pushNamed(context, Routes.searchScreen),
              icon: Icon(
                Icons.search,
                color: ColorManager.iconColor,
                size: 30.h,
              ),
              iconSize: 30.h,
            ),
            10.horizontalSpace,

            // Tab bar — wrapped RTL so the Arabic tabs start from the far
            // right (ذو صلة on the right, تريند in the middle = default,
            // اكتشاف on the left). The tab LIST order is kept unchanged so the
            // parent TabController index mapping stays valid.
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: TabBar(
                  controller: controller,
                  overlayColor: WidgetStateColor.transparent,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabAlignment: TabAlignment.start,
                  isScrollable: true,
                  dividerHeight: 0,
                  indicator: MDIndicator(
                    indicatorGradient: const LinearGradient(
                      colors: ColorManager.theme2TabGradient,
                    ),
                    indicatorWidth: 17.0.w,
                    indicatorHeight: 4.h,
                    radius: 20.r,
                  ),
                  labelPadding: context.paddingOnly(start: 12),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: ColorManager.theme2TabInactive,
                  ),
                  labelStyle: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.headerColor,
                  ),
                  tabs: [
                    Text(StringManager.theme2Related.tr()),
                    Text(StringManager.theme2Trending.tr()),
                    // Live<->Discover swapped per owner request. Live (index 2)
                    // is present only when live is enabled; Discover is always
                    // last.
                    if (ConstantsManager.isShowLive)
                      Text(StringManager.live.tr()),
                    Text(StringManager.discover.tr()),
                  ],
                ),
              ),
            ),
            // Theme2 logo
            10.horizontalSpace,
          ],
        ),
      ),
    );
  }

  Future<void> _handleRoomEntry(
      BuildContext context, FetchMyRoomDataState state) async {
    if (RoomData.instance.utdController?.minimize.isMinimizing ?? false) {
      final navContext = SafeNavigator.context;
      if (navContext == null) return;
      await di<RoomStateManager>().exitRoom(navContext);
    }

    if (ConstantsManager.isShowLive) {
      // Small audio/live chooser (TikTok-style) — no "start a show" page.
      if (di<RoomStateManager>().isInRoom) {
        final navContext = SafeNavigator.context;
        if (navContext == null) return;
        await di<RoomStateManager>().exitRoom(
          navContext,
          callback: () {
            GoLiveFlow.showStartDialog(context, state.rooms);
          },
        );
      } else {
        GoLiveFlow.showStartDialog(context, state.rooms);
      }
    } else {
      Methods.handleRoomEntry(context, state.rooms?.audio);
    }
  }
}
