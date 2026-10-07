import 'package:general/src/core/index.dart';
import 'package:general/src/core/utils/mic_background_helper.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/room/presentation/invite_to_mic/invite_to_mic_screen.dart';
import 'package:general/src/features/room/room.dart';
import 'package:general/src/features/room/presentation/admin_permissions/room_admin_permissions.dart';

/// Shows seat options bottom sheet based on seat state and user role.
///
/// All seat availability logic is driven by [UTDSeatController] in the
/// `utd_audio_room_kit` package — the single source of truth synced via
/// `_seat_update` data messages and room metadata `_seats`.
void showSeatOptionsSheet(
  BuildContext context,
  int index,
  UTDParticipant? user,
) {
  final controller = RoomData.instance.utdController;
  final seatController = controller?.seatController;
  final isHost = MyDataModel.getInstance().id == RoomData.instance.room.ownerId;
  bool isAdmin = RoomData.instance.adminsInRoom.containsValue(
    MyDataModel.getInstance().id.toString(),
  );
  // Gate seat lock/unlock on the ACTUAL engine role too: the live `_role_change`
  // updates adminsInRoom immediately, but the engine still enforces the
  // token-baked permissions from join time, so a freshly-promoted admin's
  // lock/unlock would 403. Only require the engine role when it is known.
  if (isAdmin && !isHost) {
    final myRole = controller?.localRole;
    if (myRole != null && myRole != 'admin' && myRole != 'host') {
      isAdmin = false;
    }
  }
  final myUserId = MyDataModel.getInstance().id.toString();
  final isSeatEmpty = user == null || user.id.isEmpty;

  // Read seat state from the package (source of truth from backend)
  final isLocked = seatController?.isSeatLocked(index) ?? false;

  // Check if current user is on any seat
  final mySeatIndex =
      seatController?.getSeatIndexByUserId(myUserId) ?? -1;
  final isOnSeat = mySeatIndex >= 0;

  // Check if clicked seat is the user's own seat
  final isMyOwnSeat = !isSeatEmpty && user.id == myUserId;

  // Someone else's seat: the sheet would only offer "view details", so skip
  // the intermediate sheet and open the room profile directly. Moderation
  // actions (mute/kick/roles) already live inside UserRoomProfile.
  if (!isSeatEmpty && !isMyOwnSeat) {
    final navCtx = navKey.currentContext;
    if (navCtx == null) return;
    bottomDailog(
      context: navCtx,
      widget: UserRoomProfile(
        userId: user.id,
        roomData: RoomData.instance.room,
      ),
    );
    return;
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: ColorManager.transparent,
    builder: (ctx) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          // Fixed white (was the panel-driven surfaceCardColor, which is
          // dark in this app's theme) — matches the professional white
          // look used across the app.
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: ColorManager.grey,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            20.hBox,

            // ── Case 1: Empty seat + host/admin ──
            if (isSeatEmpty && (isHost || isAdmin)) ...[
              // Lock / Unlock — granular admin gate (owner picks per admin).
              if (isHost ||
                  RoomAdminPermissions.iCan(RoomAdminPermissions.lockSeats))
              _buildSheetOption(
                title: isLocked
                    ? StringManager.unLockSeat.tr()
                    : StringManager.lockSeat.tr(),
                onTap: () async {
                  Navigator.pop(ctx);
                  final controller = RoomData.instance.utdController;
                  if (controller == null) return;
                  // These return false (never throw) when the backend rejects
                  // the lock/unlock — surface that instead of failing silently.
                  final ok = isLocked
                      ? await controller.seatController
                          .unlockSeat(index, identity: myUserId)
                      : await controller.seatController
                          .lockSeat(index, identity: myUserId);
                  if (!ok && context.mounted) {
                    Methods.showToast(context,
                        message: StringManager.someThingWentWrong.tr(),
                        isError: true);
                  }
                },
              ),

              // Invite user (allowed even if seat is locked — host privilege)
              if (isHost ||
                  RoomAdminPermissions.iCan(RoomAdminPermissions.inviteToMic))
              _buildSheetOption(
                title: StringManager.invitationToMic.tr(),
                onTap: () {
                  Navigator.pop(ctx);
                  bottomDailog(
                    context: context,
                    widget: SelectUserToMicDialog(
                      roomOwnerId: RoomData.instance.room.ownerId ?? 0,
                      seatIndex: index.toString(),
                    ),
                  );
                },
              ),

              // Take / Switch seat
              _buildSheetOption(
                title: isOnSeat
                    ? StringManager.switchSeat.tr()
                    : StringManager.takeOnSeat.tr(),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _takeSeat(index, myUserId, context);
                },
              ),
            ]

            // ── Case 2: Empty seat + regular user (any unlocked seat) ──
            // Show "take seat" for any empty, unlocked seat regardless of the
            // locally-synced seat list (it may be empty before backend seat
            // state loads). _takeSeat hits the backend, which enforces the real
            // rules and surfaces the specific reason (e.g. request-mode 403).
            else if (isSeatEmpty && !isHost && !isLocked) ...[
              if (isOnSeat)
                _buildSheetOption(
                  title: StringManager.switchSeat.tr(),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _takeSeat(index, myUserId, context);
                  },
                )
              else
                _buildSheetOption(
                  title: StringManager.takeOnSeat.tr(),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _takeSeat(index, myUserId, context);
                  },
                ),
            ]

            // ── Case 3: Own seat (host or guest) ──
            else if (isMyOwnSeat) ...[
              _buildSheetOption(
                title: StringManager.leaveSeat.tr(),
                onTap: () async {
                  Navigator.pop(ctx);
                  final controller = RoomData.instance.utdController;
                  if (controller == null) return;
                  // leaveSeat returns false on rejection (the published kit no
                  // longer throws). Surface a generic failure toast.
                  final ok =
                      await controller.seatController.leaveSeat(myUserId);
                  if (!ok && context.mounted) {
                    Methods.showToast(context,
                        message: StringManager.someThingWentWrong.tr(),
                        isError: true);
                  }
                },
              ),
              _buildSheetOption(
                title: StringManager.showDetails.tr(),
                onTap: () {
                  Navigator.pop(ctx);
                  final navCtx = navKey.currentContext;
                  if (navCtx == null) return;
                  bottomDailog(
                    context: navCtx,
                    widget: UserRoomProfile(
                      userId: user.id,
                      roomData: RoomData.instance.room,
                    ),
                  );
                },
              ),
            ],
            // (Occupied-by-someone-else opens UserRoomProfile directly above —
            // no sheet.)

            // Cancel
            _buildSheetOption(
              title: StringManager.cancel.tr(),
              onTap: () => Navigator.pop(ctx),
              showDivider: false,
            ),
            10.hBox,
          ],
        ),
      );
    },
  );
}

