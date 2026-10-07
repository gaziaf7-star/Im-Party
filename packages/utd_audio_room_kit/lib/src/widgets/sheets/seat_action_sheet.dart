import 'package:flutter/material.dart';

import '../../controller/utd_room_controller.dart';
import '../../models/seat_model.dart';
import '../../theme/utd_room_scope.dart';
import '../../theme/utd_room_strings.dart';
import 'invite_to_speak_sheet.dart';
import 'seat_tap_decision.dart';
import 'utd_sheet.dart';

/// The package's built-in default seat-tap handler. Used by [UTDAudioRoom] when
/// the consumer does not supply `onSeatTap`. Offers, depending on seat state and
/// the local user's role: take / switch / leave / step-down, and host moderation
/// (mute, kick, lock/unlock, invite).
class UTDSeatActionSheet {
  static Future<void> show(
    BuildContext context, {
    required UTDRoomController controller,
    required int index,
    required SeatState seat,
  }) async {
    final scope = UTDRoomScope.maybeOf(context);
    final strings = scope?.strings ?? UTDRoomStrings.en();
    final hostSeatIndex = scope?.hostSeatIndex ?? 0;

    final me = controller.localIdentity;
    final isHostOrAdmin = controller.isHostOrAdmin;
    final isHost = controller.localRole == 'host';
    final localSeatIndex = controller.localSeatIndex;

    final actions = resolveSeatActions(
      seat: seat,
      isHostOrAdmin: isHostOrAdmin,
      isHost: isHost,
      me: me,
      localSeatIndex: localSeatIndex,
      hostSeatIndex: hostSeatIndex,
    );

    if (actions.isEmpty) return;

    // Information-only taps surface a snackbar instead of a sheet.
    if (actions.length == 1 &&
        (actions.first == UTDSeatAction.lockedInfo ||
            actions.first == UTDSeatAction.reservedInfo)) {
      utdShowSnack(
        context,
        actions.first == UTDSeatAction.lockedInfo
            ? strings.seatLocked
            : strings.seatReserved,
      );
      return;
    }

    await showUTDRoomSheet<void>(
      context,
      builder: (sheetContext) => _SeatActionList(
        controller: controller,
        index: index,
        seat: seat,
        actions: actions,
      ),
    );
  }
}

class _SeatActionList extends StatelessWidget {
  final UTDRoomController controller;
  final int index;
  final SeatState seat;
  final List<UTDSeatAction> actions;

  const _SeatActionList({
    required this.controller,
    required this.index,
    required this.seat,
    required this.actions,
  });

  Future<void> _run(BuildContext context, Future<bool> Function() op) async {
    final strings = UTDRoomScope.of(context).strings;
    // Capture the messenger BEFORE popping: after the pop, `context` is defunct
    // and `context.mounted` is false, so a failure snackbar keyed on it would
    // never show.
    final messenger = ScaffoldMessenger.maybeOf(context);
    Navigator.of(context).pop();
    final ok = await op();
    if (!ok) utdShowSnackVia(messenger, strings.actionFailed);
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String body,
  }) async {
    final strings = UTDRoomScope.of(context).strings;
    final result = await showDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(false),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(true),
            child: Text(strings.confirm),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final scope = UTDRoomScope.of(context);
    final strings = scope.strings;
    final theme = scope.theme;
    final me = controller.localIdentity;
    final seats = controller.seatController;

    Widget row(UTDSeatAction a) {
      switch (a) {
        case UTDSeatAction.take:
          return UTDSheetAction(
            icon: Icons.event_seat,
            label: strings.takeSeat,
            onTap: () => _run(context, () => seats.takeSeat(index, me ?? '')),
          );
        case UTDSeatAction.switchHere:
          return UTDSheetAction(
            icon: Icons.swap_horiz,
            label: strings.switchSeat,
            onTap: () => _run(context, () => seats.moveSeat(me ?? '', index)),
          );
        case UTDSeatAction.leave:
          return UTDSheetAction(
            icon: Icons.logout,
            label: strings.leaveSeat,
            color: theme.danger,
            onTap: () async {
              final ok = await _confirm(
                context,
                title: strings.leaveSeatTitle,
                body: strings.leaveSeatBody,
              );
              if (ok && context.mounted) {
                await _run(context, () => seats.leaveSeat(me ?? ''));
              }
            },
          );
        case UTDSeatAction.stepDown:
          return UTDSheetAction(
            icon: Icons.logout,
            label: strings.stepDown,
            color: theme.danger,
            onTap: () async {
              final ok = await _confirm(
                context,
                title: strings.stepDownTitle,
                body: strings.stepDownBody,
              );
              if (ok && context.mounted) {
                await _run(context, () => seats.leaveSeat(me ?? ''));
              }
            },
          );
        case UTDSeatAction.lock:
          return UTDSheetAction(
            icon: Icons.lock_outline,
            label: strings.lockSeat,
            onTap: () =>
                _run(context, () => seats.lockSeat(index, identity: me ?? '')),
          );
        case UTDSeatAction.unlock:
          return UTDSheetAction(
            icon: Icons.lock_open,
            label: strings.unlockSeat,
            onTap: () => _run(
                context, () => seats.unlockSeat(index, identity: me ?? '')),
          );
        case UTDSeatAction.invite:
          return UTDSheetAction(
            icon: Icons.person_add_alt,
            label: strings.inviteToSpeak,
            onTap: () {
              Navigator.of(context).pop();
              UTDInviteToSpeakSheet.show(context,
                  controller: controller, seatIndex: index);
            },
          );
        case UTDSeatAction.mute:
          return UTDSheetAction(
            icon: Icons.mic_off,
            label: strings.muteUser,
            onTap: () =>
                _run(context, () => seats.muteSeat(index, identity: me ?? '')),
          );
        case UTDSeatAction.unmute:
          return UTDSheetAction(
            icon: Icons.mic,
            label: strings.unmuteUser,
            onTap: () => _run(
                context, () => seats.unmuteSeat(index, identity: me ?? '')),
          );
        case UTDSeatAction.kick:
          return UTDSheetAction(
            icon: Icons.person_remove,
            label: strings.kickFromSeat,
            color: theme.danger,
            onTap: () => _run(
                context, () => seats.kickFromSeat(index, identity: me ?? '')),
          );
        case UTDSeatAction.lockedInfo:
        case UTDSeatAction.reservedInfo:
          return const SizedBox.shrink();
      }
    }

    return ListView(
      shrinkWrap: true,
      children: actions.map(row).toList(),
    );
  }
}
