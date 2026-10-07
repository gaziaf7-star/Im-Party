import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/data/model/user_in_room_model.dart';
import 'package:general/src/features/room/room.dart';
import 'package:general/src/features/room/presentation/admin_permissions/room_admin_permissions.dart';
import '../../../../../profile/presentation/profile/view/page/user_profile/component/report_dialog_for_users.dart';
import '../widgets/time_widget.dart';
import 'utd_ban_helper.dart';
import 'utd_mute_helper.dart';
import 'utd_role_helper.dart';

class NewProfilePermissionMenu extends StatelessWidget {
  final EnterRoomModel roomData;
  final UserInRoomModel userData;
  final bool? halfImageProfile;

  NewProfilePermissionMenu({
    super.key,
    required this.roomData,
    required this.userData,
    required this.halfImageProfile,
  });

  bool iAmAdmin = false;
  bool isAdmin = false;

  @override
  Widget build(BuildContext context) {
    bool iAmOwner = roomData.ownerId == MyDataModel.getInstance().id;
    return ValueListenableBuilder<int>(
      valueListenable: RoomData.instance.roleVersion,
      builder: (context, _, __) {
        iAmAdmin = RoomData.instance.adminsInRoom.containsKey(
          MyDataModel.getInstance().id.toString(),
        );
        // Gate moderation buttons on the ACTUAL engine role too: the live
        // `_role_change` updates adminsInRoom (so the UI flips immediately), but
        // the engine still enforces the token-baked permissions from join time.
        // Showing buttons the engine will 403 makes mute/kick/lock silently
        // fail. Only require the engine role when it is known (non-null) so we
        // never hide buttons just because the role metadata hasn't propagated.
        if (iAmAdmin && !iAmOwner) {
          final myRole = RoomData.instance.utdController?.localRole;
          if (myRole != null && myRole != 'admin' && myRole != 'host') {
            iAmAdmin = false;
          }
        }
        isAdmin = RoomData.instance.adminsInRoom.containsKey(
          userData.id.toString(),
        );
        return GestureDetector(
          onTap: () {
            Navigator.pop(context);
            final ctx = navKey.currentContext;
            if (ctx == null) return;
            showModalBottomSheet(
              context: ctx,
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
              ),
              backgroundColor: ColorManager.transparent,
              builder: (_) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ProfilePermissionOptionsSheet(
                        iAmOwner: iAmOwner,
                        iAmAdmin: iAmAdmin,
                        isAdmin: isAdmin,
                        roomData: roomData,
                        userData: userData,
                        onKick: () {
                          final ctx = navKey.currentContext;
                          if (ctx == null) return;
                          showTimeDialog(ctx, isAdmin, roomData, userData);
                        },
                        onBan: () {
                          final ctx = navKey.currentContext;
                          if (ctx == null) return;
                          showBanConfirmDialog(ctx, isAdmin, userData);
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: double.infinity,
                            height: 50.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Center(
                              child: Text(
                                StringManager.cancel.tr(),
                                style: context.bodyLarge
                                    .colorExt(ColorManager.black),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 30.h),
            // Brand-gradient tint (was the icon's own flat black, invisible
            // against the room profile's dark background) so the 3-dot menu
            // is always visible and matches the app's gradient buttons.
            child: ShaderMask(
              shaderCallback: (bounds) =>
                  ColorManager.brandGradient.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Image.asset(
                AssetsManager.infoIcon,
                width: 25.w,
                height: 25.h,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfilePermissionOptionsSheet extends StatelessWidget {
  final bool iAmOwner;
  final bool iAmAdmin;
  final bool isAdmin;
  final EnterRoomModel roomData;
  final UserInRoomModel userData;
  final VoidCallback onKick;
  final VoidCallback onBan;

  const _ProfilePermissionOptionsSheet({
    required this.iAmOwner,
    required this.iAmAdmin,
    required this.isAdmin,
    required this.roomData,
    required this.userData,
    required this.onKick,
    required this.onBan,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> options = [];

    final controller = RoomData.instance.utdController;
    final targetId = userData.id.toString();
    final onSeat = controller?.seatController.isUserOnSeat(targetId) ?? false;
    final isTargetMuted =
        controller?.mutedParticipants.value.contains(targetId) ?? false;

    // The target can be moderated when it isn't the owner or myself, and I'm the
    // owner or an admin acting on a non-admin. The two actions are then each
    // gated on their own granular power (owner passes every iCan check):
    //   - طرد (kick): timed removal, room stays in the target's home.
    //   - حظر (ban): permanent, hides the room + blocks re-entry until unbanned.
    final canTargetUser = userData.id != roomData.ownerId &&
        userData.id != MyDataModel.getInstance().id;
    final canModerateTarget = iAmOwner || (iAmAdmin && isAdmin == false);

    if (canTargetUser &&
        canModerateTarget &&
        RoomAdminPermissions.iCan(RoomAdminPermissions.kickFromRoom)) {
      options.add(_OptionTile(
        icon: AssetsManager.banFromRoom,
        label: StringManager.kick.tr(),
        onTap: () {
          Navigator.pop(context);
          onKick();
        },
      ));
    }

    if (canTargetUser &&
        canModerateTarget &&
        RoomAdminPermissions.iCan(RoomAdminPermissions.banUsers)) {
      options.add(_OptionTile(
        icon: AssetsManager.banFromRoom,
        label: StringManager.ban.tr(),
        onTap: () {
          Navigator.pop(context);
          onBan();
        },
      ));
    }

    if (onSeat &&
        userData.id != roomData.ownerId &&
        userData.id != MyDataModel.getInstance().id &&
        (iAmOwner ||
            (iAmAdmin &&
                isAdmin == false &&
                userData.id != roomData.ownerId))) {
      options.add(_OptionTile(
        icon: AssetsManager.muteUser,
        label: (isTargetMuted
                ? StringManager.unMuteUser
                : StringManager.muteUser)
            .tr(),
        onTap: () {
          toggleUtdMute(userData);
          Navigator.pop(context);
        },
      ));
    }

    if (iAmOwner && userData.id != MyDataModel.getInstance().id) {
      options.add(_OptionTile(
        icon: isAdmin ? AssetsManager.userBlock : AssetsManager.userAdmin,
        label: isAdmin
            ? StringManager.removeAdmin.tr()
            : StringManager.addAdmin.tr(),
        onTap: () async {
          // Close the sheet FIRST, then run the (async) role change. Popping
          // after an un-awaited promote raced the permissions-picker dialog and
          // it never showed (nothing happened on tap).
          Navigator.pop(context);
          if (isAdmin) {
            await demoteToAudience(userData);
          } else {
            await promoteToAdmin(userData);
          }
        },
      ));
    }

    // NOTE: account-level block (blocks DMs + broadcast view) is intentionally
    // NOT here — in-room moderation is room-scoped only (طرد kick / حظر ban).
    // Account block lives on the PERSONAL profile ("حظر المستخدم").

    options.add(_OptionTile(
      icon: AssetsManager.dangerIcon,
      label: StringManager.report.tr(),
      onTap: () {
        Navigator.pop(context);
        final reportCtx = navKey.currentContext;
        if (reportCtx == null) return;
        showModalBottomSheet(
          context: reportCtx,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
          ),
          builder: (_) => ReportDialogForUsers(userId: '${userData.id}'),
        );
      },
    ));

    List<Widget> optionsWithDividers = [];
    for (int i = 0; i < options.length; i++) {
      optionsWithDividers.add(options[i]);
      if (i < options.length - 1) {
        optionsWithDividers.add(
          const Divider(
            height: 1,
            color: ColorManager.lightGray1,
          ),
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: optionsWithDividers,
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: TextWidget(
        label,
        textAlign: TextAlign.center,
        style: context.bodyMedium.colorExt(ColorManager.black),
      ),
    );
  }
}

/// طرد (timed kick): pick a duration, then remove the user for that window.
Future<void> showTimeDialog(BuildContext context, bool? isAdmin,
    EnterRoomModel roomData, UserInRoomModel userData) async {
  String? selectedValue;

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return AnimatedDialog(
        title: StringManager.kick.tr(),
        onTap: () {
          Navigator.pop(context);
          applyUtdKick(selectedValue, userData);
        },
        child: Column(
          children: [
            if (isAdmin == true)
              const TextWidget(
                StringManager.warningRemoveAdmin,
                textAlign: TextAlign.center,
              ),
            TimeWidget(
              onSelected: (value) => selectedValue = value,
            ),
          ],
        ),
      );
    },
  );
}

/// حظر (permanent ban): confirm, then ban the user permanently from the room.
Future<void> showBanConfirmDialog(
    BuildContext context, bool? isAdmin, UserInRoomModel userData) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return AnimatedDialog(
        title: StringManager.ban.tr(),
        onTap: () {
          Navigator.pop(context);
          applyUtdBan(userData);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Column(
            children: [
              if (isAdmin == true)
                const TextWidget(
                  StringManager.warningRemoveAdmin,
                  textAlign: TextAlign.center,
                ),
              TextWidget(
                StringManager.confirmBanUser.tr(),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    },
  );
}
