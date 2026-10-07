import 'package:general/src/core/index.dart';
import 'package:general/src/features/live_room/presentation/live_room_data.dart';
import 'package:general/src/features/room/data/model/user_in_room_model.dart';
import 'package:general/src/features/room/room.dart';

/// Room moderation is handled ENTIRELY by the UTD-Stream kit/engine — there is
/// no parallel backend ban list. `controller.banUser` (room-scoped):
///   - [applyUtdKick] طرد: a TIMED ban (durationSeconds). The engine kicks the
///     target instantly (sends `_banned` to that identity only — no fan-out) and
///     blocks their re-entry until it expires; the target's kit shows the banned
///     dialog and leaves cleanly.
///   - [applyUtdBan]  حظر: a PERMANENT ban (durationSeconds = null).
/// Unban + the banned-users list are also the kit's (unbanUser /
/// UTDBanManagementSheet).

/// Timed kick. Maps a [TimeWidget] duration label to seconds.
Future<void> applyUtdKick(String? selectedValue, UserInRoomModel userData) async {
  if (selectedValue == null) return;
  final int? minutes = _labelToMinutes(selectedValue);
  if (minutes == null) return;
  await _ban(
    userData: userData,
    durationSeconds: minutes * 60,
    successMessage: StringManager.userKicked.tr(),
  );
}

/// Permanent ban (no expiry).
Future<void> applyUtdBan(UserInRoomModel userData) async {
  await _ban(
    userData: userData,
    durationSeconds: null,
    successMessage: StringManager.userBanned.tr(),
  );
}

int? _labelToMinutes(String value) {
  if (value == StringManager.oneMin.tr()) return 1;
  if (value == StringManager.threeMin.tr()) return 3;
  if (value == StringManager.tenMin.tr()) return 10;
  if (value == StringManager.thirtyMin.tr()) return 30;
  if (value == StringManager.sixtyMin.tr()) return 60;
  if (value == StringManager.twenyFourMin.tr()) return 1440;
  return null;
}

/// Single kit-only apply path, routed to the ACTIVE room controller (live vs
/// audio). The engine is the sole source of truth — it targets only the banned
/// identity and enforces re-entry, so no backend call/realtime message is needed.
Future<void> _ban({
  required UserInRoomModel userData,
  required int? durationSeconds,
  required String successMessage,
}) async {
  final isLive = di<RoomStateManager>().isInVideoRoom;
  final id = userData.id.toString();
  bool ok = false;
  try {
    if (isLive) {
      final c = LiveRoomData.instance.liveController;
      if (c == null) return;
      ok = await c.banUser(id, durationSeconds: durationSeconds);
    } else {
      final c = RoomData.instance.utdController;
      if (c == null) return;
      ok = await c.banUser(id, durationSeconds: durationSeconds);
    }
  } catch (e) {
    Methods.printLog('kit banUser failed: $e');
  }

  final ctx = navKey.currentContext;
  if (ctx != null) {
    Methods.showToast(
      ctx,
      message: ok ? successMessage : StringManager.someThingWentWrong.tr(),
      isError: !ok,
    );
  }
}
