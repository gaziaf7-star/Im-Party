import 'package:flutter/material.dart';

import '../../controller/utd_room_controller.dart';
import '../../models/participant_model.dart';
import '../../theme/utd_room_scope.dart';
import 'ban_management_sheet.dart';
import 'member_row.dart';
import 'utd_sheet.dart';

/// Default member list: every participant, with host/admin moderation actions
/// (mute/unmute, remove from seat, invite, ban) and owner-only promote/demote.
class UTDMemberListSheet {
  static Future<void> show(
    BuildContext context, {
    required UTDRoomController controller,
  }) {
    return showUTDRoomSheet<void>(
      context,
      builder: (_) => _MemberList(controller: controller),
    );
  }
}

class _MemberList extends StatelessWidget {
  final UTDRoomController controller;

  const _MemberList({required this.controller});

  @override
  Widget build(BuildContext context) {
    final scope = UTDRoomScope.of(context);
    final strings = scope.strings;
    final theme = scope.theme;
    final me = controller.localIdentity;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(strings.memberList,
                      style: TextStyle(
                          color: theme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
                if (controller.isHostOrAdmin)
                  IconButton(
                    icon: Icon(Icons.gavel, color: theme.onSurface),
                    tooltip: strings.banManagement,
                    onPressed: () =>
                        UTDBanManagementSheet.show(context, controller: controller),
                  ),
              ],
            ),
          ),
          Flexible(
            child: StreamBuilder<List<UTDParticipant>>(
              stream: controller.participantsStream,
              initialData: controller.participants,
              builder: (context, snapshot) {
                final members = snapshot.data ?? const <UTDParticipant>[];
                if (members.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(strings.noOtherMembers,
                        style: TextStyle(
                            color: theme.onSurface.withValues(alpha: 0.7))),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: members.length,
                  itemBuilder: (context, i) {
                    final p = members[i];
                    final canManage =
                        controller.isHostOrAdmin && p.id != me;
                    return UTDMemberRow(
                      participant: p,
                      role: controller.getParticipantRole(p.id),
                      trailing: [
                        if (canManage)
                          IconButton(
                            icon: Icon(Icons.more_horiz, color: theme.onSurface),
                            onPressed: () =>
                                _showMemberActions(context, controller, p),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showMemberActions(
  BuildContext context,
  UTDRoomController controller,
  UTDParticipant p,
) {
  final scope = UTDRoomScope.of(context);
  final strings = scope.strings;
  final theme = scope.theme;
  final me = controller.localIdentity;
  final seats = controller.seatController;
  final seatIndex = seats.getSeatIndexByUserId(p.id);
  final isSeated = seatIndex >= 0;
  final isOwner = me != null && me == scope.roomOwnerId;
  final role = controller.getParticipantRole(p.id);

  Future<void> run(BuildContext ctx, Future<bool> Function() op) async {
    // Capture the messenger before the pop — `ctx` is the sheet body context and
    // is defunct (mounted == false) once popped, so the failure snackbar must be
    // shown via the captured messenger, not re-derived from `ctx`.
    final messenger = ScaffoldMessenger.maybeOf(ctx);
    Navigator.of(ctx).pop();
    final ok = await op();
    if (!ok) utdShowSnackVia(messenger, strings.actionFailed);
  }

  Future<void> runRole(BuildContext ctx, String newRole) async {
    final messenger = ScaffoldMessenger.maybeOf(ctx);
    Navigator.of(ctx).pop();
    try {
      await controller.changeRole(targetIdentity: p.id, role: newRole);
    } catch (_) {
      utdShowSnackVia(messenger, strings.actionFailed);
    }
  }

  return showUTDRoomSheet<void>(
    context,
    builder: (ctx) {
      final muted = isSeated && seats.seats.value[seatIndex].isMuted;
      return ListView(
        shrinkWrap: true,
        children: [
          if (isSeated) ...[
            UTDSheetAction(
              icon: muted ? Icons.mic : Icons.mic_off,
              label: muted ? strings.unmuteUser : strings.muteUser,
              // Re-resolve the seat by user id at tap time: the occupant may have
              // moved/left since the sheet opened, so the captured [seatIndex]
              // could now point at a different (or empty) seat.
              onTap: () => run(ctx, () async {
                final idx = seats.getSeatIndexByUserId(p.id);
                if (idx < 0) return false;
                final isMutedNow = seats.seats.value[idx].isMuted;
                return isMutedNow
                    ? seats.unmuteSeat(idx, identity: me ?? '')
                    : seats.muteSeat(idx, identity: me ?? '');
              }),
            ),
            UTDSheetAction(
              icon: Icons.person_remove,
              label: strings.kickFromSeat,
              color: theme.danger,
              onTap: () => run(ctx, () async {
                final idx = seats.getSeatIndexByUserId(p.id);
                if (idx < 0) return false;
                return seats.kickFromSeat(idx, identity: me ?? '');
              }),
            ),
          ] else
            UTDSheetAction(
              icon: Icons.person_add_alt,
              label: strings.inviteToSpeak,
              onTap: () async {
                Navigator.of(ctx).pop();
                await controller.inviteToSpeak(p.id);
              },
            ),
          if (isOwner)
            UTDSheetAction(
              icon: role == 'admin'
                  ? Icons.remove_moderator
                  : Icons.admin_panel_settings,
              label: role == 'admin' ? strings.demote : strings.promote,
              onTap: () =>
                  runRole(ctx, role == 'admin' ? 'audience' : 'admin'),
            ),
          UTDSheetAction(
            icon: Icons.block,
            label: strings.ban,
            color: theme.danger,
            onTap: () => run(ctx, () => controller.banUser(p.id)),
          ),
        ],
      );
    },
  );
}
