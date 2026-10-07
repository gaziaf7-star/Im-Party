import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/data/model/user_in_room_model.dart';
import 'package:general/src/features/room/room.dart';
import 'package:general/src/features/room/presentation/admin_permissions/room_admin_permissions.dart';
import '../../../../../profile/presentation/profile/view/page/user_profile/component/report_dialog_for_users.dart';
import '../widgets/time_widget.dart';
import 'utd_ban_helper.dart';
import 'utd_mute_helper.dart';
import 'utd_role_helper.dart';

class ProfilePermissionMenu extends StatelessWidget {
  final EnterRoomModel roomData;
  final UserInRoomModel userData;
  final bool? halfImageProfile;

  ProfilePermissionMenu({
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
        final controller = RoomData.instance.utdController;
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
          final myRole = controller?.localRole;
          if (myRole != null && myRole != 'admin' && myRole != 'host') {
            iAmAdmin = false;
          }
        }
        isAdmin = RoomData.instance.adminsInRoom.containsKey(
          userData.id.toString(),
        );
        final targetId = userData.id.toString();
        final onSeat =
            controller?.seatController.isUserOnSeat(targetId) ?? false;
        final isTargetMuted =
            controller?.mutedParticipants.value.contains(targetId) ?? false;
        return PopupMenuButton<int>(
          // Brand-gradient glyph (was a flat ColorManager.textPrimary glyph
          // that resolves near-black, invisible on the room profile's dark
          // background) so the 3-dot menu is always visible and matches
          // every other gradient button in the app.
          icon: ShaderMask(
            shaderCallback: (bounds) =>
                ColorManager.brandGradient.createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: Icon(
              Icons.more_horiz,
              size: 30.sp,
              color: Colors.white,
            ),
          ),
          onSelected: (value) async {
            if (value == 1) {
              showTimeDialog(context, isAdmin);
            } else if (value == 3) {
              showBanConfirmDialog(context, isAdmin);
            } else if ((value == 2)) {
              toggleUtdMute(userData);
              context.popRoute();
            } else if ((value == 4)) {
              // Close the menu route FIRST, then run the async role change so
              // the permissions-picker dialog (shown via navKey.currentContext)
              // isn't raced away by the pop.
              context.popRoute();
              if (isAdmin) {
                await demoteToAudience(userData);
              } else {
                await promoteToAdmin(userData);
              }
            } else if (value == 5) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20.r)),
                ),
                builder: (_) => ReportDialogForUsers(userId: '${userData.id}'),
              );
            }
            // Mention (يذكر) moved OUT of this menu to a dedicated "@" button
            // next to "send gift" in the profile body.
          },
          itemBuilder: (context) => [
            // طرد (timed kick) — gated on the kick_from_room power.
            if ((userData.id != roomData.ownerId &&
                    userData.id != MyDataModel.getInstance().id) &&
                (iAmOwner || (iAmAdmin && isAdmin == false)) &&
                RoomAdminPermissions.iCan(RoomAdminPermissions.kickFromRoom))
              PopupMenuItem(
                value: 1,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        AssetsManager.banFromRoom,
                        height: 20.w,
                        width: 20.w,
                        color: ColorManager.iconColor,
                      ),
                      5.wBox,
                      TextWidget(
                        StringManager.kick.tr(),
                        textAlign: TextAlign.center,
                        style: context.bodyMedium
                            .colorExt(ColorManager.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            // حظر (permanent ban) — gated on the ban_users power.
            if ((userData.id != roomData.ownerId &&
                    userData.id != MyDataModel.getInstance().id) &&
                (iAmOwner || (iAmAdmin && isAdmin == false)) &&
                RoomAdminPermissions.iCan(RoomAdminPermissions.banUsers))
              PopupMenuItem(
                value: 3,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        AssetsManager.banFromRoom,
                        height: 20.w,
                        width: 20.w,
                        color: ColorManager.iconColor,
                      ),
                      5.wBox,
                      TextWidget(
                        StringManager.ban.tr(),
                        textAlign: TextAlign.center,
                        style: context.bodyMedium
                            .colorExt(ColorManager.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            if (onSeat &&
                userData.id != roomData.ownerId &&
                userData.id != MyDataModel.getInstance().id &&
                (iAmOwner ||
                    (iAmAdmin &&
                        isAdmin == false &&
                        userData.id != roomData.ownerId)))
              PopupMenuItem(
                value: 2,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        AssetsManager.muteUser,
                        height: 20.w,
                        width: 20.w,
                        color: ColorManager.iconColor,
                      ),
                      5.wBox,
                      TextWidget(
                        (isTargetMuted
                                ? StringManager.unMuteUser
                                : StringManager.muteUser)
                            .tr(),
                        textAlign: TextAlign.center,
                        style: context.bodyMedium
                            .colorExt(ColorManager.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            if (iAmOwner && userData.id != MyDataModel.getInstance().id)
              PopupMenuItem(
                value: 4,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        isAdmin
                            ? AssetsManager.userBlock
                            : AssetsManager.userAdmin,
                        height: 20.w,
                        width: 20.w,
                        color: ColorManager.iconColor,
                      ),
                      5.wBox,
                      TextWidget(
                        isAdmin
                            ? StringManager.removeAdmin.tr()
                            : StringManager.addAdmin.tr(),
                        textAlign: TextAlign.center,
                        style: context.bodyMedium
                            .colorExt(ColorManager.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            // NOTE: account-level block is NOT here — in-room moderation is
            // room-scoped only (طرد/حظر). Account block is on the personal
            // profile ("حظر المستخدم").
            PopupMenuItem(
              value: 5,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      AssetsManager.dangerIcon,
                      height: 20.w,
                      width: 20.w,
                      color: ColorManager.iconColor,
                    ),
                    5.wBox,
                    TextWidget(
                      StringManager.report.tr(),
                      textAlign: TextAlign.center,
                      style:
                          context.bodyMedium.colorExt(ColorManager.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ],
          offset: const Offset(50, 30),
          shape: RoundedRectangleBorder(
            borderRadius: 6.radius,
          ),
          // Opaque themed surface (was a translucent black that looked broken).
          color: ColorManager.surfaceCardColor,
          elevation: 4,
        );
      },
    );
  }

  /// طرد (timed kick): pick a duration then remove the user for that window.
  Future<void> showTimeDialog(BuildContext context, bool? isAdmin) async {
    String? selectedValue;

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return AnimatedDialog(
          title: StringManager.kick.tr(),
          onTap: () {
            Navigator.pop(context);
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

  /// حظر (permanent ban): confirm then ban the user permanently from the room.
  Future<void> showBanConfirmDialog(BuildContext context, bool? isAdmin) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return AnimatedDialog(
          title: StringManager.ban.tr(),
          onTap: () {
            Navigator.pop(context);
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
}
