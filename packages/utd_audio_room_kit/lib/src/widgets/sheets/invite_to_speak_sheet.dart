import 'package:flutter/material.dart';

import '../../controller/utd_room_controller.dart';
import '../../models/participant_model.dart';
import '../../theme/utd_room_scope.dart';
import 'member_row.dart';
import 'utd_sheet.dart';

/// Host/admin picker that lists audience members not currently on a seat and
/// invites the chosen one to speak (optionally onto a specific [seatIndex]).
class UTDInviteToSpeakSheet {
  static Future<void> show(
    BuildContext context, {
    required UTDRoomController controller,
    int? seatIndex,
  }) {
    return showUTDRoomSheet<void>(
      context,
      builder: (_) => _InviteList(controller: controller, seatIndex: seatIndex),
    );
  }
}

class _InviteList extends StatelessWidget {
  final UTDRoomController controller;
  final int? seatIndex;

  const _InviteList({required this.controller, this.seatIndex});

  @override
  Widget build(BuildContext context) {
    final scope = UTDRoomScope.of(context);
    final strings = scope.strings;
    final theme = scope.theme;
    final me = controller.localIdentity;

    return StreamBuilder<List<UTDParticipant>>(
      stream: controller.participantsStream,
      initialData: controller.participants,
      builder: (context, snapshot) {
        final candidates = (snapshot.data ?? const <UTDParticipant>[])
            .where((p) =>
                p.id != me &&
                controller.seatController.getSeatIndexByUserId(p.id) < 0)
            .toList();

        if (candidates.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(strings.noOtherMembers,
                style: TextStyle(color: theme.onSurface.withValues(alpha: 0.7))),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: candidates.length,
          itemBuilder: (context, i) {
            final p = candidates[i];
            return UTDMemberRow(
              participant: p,
              role: controller.getParticipantRole(p.id),
              trailing: [
                TextButton(
                  onPressed: () async {
                    // Capture before the pop — the sheet context is defunct after.
                    final messenger = ScaffoldMessenger.maybeOf(context);
                    Navigator.of(context).pop();
                    final result = await controller.inviteToSpeak(p.id,
                        seatIndex: seatIndex);
                    if (result == null) {
                      utdShowSnackVia(messenger, strings.actionFailed);
                    }
                  },
                  child: Text(strings.inviteToSpeak),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
