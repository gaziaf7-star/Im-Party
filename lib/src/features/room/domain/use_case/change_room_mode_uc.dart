import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

/// Stores the room's mode.
///
/// For an AUDIO room that is the seat layout; for a LIVE room it is the number
/// of guest tiles the host chose before going live. The two never collide
/// because a room row belongs to exactly one of the two types.
class ChangeRoomModeUC extends UseCaseWithParams<String, ChangeRoomModeParameter> {
  final RoomBaseRepository _repo;

  ChangeRoomModeUC(this._repo);

  @override
  ResultFuture<String> call(ChangeRoomModeParameter params) {
    return _repo.changeRoomMode(roomId: params.roomId, mode: params.mode);
  }
}
