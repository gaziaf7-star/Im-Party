import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

/// Host-only exit: ending the stream kicks every viewer, so instead of the
/// viewers' exit side panel the host gets an explicit confirmation dialog
/// (إنهاء البث المباشر — خروج / إلغاء).
Future<void> showEndLiveConfirmDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (dialogCtx) => AnimatedDialog(
      title: StringManager.endLiveTitle.tr(),
      description: StringManager.endLiveMsg.tr(),
      isUpdateDialog: true,
      conText: StringManager.exit.tr(),
      cancelText: StringManager.cancel.tr(),
      onTapCancel: () => Navigator.pop(dialogCtx),
      onTap: () async {
        Navigator.pop(dialogCtx);
        // Delist the broadcast IMMEDIATELY (is_live=0 + presence cleared)
        // so it vanishes from the live list the second the host confirms —
        // the occupancy sync / webhooks are only the fallback. Fire-and-forget:
        // a transport error must not block the local teardown.
        try {
          unawaited(RoomRemoteDataSourceImp(di()).endLive());
        } catch (_) {}
        final navContext = SafeNavigator.context;
        if (navContext == null) return;
        // Same teardown as the viewers' exit: pop back to where the host
        // came from (the lives page when the live was opened from it, else
        // the layout), then let exitRoom() tear the live session down.
        Navigator.popUntil(
          navContext,
          (route) =>
              route.settings.name == Routes.livesPage ||
              route.settings.name == Routes.layout ||
              route.isFirst,
        );
        await di<RoomStateManager>().exitRoom(navContext);
      },
    ),
  );
}
