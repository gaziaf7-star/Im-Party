import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/presentation/home/bloc/home_manager/home_bloc.dart';
import 'package:general/src/features/home/presentation/home/bloc/fetch_my_room_data_manager/fetch_my_room_data_bloc.dart';
import 'package:general/src/features/live_room/presentation/go_live_flow.dart';
import 'package:general/src/features/home/presentation/home/view/components/room_card_body.dart';
import 'package:general/src/features/home/presentation/home/bloc/get_carousel_manager/get_carousel_bloc.dart';
import 'package:general/src/features/home/presentation/home/view/widgets/carousel_widget.dart';
import 'package:general/src/features/home/presentation/home/view/widgets/home_banner_metrics.dart';

/// The "Live" tab of the Theme2 home — lists the currently-open live rooms.
///
/// Bound to [HomeBloc]'s live-rooms slice (`state.stream` / `reqStateLive` /
/// `isPaginatingLive`, paginated through `streamScrollCtrl`). Unlike the other
/// Theme2 tabs — which were written while video live was removed and ignore taps
/// on `streamType == "live"` cards — tapping a card here ENTERS the live room via
/// [RoomStateManager.navigateToRoom] with `isLive: true`.
class Theme2LivesBody extends StatefulWidget {
  final HomeBloc bloc;
  const Theme2LivesBody({super.key, required this.bloc});

  @override
  State<Theme2LivesBody> createState() => _Theme2LivesBodyState();
}

class _Theme2LivesBodyState extends State<Theme2LivesBody>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  /// How many rooms get the rank-badge + SVGA treatment (theme_1's
  /// [RoomCardBody] layout — 2-column grid, first 4 ranked) before the plain
  /// second grid starts.
  static const int _rankedCount = 4;

  static final _firstGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 17.5.h,
    crossAxisSpacing: 17.5.w,
    childAspectRatio: 0.85,
  );

  static final _secondGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 10.h,
    crossAxisSpacing: 10.w,
    childAspectRatio: 0.85,
  );

  @override
  void initState() {
    super.initState();
    // The 'live' carousel slot is only ever requested from the Popular tab's
    // interlude banner (see all_view_body.dart), so it never loads if that
    // tab isn't visited first. Ask for it here too so this tab's own top
    // banner has data on a fresh Live-tab open.
    if (!di<GetCarouselBloc>().state.liveState.isLoaded) {
      di<GetCarouselBloc>().add(const GetLiveCarouselEvent(isLoading: false));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<HomeBloc, HomeState>(
      bloc: widget.bloc,
      buildWhen: (prev, curr) =>
          prev.stream != curr.stream ||
          prev.reqStateLive != curr.reqStateLive ||
          prev.isPaginatingLive != curr.isPaginatingLive,
      builder: (context, homeState) {
        final rooms = homeState.stream;
        final count = rooms.length;

        return RefreshIndicatorWidget(
          onRefresh: () async {
            widget.bloc.add(const FetchLiveRoomsEvent(
                isLiveLoading: false, isFirstPage: true));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: homeState.streamScrollCtrl,
            // Flutter 3.44 spells this scrollCacheExtent: ScrollCacheExtent.pixels(250).
            // Restore that when the toolchain is upgraded; 250 logical pixels either way.
            cacheExtent: 250,
            slivers: [
              // Top banner (theme2 style — same widget/metrics as the Popular
              // tab's banner), on request, so the Live tab isn't just a bare
              // list under the tab bar.
              SliverToBoxAdapter(
                child: Padding(
                  padding: context.paddingSymmetric(
                    horizontal: HomeBannerMetrics.edge,
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(HomeBannerMetrics.radius),
                    child: CarouselWidget(
                      type: "noEvent",
                      source: 'live',
                      height: HomeBannerMetrics.bannerHeight(),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: HomeBannerMetrics.gapBannerToCards),
              ),

              if (homeState.reqStateLive.isLoading ||
                  homeState.reqStateLive.isError)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: context.paddingSymmetric(horizontal: 10),
                    child: HandlingDataWidget(
                      reqState: homeState.reqStateLive,
                      title: StringManager.noRooms.tr(),
                      subTitle: StringManager.noRoomsMsg.tr(),
                      onTap: () => widget.bloc
                          .add(const FetchLiveRoomsEvent(isFirstPage: true)),
                      childEmpty: const SizedBox(),
                      child: const SizedBox.shrink(),
                    ),
                  ),
                ),

              // No broadcasts right now: invite the user to be the FIRST host
              // instead of a blank page (owner spec 2026-06-11).
              if (count == 0 && homeState.reqStateLive.isLoaded)
                const SliverToBoxAdapter(child: _NoLivesNow()),

              // theme_1 style: a 2-column grid, ranked first 4 (SVGA + rank
              // badge, RoomCardBody) then the rest as a plain 2-column grid —
              // same layout as _RoomsWithCarouselGrid, on request.
              if (count > 0 && homeState.reqStateLive.isLoaded) ...[
                SliverPadding(
                  padding: context.paddingSymmetric(horizontal: 10),
                  sliver: SliverGrid.builder(
                    itemCount: count < _rankedCount ? count : _rankedCount,
                    gridDelegate: _firstGridDelegate,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      return RepaintBoundary(
                        child: RoomCardBody(
                          key: ValueKey('theme2_${room.id}'),
                          data: room,
                          isLoading:
                              di<FetchUserDataBloc>().state.reqState.isLoaded,
                          isShowSVGA: true,
                          isLive: true,
                          rank: index + 1,
                        ),
                      );
                    },
                  ),
                ),
                if (count > _rankedCount)
                  SliverPadding(
                    padding: context.paddingSymmetric(horizontal: 10),
                    sliver: SliverGrid.builder(
                      itemCount: count - _rankedCount,
                      gridDelegate: _secondGridDelegate,
                      itemBuilder: (context, index) {
                        final room = rooms[index + _rankedCount];
                        return RepaintBoundary(
                          child: RoomCardBody(
                            key: ValueKey('theme2_${room.id}'),
                            data: room,
                            isLoading: di<FetchUserDataBloc>()
                                .state
                                .reqState
                                .isLoaded,
                            isLive: true,
                          ),
                        );
                      },
                    ),
                  ),
              ],

              if (homeState.isPaginatingLive)
                const SliverToBoxAdapter(child: CircleLoadingWidget()),

              SliverToBoxAdapter(child: 80.hBox),
            ],
          ),
        );
      },
    );
  }
}


