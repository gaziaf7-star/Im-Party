import 'package:general/src/core/index.dart';
import 'package:general/src/features/messages/messages.dart';

class ConversationEntity extends Equatable {
  final int? chatId;
  final List<MessagesEntity> messages;
  final UserNowRoomEntity? room;
  const ConversationEntity({
    this.chatId,
    required this.messages,
    required this.room,
  });

  @override
  List<Object?> get props => [chatId, messages];
}

class UserNowRoomEntity extends Equatable {
  int? roomOwnerId;
  OwnerEntity? owner;
  bool? hasPassword;
  RoomChatEntity? room;

  UserNowRoomEntity({this.roomOwnerId, this.owner, this.hasPassword, this.room});



  @override
  List<Object?> get props => [roomOwnerId, owner, hasPassword, room];
}

class OwnerEntity extends Equatable {
  String? uuid;

  OwnerEntity({this.uuid});



  @override
  List<Object?> get props => [uuid];
}

class RoomChatEntity extends Equatable {
  int? id;
  String? name;
  String? image;
  int? mode;
  String? roomBackground;
  String? exp;

  RoomChatEntity(
      {this.id,
      this.name,
      this.image,
      this.mode,
      this.roomBackground,
      this.exp});

  @override
  List<Object?> get props => [id, name, image, mode, roomBackground, exp];
}
