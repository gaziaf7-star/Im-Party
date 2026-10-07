part of 'create_room_bloc.dart';

abstract class CreateRoomEvents extends Equatable {}

class CreateAudioRoomEvent extends CreateRoomEvents {
  final String roomIntero;
  final String roomType;
  final File? roomCover;
  final String roomName;
  final String password;
  final String type;

  CreateAudioRoomEvent({
    required this.roomName,
    required this.roomCover,
    required this.password,
    required this.roomIntero,
    required this.type,
    required this.roomType,
  });

  @override
  List<Object?> get props => [roomIntero, roomType, roomCover, roomName, type];
}

class SelectRoomTypeEvent extends CreateRoomEvents {
  final int roomTypeId;

  SelectRoomTypeEvent(this.roomTypeId);

  @override
  List<Object?> get props => [roomTypeId];
}

class GetTypesRoomEvent extends CreateRoomEvents {
  @override
  List<Object?> get props => [];
}

class DisposeEvent extends CreateRoomEvents {
  @override
  List<Object?> get props => [];
}

class PickRoomImage extends CreateRoomEvents {
  final File? image;

  PickRoomImage(this.image);

  @override
  List<Object?> get props => [image];
}

class RemoveRoomImage extends CreateRoomEvents {

  @override
  List<Object?> get props => [];
}

class CreatePaidRoomEvent extends CreateRoomEvents {
  @override
  List<Object?> get props => [];
}
