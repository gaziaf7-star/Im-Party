import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/live_room/presentation/live_room_data.dart';
import 'package:general/src/features/room/presentation/manager/check_admin_owner_manager/check_admin_owner_bloc.dart';
import 'package:general/src/features/room/presentation/music/view/music_server_page.dart';
import 'package:general/src/features/room/presentation/room_controller.dart';
import 'package:general/src/features/room/room.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:utd_live_room_kit/utd_live_room_kit.dart' as live;

import 'package:general/src/features/room/presentation/admin_permissions/room_admin_permissions.dart';

import 'package:utd_video_effects_kit/utd_video_effects_kit.dart';
import 'live_broadcast_settings_sheet.dart';
import 'live_control_button.dart';
import 'live_share_sheet.dart';
import 'live_stream_settings_page.dart';

/// The live room's "more" bottom sheet: show settings (host), music
/// (host/admin — the audio room's synced server music), share, flip camera,
/// and beauty. Speaker/requests/members live on the main bar / header instead.
///
/// Opened from [LiveControlsBar]. The beauty sheet it launches needs a context
/// under [live.UTDRoomScope], so it keeps the caller's (scoped) context and
/// uses it after closing itself.
class LiveMoreSheet {
  static Future<void> show(BuildContext context) {
    final scope = live.UTDRoomScope.maybeOf(context);
    final controller = scope?.controller;
    if (controller == null) return Future.value();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (_) => _LiveMoreSheetBody(
        controller: controller,
        theme: scope!.theme,
        rootContext: context,
      ),
    );
  }
}

class _LiveMoreSheetBody extends StatelessWidget {
  final live.UTDRoomController controller;
  final live.UTDRoomTheme theme;

  /// The scoped controls-bar context — used to launch kit sheets (which read
  /// [live.UTDRoomScope]) after this sheet is dismissed.
  final BuildContext rootContext;

  const _LiveMoreSheetBody({
    required this.controller,
    required this.theme,
    required this.rootContext,
  });

  live.UTDRoomController get _c => controller;

  /// Same flow as the audio room's music tool: server-side admin/owner check,
  /// audio permission, then the shared synced-music page ([MusicServerPage]).
  Future<void> _openGames(BuildContext context) async {
    if (HomePage.isConnectToInternet != true) {
      Methods.showToast(
        context,
        message: StringManager.pleaseCheckInternet.tr(),
        isError: true,
      );
      return;
    }

    final String activeRoomId = RoomData.instance.room.id.toString();
    final BuildContext roomContext = rootContext;

    debugPrint('🎮 VIDEO MORE => open games room=$activeRoomId');

    // Close only the video More sheet. Use the original scoped live-room
    // context afterwards instead of SafeNavigator/navKey, because the latter
    // can point at a different Navigator in live rooms.
    Navigator.of(context).pop();
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // If another bottomDailog is still finishing, wait until its global lock
    // is released so this GamesView request cannot be silently dropped.
    for (int i = 0; i < 30 && isDialogOpen; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }

    if (!roomContext.mounted) return;

    await bottomDailog(
      context: roomContext,
      widget: GamesView(roomId: activeRoomId),
    );
  }

  void _openMusic(BuildContext context) {
    Navigator.pop(context);
    di<CheckAdminOwnerBloc>().add(
      CheckAdminOwnerEvent(
        context: rootContext,
        params: CheckAdminOwnerParam(
          roomId: RoomData.instance.room.id.toString(),
          type: 'music',
        ),
        callback: () async {
          await Methods.requestPermission(Permission.audio);
          final ctx = navKey.currentState?.context;
          if (ctx == null || !ctx.mounted) return;
          Navigator.of(
            ctx,
          ).push(MaterialPageRoute(builder: (_) => const MusicServerPage()));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.sheetBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.sheetHandle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          16.hBox,
          Wrap(
            spacing: 24.w,
            runSpacing: 16.h,
            alignment: WrapAlignment.center,
            children: _actions(context),
          ),
        ],
      ),
    );
  }

