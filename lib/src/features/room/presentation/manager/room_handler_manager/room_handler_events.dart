import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/data/model/enter_room_model.dart';

abstract class RoomHandlerEvents extends Equatable {}

class EnterRoomEvent extends RoomHandlerEvents {
  final String roomId;
  final String roomPassword;
  final int isVip;
  final BuildContext context;

  EnterRoomEvent(this.context,
      {required this.isVip, required this.roomId, required this.roomPassword});

  @override
  List<Object?> get props => [roomId, roomPassword, isVip];
}

class EmitCachedRoomDataEvent extends RoomHandlerEvents {
  final EnterRoomModel room;

  EmitCachedRoomDataEvent(this.room);

  @override
  List<Object?> get props => [room];
}

class ResetRoomHandlerEvent extends RoomHandlerEvents {
  @override
  List<Object?> get props => [];
}
