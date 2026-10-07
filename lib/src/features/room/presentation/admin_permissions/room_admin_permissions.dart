import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

/// The complete inventory of admin powers in rooms AND lives (owner spec
/// 2026-06-11). The owner picks a subset when assigning an admin; a null
/// stored set means ALL powers (legacy admins / "select all").
class RoomAdminPermissions {
  const RoomAdminPermissions._();

  static const String removeFromMic = 'remove_from_mic';
  static const String muteUsers = 'mute_users';
  static const String lockSeats = 'lock_seats';
  static const String kickFromRoom = 'kick_from_room';
  static const String banUsers = 'ban_users';
  static const String music = 'music';
  static const String manageRequests = 'manage_requests';
  static const String manageChat = 'manage_chat';
  static const String inviteToMic = 'invite_to_mic';

  /// (key, Arabic label, English label, icon)
  static const List<(String, String, String, IconData)> all = [
    (removeFromMic, 'إنزال من المايك/الجست', 'Remove from mic/stage',
        Icons.mic_off),
    (muteUsers, 'كتم المستخدمين', 'Mute users', Icons.volume_off_outlined),
    (lockSeats, 'قفل وفتح الكراسي', 'Lock/unlock seats', Icons.lock_outline),
    (kickFromRoom, 'طرد من الغرفة/البث', 'Kick from room/broadcast',
        Icons.person_remove_outlined),
    (banUsers, 'حظر المستخدمين', 'Ban users', Icons.block),
    (music, 'تشغيل الموسيقى', 'Play music', Icons.music_note_outlined),
    (manageRequests, 'إدارة طلبات المايك/الجست', 'Manage requests',
        Icons.person_add),
    (manageChat, 'إدارة التعليقات', 'Manage chat', Icons.chat_bubble_outline),
    (inviteToMic, 'الدعوة للمايك/الجست', 'Invite to mic/stage',
        Icons.person_add_alt_1_outlined),
  ];

  /// Whether [userId] (an assigned admin) may perform [permission] in the
  /// CURRENT room. The room owner can always do everything; non-admins can't.
  static bool adminCan(String userId, String permission) {
    final room = RoomData.instance.room;
    if (room.ownerId?.toString() == userId) return true;
    if (!RoomData.instance.adminsInRoom.containsKey(userId)) return false;
    final perms = room.adminPermissions?[userId];
    // Absent entry / null = ALL powers (legacy admins).
    return perms == null || perms.contains(permission);
  }

  /// Whether the LOCAL user may perform [permission] here.
  static bool iCan(String permission) =>
      adminCan(MyDataModel.getInstance().id?.toString() ?? '', permission);
}

/// Permission picker shown when the owner assigns (or edits) an admin.
/// Returns the selected keys, or null for "ALL powers", or no result (user
/// cancelled — caller aborts the assignment).
Future<({List<String>? permissions})?> showAdminPermissionsPicker(
  BuildContext context, {
  required String adminName,
  List<String>? initial,
}) {
  return showDialog<({List<String>? permissions})>(
    context: context,
    builder: (dialogCtx) =>
        _PermissionsDialog(adminName: adminName, initial: initial),
  );
}

class _PermissionsDialog extends StatefulWidget {
  final String adminName;
  final List<String>? initial;
  const _PermissionsDialog({required this.adminName, this.initial});

  @override
  State<_PermissionsDialog> createState() => _PermissionsDialogState();
}

class _PermissionsDialogState extends State<_PermissionsDialog> {
  late final Set<String> _selected = {
    ...(widget.initial ?? RoomAdminPermissions.all.map((p) => p.$1)),
  };

  bool get _all => _selected.length == RoomAdminPermissions.all.length;

  @override
  Widget build(BuildContext context) {
    final ar = Methods.getLang() == 'ar';
    return AlertDialog(
      backgroundColor: ColorManager.surfaceCardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      title: Text(
        ar
            ? 'صلاحيات المشرف «${widget.adminName}»'
            : 'Admin permissions — "${widget.adminName}"',
        style: context.bodyLarge.w700.colorExt(ColorManager.textPrimary).size(15),
        textAlign: TextAlign.center,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                dense: true,
                activeThumbColor: ColorManager.primary,
                title: Text(ar ? 'كل الصلاحيات' : 'All permissions',
                    style: context.bodyMedium.w600
                        .colorExt(ColorManager.textPrimary)),
                // Convenience: select-all / clear-all. Individual rows stay
                // editable either way.
                value: _all,
                onChanged: (v) => setState(() {
                  _selected.clear();
                  if (v) {
                    _selected.addAll(RoomAdminPermissions.all.map((p) => p.$1));
                  }
                }),
              ),
              Divider(
                  color: ColorManager.secondaryText.withValues(alpha: 0.2),
                  height: 1),
              for (final p in RoomAdminPermissions.all)
                CheckboxListTile(
                  dense: true,
                  activeColor: ColorManager.primary,
                  controlAffinity: ListTileControlAffinity.leading,
                  secondary:
                      Icon(p.$4, color: ColorManager.iconColor, size: 18.sp),
                  title: Text(ar ? p.$2 : p.$3,
                      style: context.bodySmall
                          .colorExt(ColorManager.textPrimary)
                          .size(12.5)),
                  // Always editable — toggling any row updates the set (and the
                  // "All" switch reflects it automatically).
                  value: _selected.contains(p.$1),
                  onChanged: (v) => setState(() =>
                      v == true ? _selected.add(p.$1) : _selected.remove(p.$1)),
                ),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(StringManager.cancel.tr(),
              style: context.bodyMedium.colorExt(ColorManager.secondaryText)),
        ),
        // Filled button so "Save" is always visible — the plain primary-on-
        // surface text was invisible when the theme's primary ≈ card color.
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: ColorManager.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r)),
            padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 8.h),
          ),
          onPressed: () => Navigator.pop(
            context,
            (permissions: _all ? null : _selected.toList()),
          ),
          child: Text(StringManager.save.tr(),
              style:
                  context.bodyMedium.w700.colorExt(ColorManager.buttonTextColor)),
        ),
      ],
    );
  }
}
