import '../../models/seat_model.dart';

/// The actions a seat tap can offer, in display order. Pure data so the decision
/// logic is unit-testable without a live room or any Flutter context.
enum UTDSeatAction {
  /// Local user (not seated) takes this empty seat.
  take,

  /// Local user (seated elsewhere) switches to this empty seat.
  switchHere,

  /// Local user leaves their own (non-host) seat.
  leave,

  /// Local host leaves the reserved host seat.
  stepDown,

  /// Host/admin locks this seat.
  lock,

  /// Host/admin unlocks this seat.
  unlock,

  /// Host/admin invites someone to this seat.
  invite,

  /// Host/admin mutes the occupant.
  mute,

  /// Host/admin unmutes the occupant.
  unmute,

  /// Host/admin removes the occupant from the seat.
  kick,

  /// Non-host tapped a locked seat — informational only.
  lockedInfo,

  /// Non-host tapped a seat reserved for someone else — informational only.
  reservedInfo,
}

/// Computes the ordered list of actions to offer when [seat] is tapped.
///
/// - An empty list means "do nothing" (e.g. a regular user tapping a seat held
///   by someone else — the package has no profile view to show).
/// - A single [UTDSeatAction.lockedInfo]/[UTDSeatAction.reservedInfo] means the
///   caller should show a brief snackbar rather than a sheet.
List<UTDSeatAction> resolveSeatActions({
  required SeatState seat,
  required bool isHostOrAdmin,
  required bool isHost,
  required String? me,
  required int localSeatIndex,
  required int hostSeatIndex,
}) {
  final actions = <UTDSeatAction>[];

  if (seat.isOccupied) {
    final occupiedByMe = seat.occupantUserId == me && me != null;
    if (occupiedByMe) {
      if (seat.index == hostSeatIndex && isHost) {
        actions.add(UTDSeatAction.stepDown);
      } else {
        actions.add(UTDSeatAction.leave);
      }
    } else if (isHostOrAdmin) {
      actions.add(seat.isMuted ? UTDSeatAction.unmute : UTDSeatAction.mute);
      actions.add(UTDSeatAction.kick);
      actions.add(seat.isLocked ? UTDSeatAction.unlock : UTDSeatAction.lock);
    }
    return actions;
  }

  // Empty seat.
  if (seat.isLocked) {
    if (isHostOrAdmin) {
      actions
        ..add(UTDSeatAction.unlock)
        ..add(UTDSeatAction.invite);
    } else {
      actions.add(UTDSeatAction.lockedInfo);
    }
    return actions;
  }

  final reservedForOther = seat.isReserved && seat.reservedFor != me;
  if (reservedForOther) {
    if (isHostOrAdmin) {
      actions
        ..add(UTDSeatAction.lock)
        ..add(UTDSeatAction.invite);
    } else {
      actions.add(UTDSeatAction.reservedInfo);
    }
    return actions;
  }

  // Empty + available (or reserved for me).
  if (me != null) {
    actions.add(
      localSeatIndex >= 0 ? UTDSeatAction.switchHere : UTDSeatAction.take,
    );
  }
  if (isHostOrAdmin) {
    actions
      ..add(UTDSeatAction.lock)
      ..add(UTDSeatAction.invite);
  }
  return actions;
}
