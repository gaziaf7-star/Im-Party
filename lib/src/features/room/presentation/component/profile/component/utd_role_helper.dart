import 'package:general/src/core/index.dart';
import 'package:general/src/features/live_room/presentation/live_room_data.dart';
import 'package:general/src/features/room/data/model/user_in_room_model.dart';
import 'package:general/src/features/room/room.dart';
import 'package:general/src/features/room/presentation/admin_permissions/room_admin_permissions.dart';

/// Promotes/demotes a user via the UTD-Stream Engine role endpoint.
///
/// Owner-only (the server enforces it and returns `403` otherwise; the calling
/// menu already gates to the owner). `admin` => promote, `audience` => demote.
/// Updates [RoomData.adminsInRoom] optimistically (the broadcast `_role_change`
/// confirms shortly after), emits the localized chat system message for parity,
/// and shows a toast.

/// Promote [userData] to engine `admin`.
Future<void> promoteToAdmin(UserInRoomModel userData) => changeUserRole(
      id: userData.id?.toString() ?? '',
      name: userData.name ?? '',
      role: 'admin',
    );

/// Demote [userData] to engine `audience` (removes admin).
Future<void> demoteToAudience(UserInRoomModel userData) => changeUserRole(
      id: userData.id?.toString() ?? '',
      name: userData.name ?? '',
      role: 'audience',
    );

/// Demote by id/name — convenience for callers that only have raw values
/// (e.g. the admins-list row's delete icon).
Future<void> demoteToAudienceById(String id, String name) =>
    changeUserRole(id: id, name: name, role: 'audience');

/// Owner-only: edit an EXISTING admin's granular permissions. Opens the picker
/// pre-filled with the admin's current set, persists via update_admin_permissions
/// (the backend broadcasts updateAdmins so every client applies the new powers
/// live), and mirrors the change locally.
Future<void> editAdminPermissions(String id, String name) async {
  final ctx = navKey.currentContext;
  if (ctx == null || id.isEmpty) return;
  final roomId = RoomData.instance.room.id?.toString() ?? '';
  if (roomId.isEmpty) return;

  final current = RoomData.instance.room.adminPermissions?[id];
  final picked =
      await showAdminPermissionsPicker(ctx, adminName: name, initial: current);
  if (picked == null) return;

  try {
    await di<DioFactory>().post(
      EndPoints.updateAdminPermissions,
      data: {
        'room_id': roomId,
        'user_id': id,
        'permissions': picked.permissions,
      },
    );
    final perms = Map<String, List<String>?>.from(
        RoomData.instance.room.adminPermissions ?? const {});
    perms[id] = picked.permissions;
    RoomData.instance.room.adminPermissions = perms;
    RoomData.instance.bumpRoleVersion();
    final c = navKey.currentContext;
    if (c != null) Methods.showToast(c, message: StringManager.success.tr());
  } catch (_) {
    final c = navKey.currentContext;
    if (c != null) {
      Methods.showToast(c,
          message: StringManager.someThingWentWrong.tr(), isError: true);
    }
  }
}

