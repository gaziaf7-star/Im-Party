import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/core/widgets/id_with_copy.dart';
import 'package:general/src/features/auth/domain/entities/my_data_entity.dart';
import 'package:general/src/features/room/room.dart';
import '../../../gifts/bloc/gift_bloc/gift_bloc.dart';

class OwnerOfRoom extends StatelessWidget {
  final EnterRoomModel roomData;
  final String introRoom;
  final String roomImg;
  final String roomName;
  final String? specialIdImage;
  final bool? isLive;
  final ImageColorEntity? imageColorEntity;

  const OwnerOfRoom({
    required this.roomName,
    required this.roomData,
    required this.introRoom,
    required this.roomImg,
    required this.specialIdImage,
    required this.imageColorEntity,
    this.isLive = false,
    super.key,
  });
  static ValueNotifier<int> isEditRoom = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180.w,
      // Two rows stack here (room name, then the ID row below it) inside a
      // fixed-height, Clip.hardEdge container -- at 48.h the two rows'
      // real rendered height (name row + icon/level badge + ID row + copy
      // icon + vertical padding) ran right up against the limit and the ID
      // row got silently clipped off the bottom on real devices, making the
      // special-id badge/ID text disappear entirely even though the data
      // and widget were both fine. 60.h gives both rows breathing room.
      height: 60.h,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: (0.25)),
        // Left corners squared off (were rounded 25 like the right side),
        // on request -- this pill sits flush at the room screen's top-left
        // edge, so only the outward-facing right corners stay rounded.
        borderRadius: BorderRadius.only(
          topLeft: Radius.zero,
          bottomLeft: Radius.zero,
          topRight: 25.radiusCircular,
          bottomRight: 25.radiusCircular,
        ),
      ),
      padding: EdgeInsets.only(
        right: 15.w,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
              key: di<RoomStateManager>().isInAudioRoom
                  ? null
                  : RoomScreenState.seatAvatarKeys[
              RoomData.instance.room.ownerId.toString()],
              decoration: BoxDecoration(
                border: Border.all(color: ColorManager.white, width: 0.4),
                borderRadius: BorderRadius.circular(25),
              ),
              child: ImageViewWidget(
                url: roomImg == ''
                    ? EndPoints.getImage(roomData.roomCover ?? "")
                    : EndPoints.getImage(roomImg),
                displayName:
                roomName == "" ? roomData.roomName ?? "" : roomName,
                height: 40.h,
                width: 40.w,
                radius: 21.r,
              ),
            ),
          ),
          Flexible(
            child: Padding(
              // Slightly tighter vertical padding avoids the tiny
              // 'BOTTOM OVERFLOWED BY 0.606 PIXELS' warning.
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Real-time lock badge: appears the instant the room is
                      // locked and disappears when unlocked (driven by the
                      // `roomPassword` broadcast / local toggle).
                      ValueListenableBuilder<bool>(
                        valueListenable: RoomData.instance.isRoomLocked,
                        builder: (context, locked, _) => locked
                            ? Padding(
                          padding: EdgeInsets.only(right: 4.w),
                          child: Icon(
                            Icons.lock,
                            size: 14.sp,
                            color: ColorManager.white,
                          ),
                        )
                            : const SizedBox.shrink(),
                      ),
                      // Room-level badge: moved here from an overlay on the
                      // cover photo, on request -- a small icon before the
                      // name instead of stamped on the avatar.
                      if (roomData.roomLevelImage != '' && !(isLive ?? true))
                        Padding(
                          padding: EdgeInsets.only(right: 4.w),
                          child: ImageViewWidget(
                            url: roomData.roomLevelImage ?? '',
                            // Wider box, no forced circle -- was a 16x16
                            // circle with BoxFit.fill, which squeezed/cropped
                            // this wider-than-tall crown+number badge. Now
                            // full width with BoxFit.contain so it shows
                            // uncropped, on request.
                            height: 16.h,
                            width: 30.w,
                            boxFit: BoxFit.contain,
                          ),
                        ),
                      Flexible(
                        // Flexible (not just a fixed-maxWidth ConstrainedBox)
                        // so this shrinks to whatever's left after the lock
                        // icon / room-level badge instead of overflowing --
                        // those two are conditional, so their combined width
                        // isn't accounted for by a flat 104.w maxWidth.
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 104.w,
                            minWidth: 10.w,
                          ),
                          child: TextScroll(
                          (roomName == "" ? roomData.roomName ?? "" : roomName)
                              .sanitizedForDisplay,
                          velocity: const Velocity(pixelsPerSecond: Offset(50, 0)),
                          pauseBetween: const Duration(milliseconds: 1000),
                          // Room name and the ID below it were the two smallest
                          // things on a busy screen; both are nudged up a step.
                          style: context.bodyMedium.copyWith(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: roomData.vip?.colorName != null &&
                                  (roomData.vip?.colorName ?? '').isNotEmpty
                                  ? Color(
                                int.parse(
                                  (roomData.vip?.colorName ?? '')
                                      .replaceFirst('#', '0xff'),
                                ),
                              )
                                  : ColorManager.white),
                          textDirection: TextDirection.ltr,
                          ),
                        ),
                      ),
                    ],
                  ),
                  IdWithCopyIcon(
                    // Left-aligned (was the default MainAxisAlignment.center)
                    // so the ID sits flush under the room name above it,
                    // instead of centered across the whole flexible width.
                    mainAxisAlignment: MainAxisAlignment.start,
                    isNeedCopyIcon: true,
                    isSpecial: (roomData.ownerSpecialId != null &&
                        roomData.ownerSpecialId?.isNotEmpty == true)
                        ? true
                        : (specialIdImage?.isNotEmpty ?? false),
                    specialImg: roomData.ownerSpecialId?.isNotEmpty == true
                        ? (roomData.ownerSpecialId ?? "")
                        : (specialIdImage ?? ''),
                    // Shorter than the shared default (20.h) -- this pill
                    // is a tight fit at the top of the room, on request.
                    specialImgHeight: 14.h,
                    color: roomData.ownerImageColor?.color?.isNotEmpty == true
                        ? (roomData.ownerImageColor?.color ?? "")
                        : imageColorEntity?.color,
                    img: roomData.ownerImageColor?.image?.isNotEmpty == true
                        ? (roomData.ownerImageColor?.image ?? "")
                        : imageColorEntity?.image,
                    idStyle: context.bodyMedium.w400
                        .colorExt(
                      Methods.safeHexColor(roomData.ownerImageColor?.color) ??
                          Methods.safeHexColor(imageColorEntity?.color) ??
                          ColorManager.white,
                    )
                        .copyWith(height: 0.1, fontSize: 12.sp),
                    userId: roomData.uuidOwnerRoom ?? '',
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}