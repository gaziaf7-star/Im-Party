import 'package:general/src/features/messages/messages.dart';

import '../../../../core/utils/methods.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel(
      {super.chatId, required super.room, required super.messages});

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      ConversationModel(
        chatId: json['chat_room_id'],
        room: json['user_now_room'] is Map<String, dynamic> ? UserNowRoomModel.fromJson(json['user_now_room']) : null,
        messages: List<MessagesModel>.from(
          (json['messages'] is List ? json['messages'] as List : const [])
              .whereType<Map<String, dynamic>>()
              .map(
            (element) => MessagesModel.fromJson(element),
          ),
        ),
      );
}

class UserNowRoomModel extends UserNowRoomEntity {
  UserNowRoomModel(
      {super.roomOwnerId, super.owner, super.hasPassword, super.room});

  UserNowRoomModel.fromJson(Map<String, dynamic> json) {
    roomOwnerId =parseValue<int>(json['room_owner_id'], 0);
    owner = json['owner'] is Map<String, dynamic> ? OwnerModel.fromJson(json['owner']) : null;
    hasPassword = json['has_password'];
    room = json['room'] is Map<String, dynamic> ? RoomChatModel.fromJson(json['room']) : null;
  }

  @override
  List<Object?> get props => [roomOwnerId, owner, hasPassword, room];
}

class OwnerModel extends OwnerEntity {
  OwnerModel({super.uuid});

  OwnerModel.fromJson(Map<String, dynamic> json) {
    uuid = parseValue<String>(json['uuid'], '') ;
  }

  @override
  List<Object?> get props => [uuid];
}

class RoomChatModel extends RoomChatEntity {
  RoomChatModel(
      {super.id,
      super.name,
      super.image,
      super.mode,
      super.roomBackground,
      super.exp});

  factory RoomChatModel.fromJson(Map<String, dynamic> json) {
    return RoomChatModel(
    id : parseValue<int>(json['id'], 0),
      name : parseValue<String>(json['name'], ''),
      image : parseValue<String>(json['image'], ''),
      mode : parseValue<int>(json['mode'], 0),
      roomBackground : parseValue<String>(json['room_background'], ''),
      exp : parseValue<String>(json['exp'], ''),
    );

  }


  @override
  List<Object?> get props => [id, name, image, mode, roomBackground, exp];
}
