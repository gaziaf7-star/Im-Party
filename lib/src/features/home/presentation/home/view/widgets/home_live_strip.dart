import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/domain/entities/room_entity.dart';
import 'package:general/src/features/home/presentation/home/bloc/home_manager/home_bloc.dart';
import 'home_banner_metrics.dart';

/// The row of live/video rooms that breaks up the party list.
///
/// Reads `HomeState.stream`, the live-room list the Live tab already fetches, so
/// nothing new is requested — the same data appears inline on the home feed
/// after the first few party rows, which is where the reference layout puts it.
///
/// Renders nothing at all when there are no live rooms, rather than an empty
/// band: a home feed with no one streaming should simply not show the row.
class HomeLiveStrip extends StatelessWidget {
  const HomeLiveStrip({super.key, this.maxItems = 8});

  final int maxItems;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: di<HomeBloc>(),
      buildWhen: (prev, curr) =>
          prev.stream != curr.stream || prev.reqStateLive != curr.reqStateLive,
      builder: (context, state) {
        final rooms = state.stream;
        if (rooms.isEmpty) return const SizedBox.shrink();

        final visible =
            rooms.length > maxItems ? rooms.sublist(0, maxItems) : rooms;
        final height = HomeBannerMetrics.liveCardHeight();

        return SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: context.paddingSymmetric(
              horizontal: HomeBannerMetrics.edge,
            ),
            itemCount: visible.length,
            separatorBuilder: (_, __) =>
                SizedBox(width: HomeBannerMetrics.gapCardsW),
            itemBuilder: (context, index) => _LiveCard(
              room: visible[index],
              width: HomeBannerMetrics.liveCardWidth(),
              height: height,
            ),
          ),
        );
      },
    );
  }
}

class _LiveCard extends StatelessWidget {
  const _LiveCard({
    required this.room,
    required this.width,
    required this.height,
  });

  final RoomEntity room;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final name = (room.name?.isNotEmpty ?? false)
        ? room.name!
        : (room.ownerName ?? '');

    return GestureDetector(
      onTap: () => di<RoomStateManager>().navigateToRoom(
        RoomEntryRequest(
          context: context,
          roomData: room,
          isLive: true,
        ),
      ),
      child: SizedBox(
        width: width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(HomeBannerMetrics.radius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ImageViewWidget(
                url: room.cover ?? '',
                boxFit: BoxFit.cover,
                width: width,
                height: height,
                isRoomCover: true,
              ),
              // Scrim so the name stays legible over any cover.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: height * 0.42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        ColorManager.black.withValues(alpha: 0.70),
                        ColorManager.black.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ColorManager.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if ((room.visitorsCount ?? 0) > 0) ...[
                      4.wBox,
                      Text(
                        '${room.visitorsCount}',
                        style: TextStyle(
                          color: ColorManager.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
