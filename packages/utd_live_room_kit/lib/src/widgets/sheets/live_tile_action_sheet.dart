import 'package:flutter/material.dart';

import '../../controller/utd_room_controller.dart';
import '../../models/seat_model.dart';
import '../../theme/utd_room_scope.dart';
import 'utd_sheet.dart';

/// Per-tile actions for a live room, opened by tapping a guest tile.
///
/// - Tapping your OWN tile: flip your camera.
/// - Host/admin tapping a guest tile: force the guest's camera/mic on/off
///   (server-authoritative) and remove the guest from the stage.
/// - Audience tapping a tile: informational only (the occupant's name).
class UTDLiveTileActionSheet {
  static Future<void> show(
    BuildContext context, {
    required UTDRoomController controller,
    required SeatState seat,
  }) {
    return showUTDRoomSheet<void>(
      context,
      builder: (_) => _TileActions(controller: controller, seat: seat),
    );
  }
}

class _TileActions extends StatelessWidget {
  final UTDRoomController controller;
  final SeatState seat;

  const _TileActions({required this.controller, required this.seat});

  @override
  Widget build(BuildContext context) {
    final scope = UTDRoomScope.of(context);
    final strings = scope.strings;
    final theme = scope.theme;

    final id = seat.occupantUserId;
    final me = controller.localIdentity;
    final isSelf = id != null && id == me;
    final isHostOrAdmin = controller.isHostOrAdmin;

    // Run an action: pop first, then await, then surface failures via the
    // captured messenger (the sheet context is defunct after the pop).
    Future<void> run(Future<bool> Function() op) async {
      final messenger = ScaffoldMessenger.maybeOf(context);
      Navigator.of(context).pop();
      final ok = await op();
      if (!ok) utdShowSnackVia(messenger, strings.actionFailed);
    }

    final actions = <Widget>[];

    if (isSelf) {
      // Guest controls their own camera position…
      actions.add(UTDSheetAction(
        icon: Icons.cameraswitch_outlined,
        label: strings.switchCamera,
        onTap: () async {
          Navigator.of(context).pop();
          await controller.mediaController.switchCamera();
        },
      ));
      // …and can step DOWN from the stage themselves (owner spec 2026-06-11).
      actions.add(UTDSheetAction(
        icon: Icons.exit_to_app,
        label: strings.leaveStage,
        color: theme.danger,
        onTap: () => run(() => controller.seatController.leaveSeat(id)),
      ));
    } else if (isHostOrAdmin && id != null) {
      final cameraOn = controller.cameraOnParticipants.value.contains(id);
      final micMuted = controller.mutedParticipants.value.contains(id);

      actions.add(UTDSheetAction(
        icon: cameraOn ? Icons.videocam_off : Icons.videocam,
        label: cameraOn ? strings.turnCameraOff : strings.turnCameraOn,
        onTap: () => run(() => controller.setRemoteCameraEnabled(id, !cameraOn)),
      ));
      actions.add(UTDSheetAction(
        icon: micMuted ? Icons.mic : Icons.mic_off,
        label: micMuted ? strings.unmuteUser : strings.muteUser,
        onTap: () => run(() => controller.setRemoteMicEnabled(id, micMuted)),
      ));
      actions.add(UTDSheetAction(
        icon: Icons.person_remove,
        label: strings.kickFromSeat,
        color: theme.danger,
        onTap: () => run(
            () => controller.seatController.kickFromSeat(seat.index, identity: me ?? '')),
      ));
      // Kick out of the BROADCAST entirely (engine-side removal).
      actions.add(UTDSheetAction(
        icon: Icons.block,
        label: strings.kickFromBroadcast,
        color: theme.danger,
        onTap: () => run(() async {
          final result = await controller.kickParticipant(id);
          return result;
        }),
      ));
    }

    if (actions.isEmpty) {
      final name = seat.attributes['name'] ?? seat.attributes['cn'] ?? id ?? '';
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(color: theme.onSurface, fontSize: 15),
        ),
      );
    }

    return ListView(shrinkWrap: true, children: actions);
  }
}
