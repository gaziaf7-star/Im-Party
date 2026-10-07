import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/core/widgets/show_svga.dart';
import 'package:general/src/features/live_room/presentation/component/gifts/live_gift.dart';
import 'package:general/src/features/live_room/presentation/live_room_data.dart';
import 'package:general/src/features/room/presentation/manager/room_handler_manager/room_handler_bloc.dart';
import 'package:general/src/features/room/presentation/manager/room_handler_manager/room_handler_events.dart';
import 'package:general/src/features/room/presentation/room_controller.dart';

/// Opens the live room's OWN gift sheet ([LiveGiftScreen]) — independent of the
/// audio room's gift box. Recipients (host + on-stage guests) are resolved
/// inside the sheet's own picker from the live controller, and sends broadcast
/// on the live channel.
void openLiveGiftScreen(BuildContext context) {
  // The full model comes from the enter-room response; until it lands, fall
  // back to the seed RoomStateManager always writes before navigation
  // (id/ownerId/giftPrice — enough for the sheet). The non-null getter threw
  // here, leaving a silent dead button. Also re-fire enter-room so the full
  // model recovers if the first call was lost.
  final liveRoom = LiveRoomData.instance.roomOrNull;
  if (liveRoom == null) {
    final roomId = LiveRoomData.instance.liveController?.seatController.roomId;
    if (roomId != null && roomId.isNotEmpty) {
      di<RoomHandlerBloc>().add(
        EnterRoomEvent(context, isVip: 0, roomId: roomId, roomPassword: ""),
      );
    }
  }
  final room = liveRoom ?? RoomData.instance.room;
  bottomDailog(
    context: context,
    barrierColor: ColorManager.transparent,
    widget: LiveGiftScreen(
      roomData: room,
      myDataModel: MyDataModel.getInstance(),
    ),
  );
}

/// The live room's gift button (SVGA gift icon) for the bottom bar.
class LiveGiftButton extends StatelessWidget {
  const LiveGiftButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => openLiveGiftScreen(context),
      child:
          ConstantsManager.isTheme1
              ? ShowSVGA(
                svgaAssetPath: AssetsManager.giftIconNew,
                width: 50.w,
                height: 50.h,
                fit: BoxFit.cover,
              )
              : ShowSVGA(
                svgaAssetPath: AssetsManager.giftIconAudio,
                width: 44.w,
                height: 44.h,
              ),
    );
  }
}
