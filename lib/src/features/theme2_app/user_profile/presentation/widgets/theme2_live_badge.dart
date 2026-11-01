import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/domain/entities/now_room_entity.dart';
import 'package:general/src/features/home/domain/entities/room_entity.dart';

/// Animated "تتبع"/live badge shown on the visitor profile header when the
/// profiled user is currently inside a room. It pulses (scale + glow) to draw
/// attention and, on tap, enters that room reusing the canonical room-enter
/// flow ([RoomStateManager.navigateToRoom]) — the same path a room-list tap
/// uses (see theme2_room_card.dart), so password / PiP / same-room handling
/// all come for free.
class Theme2LiveBadge extends StatefulWidget {
  /// The room the profiled user is currently in. The badge is only built by the
  /// caller when this is non-null with a valid id, so we treat it as present.
  final NowRoomEntity nowRoom;

  const Theme2LiveBadge({super.key, required this.nowRoom});

  @override
  State<Theme2LiveBadge> createState() => _Theme2LiveBadgeState();
}

class _Theme2LiveBadgeState extends State<Theme2LiveBadge>
    with SingleTickerProviderStateMixin {
  /// Drives the three "audio" bars (same feel as the room's speaking bars).
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _enterRoom() {
    final roomId = widget.nowRoom.id;
    if (roomId == null || roomId == 0) return;

    final roomEntity = RoomEntity(
      id: roomId,
      name: widget.nowRoom.roomName,
      cover: widget.nowRoom.roomCover,
      roomBackground: widget.nowRoom.roomBackground,
      mode: widget.nowRoom.mode,
      giftPrice: widget.nowRoom.giftPrice,
      passwordStatus: widget.nowRoom.roomStatus,
    );

    di<RoomStateManager>().navigateToRoom(
      RoomEntryRequest(
        context: context,
        roomData: roomEntity,
        isLive: false,
      ),
    );
  }

  /// Bar height 0..1 for bar [i]: each bar bounces on its own phase.
  double _bar(int i) {
    final t = (_controller.value + i * 0.27) % 1.0;
    final tri = t < .5 ? t * 2 : (1 - t) * 2;
    return .35 + .65 * Curves.easeInOut.transform(tri);
  }

  @override
  Widget build(BuildContext context) {
    // Tab hugging the right screen edge (rounded on the left only), orange to
    // red, with bouncing audio bars -- tap to enter the room they are in.
    final barW = 4.w, barMax = 16.h;
    return GestureDetector(
      onTap: _enterRoom,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 46.h,
        padding: EdgeInsets.fromLTRB(16.w, 0, 18.w, 0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFFF7A45), Color(0xFFFF3D5E)],
          ),
          borderRadius: BorderRadius.horizontal(left: Radius.circular(23.r)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF3D5E).withValues(alpha: .35),
              blurRadius: 10.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) SizedBox(width: 3.w),
                Padding(
                  padding: EdgeInsets.only(bottom: 15.h),
                  child: Container(
                    width: barW,
                    height: barMax * _bar(i),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(barW),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
