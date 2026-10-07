part of 'update_room_bloc.dart';

abstract class UpdateRoomEvents extends Equatable {
  const UpdateRoomEvents();
}

// pick image
class PickImageEvent extends UpdateRoomEvents {
  final ImageSource source;
  final String ownerId;
  final BuildContext context;
  const PickImageEvent(
      {required this.context, required this.source, required this.ownerId});

  @override
  List<Object> get props => [source, ownerId];
}

class UpdateRoomEvent extends UpdateRoomEvents {
  final String ownerId;
  final String roomId;
  final String? roomName;
  final String? freeMic;
  final File? roomCover;
  final String? roomBackgroundId;
  final String? roomIntro;
  final String? roomPass;
  final String? roomType;
  final String? roomClass;
  final String? change;
  final String? roomVideoType;

  const UpdateRoomEvent(
      {required this.ownerId,
      this.roomName,
      this.freeMic,
      this.roomCover,
      this.roomBackgroundId,
      this.roomIntro,
      this.roomPass,
      this.roomType,
      this.roomClass,
      this.change,
      this.roomVideoType,
      required this.roomId});
  @override
  List<Object?> get props => [
        ownerId,
        roomName,
        freeMic,
        roomCover,
        roomBackgroundId,
        roomIntro,
        roomPass,
        roomType,
        roomClass,
        change,
        roomVideoType,
        roomId
      ];
}
