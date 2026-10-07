import 'package:flutter/cupertino.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/charisma/bloc/charisma_bloc.dart';
import 'package:general/src/features/room/presentation/component/seat_config/arc_container_widget.dart';
import 'package:general/src/features/room/presentation/component/seat_config/seat_metrics.dart';
import 'package:general/src/features/room/room.dart';
import 'package:collection/collection.dart';

/// Charisma badge shown over an avatar (seat avatars and the room-owner header).
///
/// Single source of truth for the badge so the seat avatar and the host header
/// render identical badges: it reads [CharismaBloc] keyed by [userId], gated by
/// [RoomData.isCharismaVisible], and shows the tier image (when
/// [ConstantsManager.isCharismaBadge]) or the legacy heart badge as fallback.
class CharismaBadge extends StatelessWidget {
  final String userId;
  final double imageSize;

  const CharismaBadge({
    super.key,
    required this.userId,
    required this.imageSize,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: RoomData.instance.isCharismaVisible,
      builder: (context, value, _) {
        if (!value) return const SizedBox();

        return BlocSelector<
          CharismaBloc,
          CharismaState,
          ({String total, String? levelImage})
        >(
          bloc: di<CharismaBloc>(),
          selector: (state) {
            final userData = state.data?.firstWhereOrNull(
              (element) => element.userId.toString() == userId,
            );
            final total = userData?.total ?? "0";
            // (F) Badge tier keys off the PRECISE integer carried in the frame
            // (total_value), not a lossy reverse of the abbreviated string — so
            // the tier no longer flickers near a threshold after a round-trip.
            final points = userData?.totalValue ?? 0;
            final levelImage =
                ConstantsManager.isCharismaBadge
                    ? CharismaBloc.getLevelImage(points)
                    : null;
            return (total: total, levelImage: levelImage);
          },
          builder: (context, data) {
            final m = SeatMetrics.forAvatar(imageSize);
            if (data.levelImage != null && data.levelImage!.isNotEmpty) {
              return Positioned(
                // Anchor the charisma badge over the lower edge of the avatar
                // (same vertical anchor as the legacy heart badge) so it sits on
                // the image instead of dropping onto — and covering — the name.
                bottom: imageSize * 0.05,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: imageSize * 1.1,
                      height: imageSize * 0.45,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          ImageViewWidget(
                            url: data.levelImage!,
                            isFromRoom: true,
                            height: imageSize * 0.45,
                            width: imageSize * 1.3,
                            boxFit: BoxFit.contain,
                          ),
                          Positioned(
                            bottom: imageSize * 0.22,
                            child: Text(
                              data.total,
                              style: context.bodyMedium
                                  .copyWith(fontSize: m.charismaFont)
                                  .w600
                                  .colorExt(ColorManager.onDark)
                                  .copyWith(height: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            // Default: show old heart badge
            return Positioned(
              bottom: imageSize * 0.05,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomPaint(
                    painter: ArcContainerPainter(
                      backgroundColor: ColorManager.black.withValues(
                        alpha: 0.6,
                      ),
                    ),
                    child: SizedBox(
                      width: imageSize * 0.9,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.heart_fill,
                              color: ColorManager.redIcons,
                              size: m.charismaIcon,
                            ),
                            SizedBox(width: m.charismaGap),
                            Text(
                              data.total,
                              style: context.bodyMedium
                                  .copyWith(fontSize: m.charismaFont)
                                  .w600
                                  .colorExt(ColorManager.onDark)
                                  .copyWith(height: 0.9),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
