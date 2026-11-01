import 'dart:io';
import 'package:general/src/features/room/presentation/component/seat_config/charisma_badge_widget.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/component/seat_config/seat_metrics.dart';
import 'package:general/src/features/room/presentation/component/seat_config/seat_mute_badge.dart';

class LockedSeatWidget extends StatelessWidget {
  final int index;

  /// The full seat slot size provided by the audio-room kit. The icon is sized
  /// to [SeatMetrics.avatar] — the SAME shared source the occupied avatar and
  /// the empty seat use — so all seat states match exactly, and leave room for
  /// the index label so the column never overflows the tight square the kit lays
  /// the seat out in.
  final double size;
  const LockedSeatWidget({super.key, required this.index, required this.size});

  @override
  Widget build(BuildContext context) {
    final m = SeatMetrics.forSeat(size);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Mirrors EmptySeat: fills the shared avatar slot directly, no
        // background disc/container behind the icon.
        Flexible(
          child: AspectRatio(
            aspectRatio: 1,
            child: SizedBox(
              width: m.avatar,
              height: m.avatar,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child:
                        Methods.getMicImageClose() != null
                            ? ClipOval(
                              child: Image.file(
                                File(Methods.getMicImageClose() ?? ''),
                                fit: BoxFit.cover,
                              ),
                            )
                            : Image.asset(
                              AssetsManager.lockSeat,
                              fit: BoxFit.contain,
                            ),
                  ),
                  AllMuteSeatBadge(avatarSize: m.avatar),
                ],
              ),
            ),
          ),
        ),
        Text(
          "${index + 1}",
          textAlign: TextAlign.center,
          style: context.bodyMedium
              .copyWith(fontSize: m.indexFont)
              .w400
              .colorExt(ColorManager.white),
        ),
        // Same line as occupied seats, so all seats keep one height.
        CharismaValueLine(
          userId: '',
          fontSize: m.charismaFont,
          iconSize: m.charismaIcon,
        ),
      ],
    );
  }
}
