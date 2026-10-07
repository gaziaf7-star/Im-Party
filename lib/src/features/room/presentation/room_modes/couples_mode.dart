import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class CouplesMode extends StatelessWidget {
  final List<UTDParticipant> allUsers;
  final List<UTDParticipant> audioVideoUsers;
  final Widget Function(UTDParticipant user, int seatIndex) seatWidgetCreator;
  const CouplesMode({
    super.key,
    required this.allUsers,
    required this.audioVideoUsers,
    required this.seatWidgetCreator,
  });

  @override
  Widget build(BuildContext context) {
    final seatNotifier = RoomData.instance.utdController?.seatController.seats;
    // Single source of truth for the seat size (already device-scaled). The
    // couples mode declares an explicit reference seatSize on its UTDRoomMode
    // because its visual layout is 4-across (two couches/row) while its `rows`
    // metadata is 2-wide.
    final seatSize = RoomData.instance.utdController?.currentMode.value
            .computeSeatSize(MediaQuery.of(context).size.width) ??
        67.0;
    if (seatNotifier == null) {
      return _buildLayout(seatSize);
    }
    return ValueListenableBuilder<List<SeatState>>(
      valueListenable: seatNotifier,
      builder: (context, _, __) => _buildLayout(seatSize),
    );
  }

  Widget _buildLayout(double seatSize) {
    final seatHeight = seatSize * 1.15;

    // seatSize/seatHeight come from computeSeatSize and are already device-real
    // px — do NOT apply ScreenUtil (.w/.h) here or they get scaled twice.
    Widget seat(int index) => SizedBox(
          width: seatSize,
          height: seatHeight,
          child: seatWidgetCreator(
            const UTDParticipant(id: '', name: ''),
            index,
          ),
        );

    final bgWidth = seatSize * 2.4;
    final bgHeight = seatSize * 1.85;

    Widget coupleGroup(int idx1, int idx2) => Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: bgWidth,
              height: bgHeight,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AssetsManager.coupleModeSeat),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [seat(idx1), seat(idx2)],
            ),
          ],
        );

    return Padding(
      padding: EdgeInsets.only(top: 150.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [coupleGroup(0, 1), coupleGroup(2, 3)],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [coupleGroup(4, 5), coupleGroup(6, 7)],
          ),
        ],
      ),
    );
  }
}
