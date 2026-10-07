import 'package:general/src/features/room/data/model/enter_room_model.dart';
import 'package:equatable/equatable.dart';

abstract class RoomHandlerStates extends Equatable {}

class InitialHandlerRoomStates extends RoomHandlerStates {
  @override
  List<Object?> get props => [];
}

class EnterRoomErrorMessageState extends RoomHandlerStates {
  final String errorMessage;

  EnterRoomErrorMessageState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class EnterRoomLaoding extends RoomHandlerStates {
  EnterRoomLaoding();

  @override
  List<Object?> get props => [];
}

class EnterRoomSuccesMessageState extends RoomHandlerStates {
  final EnterRoomModel room;
  final int _timestamp;

  EnterRoomSuccesMessageState({
    required this.room,
  }) : _timestamp = DateTime.now().microsecondsSinceEpoch;

  @override
  List<Object?> get props => [room, _timestamp];
}
