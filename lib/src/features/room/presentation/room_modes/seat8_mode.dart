import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class Seat8Mode extends StatelessWidget {
  final List<UTDParticipant> allUsers;
  final List<UTDParticipant> audioVideoUsers;
  final Widget Function(UTDParticipant user, int seatIndex) seatWidgetCreator;
  const Seat8Mode({
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
      return _buildOvalLayout(seatSize);
    }
    return ValueListenableBuilder<List<SeatState>>(
      valueListenable: seatNotifier,
      builder: (context, _, __) {
        return _buildOvalLayout(seatSize);
      },
    );
  }

  Widget _buildOvalLayout(double seatSize) {
    // seatSize is already device-real px — do NOT apply ScreenUtil (.w/.h).
    // Background art keeps its original 90/80 ratio relative to the seat.
    final double bgSize = seatSize * 1.125;

    Widget seat(int index) => SizedBox(
          width: seatSize,
          height: seatSize,
          child: seatWidgetCreator(
            const UTDParticipant(id: '', name: ''),
            index,
          ),
        );

    return Padding(
      padding: EdgeInsets.only(top: 150.h),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 85.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  children: [
                    Container(
                      width: bgSize,
                      height: bgSize,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          matchTextDirection: true,
                          image: AssetImage(AssetsManager.seat1),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    seat(0),
                  ],
                ),
                Stack(
                  children: [
                    Container(
                      width: bgSize,
                      height: bgSize,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          matchTextDirection: true,
                          image: AssetImage(AssetsManager.seat2),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    seat(1),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  children: [
                    Container(
                      width: bgSize,
                      height: bgSize,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          matchTextDirection: true,
                          image: AssetImage(AssetsManager.seat3),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    seat(2),
                  ],
                ),
                Stack(
                  children: [
                    Container(
                      width: bgSize,
                      height: bgSize,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          matchTextDirection: true,
                          image: AssetImage(AssetsManager.seat4),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    seat(3),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  children: [
                    Container(
                      width: bgSize,
                      height: bgSize,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          matchTextDirection: true,
                          image: AssetImage(AssetsManager.seat5),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    seat(4),
                  ],
                ),
                Stack(
                  children: [
                    Container(
                      width: bgSize,
                      height: bgSize,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          matchTextDirection: true,
                          image: AssetImage(AssetsManager.seat6),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    seat(5),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  children: [
                    Container(
                      width: bgSize,
                      height: bgSize,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          matchTextDirection: true,
                          image: AssetImage(AssetsManager.seat7),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    seat(6),
                  ],
                ),
                Stack(
                  children: [
                    Container(
                      width: bgSize,
                      height: bgSize,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          matchTextDirection: true,
                          image: AssetImage(AssetsManager.seat8),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    seat(7),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
