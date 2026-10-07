import 'dart:math' as math;

import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/youtube/view/youtube_view.dart';
import 'package:general/src/features/room/room.dart';

class CinemaModeLayout extends StatelessWidget {
  final List<UTDParticipant> allUsers;
  final List<UTDParticipant> audioVideoUsers;
  final Widget Function(UTDParticipant user, int seatIndex) seatWidgetCreator;
  const CinemaModeLayout({
    super.key,
    required this.allUsers,
    required this.audioVideoUsers,
    required this.seatWidgetCreator,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final seatSize = RoomData.instance.utdController?.currentMode.value
            .computeSeatSize(width) ??
        80;

    final seatNotifier = RoomData.instance.utdController?.seatController.seats;
    if (seatNotifier == null) {
      return Column(
        children: [
          YoutubeView(
            roowOwnerId: RoomData.instance.room.ownerId.toString(),
            roomId: RoomData.instance.room.id.toString(),
          ),
          SizedBox(height: 10.h),
          _buildSeatLayout(seatSize, width),
        ],
      );
    }
    return Column(
      children: [
        YoutubeView(
          roowOwnerId: RoomData.instance.room.ownerId.toString(),
          roomId: RoomData.instance.room.id.toString(),
        ),
        SizedBox(height: 10.h),
        ValueListenableBuilder<List<SeatState>>(
          valueListenable: seatNotifier,
          builder: (context, _, __) => _buildSeatLayout(seatSize, width),
        ),
      ],
    );
  }

  Widget _buildSeatLayout(double seatSize, double maxWidth) {
    // seatSize is already device-real px (from computeSeatSize) — do NOT apply
    // ScreenUtil (.w/.h). Background art keeps its original 90/80 ratio, but is
    // capped so the 4-across `spaceBetween` row always fits very narrow screens.
    final double bgSize = math.min(seatSize * 1.125, maxWidth / 4.2);

    Widget seat(int index) => SizedBox(
          width: seatSize,
          height: seatSize,
          child: seatWidgetCreator(
            const UTDParticipant(id: '', name: ''),
            index,
          ),
        );

    Widget seatWithBg(int index) => Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: bgSize,
              height: bgSize,
              decoration: BoxDecoration(
                image: DecorationImage(
                  matchTextDirection: true,
                  image: AssetImage(AssetsManager.cinemaSeat),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            seat(index),
          ],
        );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            seatWithBg(0),
            seatWithBg(1),
            seatWithBg(2),
            seatWithBg(3),
          ],
        ),
        5.hBox,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            seatWithBg(4),
            seatWithBg(5),
            seatWithBg(6),
            seatWithBg(7),
          ],
        ),
      ],
    );
  }
}
