import 'package:general/src/core/index.dart';
import 'package:general/src/features/live_room/presentation/live_room_data.dart';
import 'package:general/src/features/room/data/model/user_in_room_model.dart';
import 'package:general/src/features/room/room.dart';

/// Toggles the server-side microphone mute for [userData] via the ACTIVE room's
/// seat controller (audio OR live).
///
/// Mutes if the target is currently unmuted, unmutes otherwise. The target
/// stays on their seat — this is a mic mute, not a kick. No-op if the user is
/// not on a seat. Gating to host/admin is handled by the calling menu.
Future<void> toggleUtdMute(UserInRoomModel userData) async {
  // Route to the ACTIVE controller — in a LIVE broadcast the audio utdController
  // is null, so the previous code returned here and mute silently did nothing.
  final isLive = di<RoomStateManager>().isInVideoRoom;
  final userId = userData.id.toString();
  final actor = MyDataModel.getInstance().id.toString();
  final ctx = navKey.currentContext;

  bool ok = false;
  final isMuted =
      (isLive
              ? LiveRoomData.instance.liveController?.mutedParticipants.value
              : RoomData.instance.utdController?.mutedParticipants.value)
          ?.contains(userId) ??
      false;
  if (isLive) {
    final c = LiveRoomData.instance.liveController;
    if (c == null) return;
    final seatIndex = c.seatController.getSeatIndexByUserId(userId);
    if (seatIndex < 0) return; // not on a seat -> no mic to mute
    // Live kit uses setRemoteMicEnabled (engine API) not seatController mute
    ok = await c.setRemoteMicEnabled(userId, isMuted);
  } else {
    final c = RoomData.instance.utdController;
    if (c == null) return;
    final seatIndex = c.seatController.getSeatIndexByUserId(userId);
    if (seatIndex < 0) return;
    ok =
        isMuted
            ? await c.seatController.unmuteSeat(seatIndex, identity: actor)
            : await c.seatController.muteSeat(seatIndex, identity: actor);
  }

  if (ctx != null) {
    Methods.showToast(
      ctx,
      message:
          ok
              ? (isMuted ? StringManager.userUnmuted : StringManager.userMuted)
                  .tr()
              : StringManager.someThingWentWrong.tr(),
      isError: !ok,
    );
  }
}
