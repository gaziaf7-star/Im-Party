import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

/// Opens a room/live shared into a chat (the `share_room:` card tap), handling
/// every in-room case: restore the same room if minimized, no-op if already
/// inside it, or exit the current room first and then enter the shared one.
/// RoomHandlerScreen resolves the room and routes live vs audio by streamType.
///
/// Single source of truth for both the DM share card and the group-chat live
/// card.
Future<void> openSharedRoomFromChat(String id) async {
  final navContext = SafeNavigator.context;
  if (navContext == null) return;
  if (di<RoomStateManager>().isInRoom) {
    if (RoomData.instance.room.id.toString() == id) {
      final utdCtrl = RoomData.instance.utdController;
      if (utdCtrl != null && utdCtrl.minimize.isMinimizing) {
        utdCtrl.minimize.restoreWithNavigator();
        return;
      }
      // A minimized live room: navigate back into it.
      if (di<RoomStateManager>().currentState == RoomStateType.videoMinimized) {
        Navigator.pushNamed(
          navContext,
          Routes.roomScreen,
          arguments: RoomParameter(
            myDataModel: MyDataModel.getInstance(),
            isLocked: true,
            isHost: MyDataModel.getInstance().id.toString() ==
                RoomData.instance.room.ownerId.toString(),
            roomId: RoomData.instance.room.id.toString(),
            ownerId: RoomData.instance.room.ownerId.toString(),
          ),
        );
      }
      return;
    }
    await di<RoomStateManager>().exitRoom(
      navContext,
      callback: () {
        final cbContext = SafeNavigator.context;
        if (cbContext == null) return;
        if (NavObserver.currentRoute.value == Routes.roomScreen ||
            NavObserver.currentRoute.value == Routes.liveRoomScreen) {
          Navigator.popUntil(
            cbContext,
            (route) => route.settings.name == Routes.layout,
          );
        }
        Navigator.pushNamed(
          cbContext,
          Routes.roomHandlerScreen,
          arguments: id,
        );
      },
    );
    return;
  }
  Navigator.pushNamed(
    navContext,
    Routes.roomHandlerScreen,
    arguments: id,
  );
}