  List<Widget> _actions(BuildContext context) {
    return [
      // Broadcast settings — host only: edit the stream's name, intro and
      // cover image mid-stream.
      if (_c.isLocalHost)
        LiveControlButton(
          icon: Icons.settings_outlined,
          label: StringManager.streamSettings.tr(),
          onTap: () {
            Navigator.pop(context);
            LiveBroadcastSettingsSheet.show(rootContext);
          },
        ),
      // Live admins management — host only.
      if (_c.isLocalHost)
        LiveControlButton(
          icon: Icons.admin_panel_settings_outlined,
          label: Methods.getLang() == 'ar' ? 'المشرفين' : 'Admins',
          onTap: () {
            Navigator.pop(context);
            Navigator.of(rootContext).push(
              MaterialPageRoute(builder: (_) => const LiveStreamSettingsPage()),
            );
          },
        ),
      // Music — host/admin with the music permission.
      if (_c.isLocalHost ||
          (_c.isHostOrAdmin &&
              RoomAdminPermissions.iCan(RoomAdminPermissions.music)))
        LiveControlButton(
          icon: Icons.music_note_outlined,
          label: StringManager.music.tr(),
          onTap: () => _openMusic(context),
        ),
      // Games — visible to every user. Reuse the original in-room GamesView
      // and its existing WebView player instead of maintaining a second flow.
      LiveControlButton(
        icon: Icons.sports_esports_outlined,
        label: StringManager.games.tr(),
        onTap: () => _openGames(context),
      ),
      // Share — moved here from the header for the host (owner 2026-06-12).
      // Viewers share from the bottom bar instead.
      LiveControlButton(
        icon: Icons.share,
        label: StringManager.share.tr(),
        onTap: () {
          Navigator.pop(context);
          LiveShareSheet.open(rootContext);
        },
      ),
      // Flip camera — when the camera is on, including the host's pre-live
      // preview (switchCamera flips the preview track too).
      ValueListenableBuilder<bool>(
        valueListenable: _c.mediaController.canPublish,
        builder: (_, canPublish, __) {
          if (!canPublish) return const SizedBox.shrink();
          return AnimatedBuilder(
            animation: Listenable.merge([
              _c.mediaController.isCameraEnabled,
              _c.mediaController.isPreviewing,
            ]),
            builder: (_, __) {
              final camOn =
                  _c.mediaController.isCameraEnabled.value ||
                      _c.mediaController.isPreviewing.value;
              if (!camOn) return const SizedBox.shrink();
              return LiveControlButton(
                icon: Icons.cameraswitch_outlined,
                label: StringManager.switchCamera.tr(),
                onTap: _c.mediaController.switchCamera,
              );
            },
          );
        },
      ),
      // Beauty & filters — same visibility as flip camera (local camera on,
      // including the host's pre-live preview). Opens the effects sheet which
      // drives the session's video-effects processor.
      ValueListenableBuilder<bool>(
        valueListenable: _c.mediaController.canPublish,
        builder: (_, canPublish, __) {
          if (!canPublish) return const SizedBox.shrink();
          return AnimatedBuilder(
            animation: Listenable.merge([
              _c.mediaController.isCameraEnabled,
              _c.mediaController.isPreviewing,
            ]),
            builder: (_, __) {
              final camOn =
                  _c.mediaController.isCameraEnabled.value ||
                      _c.mediaController.isPreviewing.value;
              if (!camOn) return const SizedBox.shrink();
              return LiveControlButton(
                icon: Icons.auto_awesome,
                label: Methods.getLang() == 'ar' ? 'تجميل' : 'Beauty',
                onTap: () {
                  Navigator.pop(context);
                  VideoEffectsSheet.show(
                    rootContext,
                    processor: LiveRoomData.instance.ensureVideoEffects(),
                  );
                },
              );
            },
          );
        },
      ),
      // Members + requests intentionally NOT here: members are reachable from
      // the header's viewer strip, and the requests/apply-to-speak action moved
      // to a standalone button on the main bar next to the gift box.
    ];
  }
}