Future<void> _takeSeat(int index, String userId, BuildContext context) async {
  final controller = RoomData.instance.utdController;
  if (controller == null) return;

  final currentSeatIndex =
      controller.seatController.getSeatIndexByUserId(userId);
  final isAlreadySeated = currentSeatIndex >= 0;

  // takeSeat/moveSeat return false when the engine rejects the request (the
  // published kit no longer throws). In a request-mode room a direct take is
  // not allowed — the user must be approved by the host — so route a failed
  // take through the speaker-request flow instead of dead-ending on an error
  // toast. Do NOT enable the mic for a seat we never got.
  final ok = isAlreadySeated
      ? await controller.seatController.moveSeat(userId, index)
      : await controller.seatController.takeSeat(index, userId);

  if (!ok) {
    if (controller.seatController.seatMode.value == 'request') {
      // Name the seat that was tapped. Without it the host's approval dropped
      // the user on the first free tile, so two people tapping two different
      // seats could both be sent to the same one.
      final res = await controller.requestToSpeak(seatIndex: index);
      if (context.mounted) {
        Methods.showToast(context,
            message: res != null
                ? StringManager.micRequestSent.tr()
                : StringManager.couldNotTakeSeat.tr(),
            isError: res == null);
      }
      return;
    }
    if (context.mounted) {
      Methods.showToast(context,
          message: StringManager.couldNotTakeSeat.tr(), isError: true);
    }
    return;
  }

  // The seat is now occupied via the backend. Publishing audio additionally
  // requires the realtime stream — when it failed to connect, the user is still
  // PRESENT on the seat but cannot publish. Skip the mic publish (and its
  // permission/background prompt) so we don't try to push a track through a dead
  // engine; the controls bar already hides the mic toggle in that state.
  if (!controller.isConnected) return;

  final navContext = SafeNavigator.context;
  if (navContext == null) return;
  await MicBackgroundHelper.showMicBackgroundDialogIfNeeded(
    navContext,
  );
  Future.delayed(const Duration(milliseconds: 500), () async {
    // Enabling the mic publishes a track through the realtime engine, which can
    // throw (TrackPublishException / NegotiationError / TimeoutException) when
    // the media server is unreachable. This runs detached in a delayed callback,
    // so an unhandled throw would escape to the zone guard and be logged as a
    // crash — guard it and record non-fatal instead.
    try {
      await controller.mediaController
          .setMicrophoneEnabled(RoomData.instance.cachedMicState);
    } catch (e, s) {
      Methods.recordNonFatal(e, s,
          reason: 'seat_options_sheet.setMicrophoneEnabled');
    }
  });
}

Widget _buildSheetOption({
  required String title,
  required VoidCallback onTap,
  bool showDivider = true,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                // Fixed black (was the theme-adaptive textPrimary) now that
                // the sheet itself is forced white above.
                color: ColorManager.momentPostTextColor,
              ),
            ),
          ),
        ),
      ),
      if (showDivider)
        Divider(
          height: 1,
          thickness: 0.5,
          color: ColorManager.grey.withValues(alpha: 0.3),
        ),
    ],
  );
}
