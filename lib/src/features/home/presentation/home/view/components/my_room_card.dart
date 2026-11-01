import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/on_multiable_tab.dart';
import 'package:general/src/features/home/data/model/my_rooms_model.dart';
import 'package:general/src/features/home/presentation/home/bloc/fetch_my_room_data_manager/fetch_my_room_data_bloc.dart';
import 'package:general/src/features/home/presentation/home/bloc/fetch_my_room_data_manager/fetch_my_room_data_event.dart';
import 'package:general/src/features/home/presentation/home/bloc/fetch_my_room_data_manager/fetch_my_room_data_state.dart';
import 'package:general/src/features/home/presentation/home/view/widgets/visitors_count.dart';
import 'package:general/src/features/room/room.dart';

class MyRoomCard extends StatefulWidget {
  const MyRoomCard({super.key});

  @override
  State<MyRoomCard> createState() => _MyRoomCardState();
}

class _MyRoomCardState extends State<MyRoomCard> {
  @override
  void initState() {
    if (!di<FetchMyRoomDataBloc>().state.requestState.isLoaded) {
      di<FetchMyRoomDataBloc>().add(const FetchMyRoomDataEvent());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchMyRoomDataBloc, FetchMyRoomDataState>(
      bloc: di<FetchMyRoomDataBloc>(),
      buildWhen: (prev, curr) =>
      prev.requestState != curr.requestState || prev.rooms != curr.rooms,
      builder: (context, state) {
        if (!di<FetchUserDataBloc>().state.reqState.isLoaded) {
          return const SizedBox();
        }

        final audioRoom = state.rooms?.audio;

        if (audioRoom?.id == 0) {
          /// No rooms -> show create room UI
          return _buildCreateRoomCard(context);
        }

        return Column(
          children: [
            if (audioRoom?.id != 0)
              _buildRoomCard(context, audioRoom!, "audio"),
          ],
        );
      },
    );
  }

  Widget _buildRoomCard(BuildContext context, MyRoom room, String type) {
    return MultiTapCard(
      onTap: () {
        di<RoomStateManager>().navigateToRoom(
          RoomEntryRequest(
            context: context,
            roomData: RoomEntity(
              ownerId: MyDataModel.getInstance().id,
              id: room.id,
              name: room.name,
              cover: room.cover,
              roomBackground: room.roomBackground,
              mode: room.mode.toString(),
              uuidOwnerRoom: MyDataModel.getInstance().uuid ?? "",
              giftPrice: room.giftPrice,
            ),
            isLive: false,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A2BF2), Color(0xFFB032E8), Color(0xFFF2459E)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB032E8).withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.r),
          child: CustomPaint(
            // Soft pattern in the background + gold flourishes in the four
            // corners.
            painter: const _RoomCardOrnamentPainter(),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFE9A8), Color(0xFFF5B521)],
                          ),
                        ),
                        child: UserImage(
                          image: room.cover,
                          displayName: room.name,
                          imageSize: 68.w,
                          borderRadius: 10.radius,
                        ),
                      ),
                      12.wBox,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    room.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                6.wBox,
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.22),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Text(
                                    type == "audio" ? "Audio" : "Live",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            4.hBox,
                            Text(
                              "ID: ${room.roomId.isNotEmpty ? room.roomId : room.id}",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            6.hBox,
                            Row(
                              children: [
                                VisitorsCount(
                                  count: room.visitorsCount.toString(),
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  isList: true,
                                ),
                                if (room.roomLevelImage != "") ...[
                                  8.wBox,
                                  ImageViewWidget(
                                    url: room.roomLevelImage,
                                    boxFit: BoxFit.contain,
                                    width: 34.w,
                                    height: 18.h,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: Colors.white.withValues(alpha: 0.85),
                          size: 24.sp),
                    ],
                  ),
                  // Room announcement.
                  if (room.roomIntro.trim().isNotEmpty) ...[
                    12.hBox,
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: const Color(0xFFFFE9A8)
                              .withValues(alpha: 0.45),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.campaign_rounded,
                              color: const Color(0xFFFFE07A), size: 16.sp),
                          6.wBox,
                          Expanded(
                            child: SizedBox(
                              height: 18.h,
                              child: AutoScrollText(
                                text: room.roomIntro.trim(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateRoomCard(BuildContext context) {
    return Container(
      margin: context.paddingSymmetric(vertical: 10, horizontal: 10),
      padding: context.paddingAll(20),
      // Fixed brand gradient (was the same green background PNG as the
      // active-room card above), on request -- kept consistent so the "no
      // room yet" state matches the "have a room" state.
      decoration: BoxDecoration(
        borderRadius: 15.radius,
        gradient: ColorManager.brandGradient,
      ),
      child: Row(
        children: [
          Container(
            padding: context.paddingAll(20),
            decoration: ColorManager.cardDecoration(
              borderRadius: 8.radius,
            ),
            child: Icon(Icons.add, color: ColorManager.iconColor, size: 30.h),
          ),
          10.wBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    TextWidget(
                      StringManager.createYourRoom.tr(),
                      maxLines: 1,
                      // Fixed white -- guaranteed to read on the fixed
                      // gradient above.
                      style: context.bodyMedium
                          .size(14)
                          .w600
                          .colorExt(ColorManager.onBrandGradient),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    ButtonWidget(
                      onPressed: () {},
                      title: StringManager.go.tr(),
                      titleColor: ColorManager.onBrandGradient,
                      fontSize: 14.sp,
                      isFittedBox: false,
                      paddingButton: context.paddingZero(),
                      width: 50.w,
                      height: 20.h,
                      // Fixed brand gradient (was the panel-driven yellow
                      // primary), on request.
                      backgroundColors: ColorManager.brandGradientColors,
                    ),
                    20.wBox,
                  ],
                ),
                10.hBox,
                Row(
                  children: [
                    Expanded(
                      child: TextWidget(
                        StringManager.enjoyLiveRoom.tr(),
                        maxLines: 1,
                        // Fixed white -- guaranteed to read on the fixed
                        // gradient above.
                        style: context.bodyMedium
                            .size(12)
                            .w400
                            .colorExt(ColorManager.onBrandGradient),
                      ),
                    ),
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
/// Light lattice pattern across the card and gold flourishes in its four
/// corners.
class _RoomCardOrnamentPainter extends CustomPainter {
  const _RoomCardOrnamentPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Diamond lattice.
    final lattice = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const step = 22.0;
    for (double x = -size.height; x < size.width + size.height; x += step) {
      canvas.drawLine(
          Offset(x, 0), Offset(x + size.height, size.height), lattice);
      canvas.drawLine(
          Offset(x, size.height), Offset(x + size.height, 0), lattice);
    }

    // Soft glow circles.
    final glow = Paint()..color = Colors.white.withValues(alpha: 0.06);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.15), 46, glow);
    canvas.drawCircle(Offset(size.width * 0.08, size.height * 0.95), 34, glow);

    // Gold corner flourishes.
    final gold = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFF1B0), Color(0xFFF2B63A)],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final dot = Paint()..color = const Color(0xFFFFE07A);
    const arm = 22.0, inset = 6.0, curl = 7.0;
    for (final corner in [
      (inset, inset, 1.0, 1.0),
      (size.width - inset, inset, -1.0, 1.0),
      (inset, size.height - inset, 1.0, -1.0),
      (size.width - inset, size.height - inset, -1.0, -1.0),
    ]) {
      final (x, y, dx, dy) = corner;
      final path = Path()
        ..moveTo(x + dx * arm, y)
        ..lineTo(x + dx * curl, y)
        ..quadraticBezierTo(x, y, x, y + dy * curl)
        ..lineTo(x, y + dy * arm)
        ..moveTo(x + dx * (arm * 0.6), y + dy * 4)
        ..quadraticBezierTo(
            x + dx * 4, y + dy * 4, x + dx * 4, y + dy * (arm * 0.6));
      canvas.drawPath(path, gold);
      canvas.drawCircle(Offset(x + dx * (arm + 3), y), 1.8, dot);
      canvas.drawCircle(Offset(x, y + dy * (arm + 3)), 1.8, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _RoomCardOrnamentPainter old) => false;
}
