import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class Seat2Mode extends StatelessWidget {
  final List<UTDParticipant> allUsers;
  final List<UTDParticipant> audioVideoUsers;
  final Widget Function(UTDParticipant user, int seatIndex) seatWidgetCreator;
  const Seat2Mode({
    super.key,
    required this.allUsers,
    required this.audioVideoUsers,
    required this.seatWidgetCreator,
  });

  @override
  Widget build(BuildContext context) {
    final seatNotifier = RoomData.instance.utdController?.seatController.seats;
    // Single source of truth for the seat size (already device-scaled).
    final seatSize = RoomData.instance.utdController?.currentMode.value
            .computeSeatSize(MediaQuery.of(context).size.width) ??
        80.0;
    if (seatNotifier == null) {
      return _buildLayout(seatSize);
    }
    return ValueListenableBuilder<List<SeatState>>(
      valueListenable: seatNotifier,
      builder: (context, _, __) => _buildLayout(seatSize),
    );
  }

  Widget _buildLayout(double seatSize) {
    // seatSize is already device-real px — do NOT apply ScreenUtil (.w/.h).
    Widget seat(int index) => SizedBox(
          width: seatSize,
          height: seatSize,
          child: seatWidgetCreator(
            const UTDParticipant(id: '', name: ''),
            index,
          ),
        );

    final bgWidth = seatSize * 1.875;
    final bgHeight = seatSize * 2.0;

    return Padding(
      padding: EdgeInsets.only(top: 150.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: bgWidth,
                height: bgHeight,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    matchTextDirection: true,
                    image: AssetImage(AssetsManager.dateModeSeat1),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              seat(0),
            ],
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: bgWidth,
                height: bgHeight,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    matchTextDirection: true,
                    image: AssetImage(AssetsManager.dateModeSeat2),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              seat(1),
            ],
          ),
        ],
      ),
    );
  }
}
