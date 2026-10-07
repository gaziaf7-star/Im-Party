import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class Seat22Mode extends StatelessWidget {
  final List<UTDParticipant> allUsers;
  final List<UTDParticipant> audioVideoUsers;
  final Widget Function(UTDParticipant user, int seatIndex) seatWidgetCreator;
  const Seat22Mode({
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
        75.0;
    if (seatNotifier == null) {
      return _buildLayout(context, seatSize);
    }
    return ValueListenableBuilder<List<SeatState>>(
      valueListenable: seatNotifier,
      builder: (context, _, __) => _buildLayout(context, seatSize),
    );
  }

  Widget _buildLayout(BuildContext context, double seatSize) {
    // seatSize is already device-real px — do NOT apply ScreenUtil (.w/.h).
    Widget seat(int index) => SizedBox(
      width: seatSize,
      height: seatSize,
      child: seatWidgetCreator(const UTDParticipant(id: '', name: ''), index),
    );

    Widget seatWithBg(int index) => SizedBox(
      width: seatSize,
      height: seatSize,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: seatSize,
              height: seatSize,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AssetsManager.roomPkDizuo),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          seat(index),
        ],
      ),
    );

    final rowGap = seatSize * 0.05;
    final screenWidth = MediaQuery.of(context).size.width;
    final sidePad = screenWidth * 0.0125;

    // Force LTR so the PK teams keep a fixed physical side regardless of the
    // app's Arabic RTL directionality: data column 0 stays on the physical LEFT
    // (red/team1) and column 4 on the physical RIGHT (blue/team2), matching the
    // PK score bar (left bar red, right bar blue).
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [seat(0)]),
        Padding(
          padding: EdgeInsets.only(top: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: sidePad),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [seatWithBg(1)],
                ),
              ),
              SizedBox(height: rowGap),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [seat(2), seat(3), seat(4), seat(5), seat(6)],
              ),
              SizedBox(height: rowGap),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [seat(7), seat(8), seat(9), seat(10), seat(11)],
              ),
              SizedBox(height: rowGap),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [seat(12), seat(13), seat(14), seat(15), seat(16)],
              ),
              SizedBox(height: rowGap),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [seat(17), seat(18), seat(19), seat(20), seat(21)],
              ),
            ],
          ),
        ),
      ],
      ),
    );
  }
}