Future<void> changeUserRole({
  required String id,
  required String name,
  required String role,
}) async {
  // Route to the ACTIVE room's controller — in a live (video) room the audio
  // utdController is null and the live kit exposes the same changeRole API.
  final isLive = di<RoomStateManager>().isInVideoRoom;
  final audioController = RoomData.instance.utdController;
  final liveController = LiveRoomData.instance.liveController;
  final ctx = navKey.currentContext;
  if ((isLive ? liveController : audioController) == null || id.isEmpty) {
    return;
  }

  final bool adminAfter = role == 'admin';

  // The OWNER picks this admin's powers before the assignment goes through
  // (owner spec 2026-06-11). Cancel = abort. null = all powers.
  List<String>? grantedPermissions;
  if (adminAfter &&
      ctx != null &&
      MyDataModel.getInstance().id == RoomData.instance.room.ownerId) {
    final picked = await showAdminPermissionsPicker(ctx, adminName: name);
    if (picked == null) return;
    grantedPermissions = picked.permissions;
  }

  // 1) Persist to the app backend FIRST — the DB (room_administrators) is the
  //    durable source of truth that enter_room / the admins list / the admin
  //    panel read; the engine grant below is session state only. A failed
  //    persist aborts loudly instead of silently producing an admin who
  //    evaporates on the next rejoin (owner report 2026-06-12).
  final persisted = await _persistAdminToBackend(
    userId: id,
    isAdmin: adminAfter,
    permissions: grantedPermissions,
  );
  if (!persisted) {
    if (ctx != null) {
      Methods.showToast(
        ctx,
        message: StringManager.someThingWentWrong.tr(),
        isError: true,
      );
    }
    return;
  }

  // 2) Best-effort engine role change for the CURRENT session. 409 (already
  //    in that role) and 404 (target not connected right now) are benign: the
  //    durable state is already correct and the kit's adminIdsResolver
  //    re-grants the role from enter_room's admins on the next join.
  try {
    if (isLive) {
      await liveController!.changeRole(targetIdentity: id, role: role);
    } else {
      await audioController!.changeRole(targetIdentity: id, role: role);
    }
  } on DioException catch (e) {
    final code = e.response?.statusCode;
    if (code != 409 && code != 404) {
      Methods.printLog('engine changeRole failed ($code) — backend persisted');
    }
  } catch (e) {
    Methods.printLog('engine changeRole failed: $e — backend persisted');
  }

  // Mirror the granted set locally so gates apply without a rejoin.
  final permsMap = Map<String, List<String>?>.from(
      RoomData.instance.room.adminPermissions ?? const {});
  if (adminAfter) {
    permsMap[id] = grantedPermissions;
  } else {
    permsMap.remove(id);
  }
  RoomData.instance.room.adminPermissions = permsMap;

  // Optimistic local update — the broadcast `_role_change` reconciles too.
  if (adminAfter) {
    RoomData.instance.adminsInRoom[id] = id;
  } else {
    RoomData.instance.adminsInRoom.remove(id);
  }
  RoomData.instance.bumpRoleVersion();

  // Chat system message for parity (localized in messages_view.dart).
  final message = "$name ${adminAfter ? 'BeAdMiN' : 'removedFromAdmins'}";
  final userData = {
    "img": MyDataModel.getInstance().profile?.image ?? "",
    "bu": MyDataModel.getInstance().bubble ?? "",
    "buId": MyDataModel.getInstance().bubbleId.toString(),
    "sL": MyDataModel.getInstance().level?.senderImage ?? "",
    "rL": MyDataModel.getInstance().level?.receiverImage ?? "",
    "v": MyDataModel.getInstance().vip1?.img1 ?? "",
    "c": MyDataModel.getInstance().vip1?.colorName ?? "",
    'type': 'message',
  };
  if (isLive) {
    LiveRoomData.instance.chatController
        ?.sendMessage(message, userData: userData);
  } else {
    RoomData.instance.chatController?.sendMessage(message, userData: userData);
  }

  if (ctx != null) {
    Methods.showToast(
      ctx,
      message:
          (adminAfter ? StringManager.adminAssigned : StringManager.removeAdmin)
              .tr(),
    );
  }
}

/// Persists an admin promotion/demotion to the app backend — the durable
/// source of truth that `enter_room` reads into [EnterRoomModel.admins], the
/// admins list screens fetch, and the admin panel displays. Returns whether
/// the durable state now matches the goal (so callers can abort loudly on
/// failure instead of granting a session-only admin that evaporates on the
/// next rejoin). On success the in-memory [RoomData.room.admins] is mirrored
/// so the current session stays consistent.
Future<bool> _persistAdminToBackend({
  required String userId,
  required bool isAdmin,
  List<String>? permissions,
}) async {
  // In a LIVE room the enter-room response lives in LiveRoomData; fall back
  // to the shared RoomData model (set pre-entry) before it lands.
  final roomId = (di<RoomStateManager>().isInVideoRoom
              ? (LiveRoomData.instance.roomOrNull?.id ??
                  RoomData.instance.room.id)
              : RoomData.instance.room.id)
          ?.toString() ??
      '';
  if (roomId.isEmpty || userId.isEmpty) return false;

  final dataSource = RoomRemoteDataSourceImp(di());
  var ok = false;
  try {
    if (isAdmin) {
      await dataSource.addAdminRoom(
        AddAdminParameter(
          roomId: roomId,
          userId: userId,
          permissions: permissions,
        ),
      );
    } else {
      await dataSource.removeAdmin(
        RemoveAdminParameter(roomId: roomId, userId: userId),
      );
    }
    ok = true;
  } on NetworkExceptions catch (e) {
    // Idempotent reconciliation: 444 "already an administrator" on add
    // (mapped to [TooManyRequests]) and 404 "not an administrator" on remove
    // (mapped to [NotFound]) mean the durable state already matches the goal.
    ok = (isAdmin && e is TooManyRequests) || (!isAdmin && e is NotFound);
    if (!ok) Methods.printLog('persistAdminToBackend error: $e');
  } catch (e) {
    Methods.printLog('persistAdminToBackend error: $e');
  }
  if (!ok) return false;

  // Keep the in-memory enter-room admin list in sync for this session.
  final admins = List<String>.from(RoomData.instance.room.admins ?? const []);
  if (isAdmin) {
    if (!admins.contains(userId)) admins.add(userId);
  } else {
    admins.remove(userId);
  }
  RoomData.instance.room.admins = admins;
  return true;
}