/// Pretty empty state for the lives list: no one is live right now — be the
/// first to go live and invite your friends. CTA opens the go-live flow.
class _NoLivesNow extends StatelessWidget {
  const _NoLivesNow();

  @override
  Widget build(BuildContext context) {
    final ar = Methods.getLang() == 'ar';
    return Padding(
      padding: context.paddingSymmetric(horizontal: 24, vertical: 60),
      child: Column(
        children: [
          Container(
            padding: context.paddingAll(22),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorManager.primary.withValues(alpha: 0.12),
            ),
            child: Icon(Icons.podcasts,
                size: 56.sp, color: ColorManager.primary),
          ),
          18.hBox,
          TextWidget(
            ar
                ? 'لا يوجد بث مباشر متاح الآن'
                : 'No live broadcasts right now',
            style: context.bodyLarge.w700
                .colorExt(ColorManager.theme2TextPrimary)
                .size(17),
            textAlign: TextAlign.center,
          ),
          8.hBox,
          TextWidget(
            ar
                ? 'كن أول من يبدأ البث المباشر وادعُ أصدقاءك! 🎥✨'
                : 'Be the first to go live and invite your friends! 🎥✨',
            style: context.bodyMedium
                .colorExt(ColorManager.theme2TextPrimary.withValues(alpha: 0.7)),
            textAlign: TextAlign.center,
          ),
          22.hBox,
          ButtonWidget(
            onPressed: () {
              final rooms = di<FetchMyRoomDataBloc>().state.rooms;
              GoLiveFlow.startLive(context, rooms?.live);
            },
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.videocam_rounded,
                    color: ColorManager.buttonTextColor, size: 20.sp),
                8.wBox,
                TextWidget(
                  ar ? 'ابدأ بثك الآن' : 'Go live now',
                  style: context.bodyMedium.w700
                      .colorExt(ColorManager.buttonTextColor),
                ),
              ],
            ),
            backgroundColor: ColorManager.primary,
            width: 200.w,
            height: 46.h,
            radius: 23,
          ),
        ],
      ),
    );
  }
}
