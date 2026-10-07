import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

import '../room_message_processor.dart';

/// Handles room-state RTM messages: mode changes, background updates,
/// admin list changes, comment locks, seat locks, room bans/deletions.
class RoomStateMessageHandler {
  final bool isHost;
  final String roomId;

  const RoomStateMessageHandler({
    required this.isHost,
    required this.roomId,
  });

  void handle(CategorizedMessage msg, BuildContext? context) {
    final result = msg.payload;

    switch (msg.messageType) {
      case roomModeKey:
        // handleRoomModeChange(
        //   result: result,
        //   isHost: isHost,
        // );
        break;

      case changeBackground:
        changeBackgroundRoom(result, RoomData.instance.roomDataUpdates);
        break;

      case removeChatKey:
        RoomData.instance.chatController?.clearMessages();
        break;

      // Backend broadcasts "updateAdmins" after add/remove admin. This handler was
      // removed (assuming engine-driven `_role_change`), but that engine grant is
      // best-effort from the owner's device only — so promotions never reached the
      // promoted user or other viewers. Re-apply the authoritative backend list to
      // every client so role-gated UI updates in real time.
      case "updateAdmins":
        try {
          final raw = result[messageContent]['admins'];
          final ids = <String>[];
          if (raw is List) {
            for (final e in raw) {
              if (e is Map) {
                final v = e['user_id'] ?? e['id'] ?? e['uid'];
                if (v != null && v.toString().isNotEmpty) ids.add(v.toString());
              } else if (e != null && e.toString().isNotEmpty) {
                ids.add(e.toString());
              }
            }
          }
          RoomData.instance.adminsInRoom
            ..clear()
            ..addEntries(ids.map((id) => MapEntry(id, id)));
          // Merge per-admin permissions so granular powers apply live (null/absent
          // entry = ALL powers). Without this a restricted admin silently kept all
          // powers on every other client until a rejoin.
          final permsRaw = result[messageContent]['admin_permissions'];
          if (permsRaw is Map) {
            final perms = <String, List<String>?>{};
            permsRaw.forEach((k, v) {
              perms[k.toString()] =
                  (v is List) ? v.map((e) => e.toString()).toList() : null;
            });
            RoomData.instance.room.adminPermissions = perms;
          }
          RoomData.instance.bumpRoleVersion();
        } catch (_) {}
        break;

      case "isCommentsClosed":
        RoomData.instance.isCommentsClosed.value =
            result[messageContent]['value'];
        break;

      // Real-time room lock/unlock — flip the header lock badge for everyone.
      case "roomPassword":
        final v = result[messageContent]['value'] == true;
        RoomData.instance.isRoomLocked.value = v;
        break;

      case "lock_seat":
        // Seat lock state is now managed entirely by the package
        // (UTDSeatController) via _seat_update / room metadata.
        // No manual toggle needed — the backend pushes _seat_update
        // automatically after every lock/unlock API call.
        break;

      case "banRoom":
        _handleBanRoom(result, context);
        break;

      case "deletedRoom":
        _handleDeletedRoom(result, context);
        break;
    }
  }

  Future<void> _handleBanRoom(
    Map<String, dynamic> result,
    BuildContext? context,
  ) async {
    if (result[messageContent]['roomId'].toString() == roomId &&
        context != null) {
      await di<RoomStateManager>().exitRoom(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.popUntil(
            context, (route) => route.settings.name == Routes.layout);
      });
    }
  }

  Future<void> _handleDeletedRoom(
    Map<String, dynamic> result,
    BuildContext? context,
  ) async {
    if (context == null) return;
    await di<RoomStateManager>().exitRoom(
      context,
      callback: () {
        Navigator.popUntil(
            context, (route) => route.settings.name == Routes.layout);
        showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: ColorManager.transparent,
              contentPadding: EdgeInsets.zero,
              content: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  height: 50.h,
                  width: 200.w,
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: ColorManager.redIcons,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      StringManager.roomDeleted.tr(),
                      style: TextStyle(color: ColorManager.textPrimary),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
