import 'package:general/src/features/messages/messages.dart';

import '../../../../core/utils/methods.dart';

class UserChatModel extends UserChatEntity {
  const UserChatModel({
    required super.userId,
    required super.chatId,
    required super.unreadMessage,
    required super.name,
    required super.image,
    required super.hasColorName,
    required super.lastMessage,
    required super.inRoom,
  });

  factory UserChatModel.fromJson(Map<String, dynamic> json) {
    return UserChatModel(
      userId: parseValue<int>(json['user_id'], 0),
      chatId: parseValue<int>(json['chat_id'], 0),
      unreadMessage: parseValue<int>(json['unread_message'], 0),
      name: parseValue<String>(json['name'], ''),
      image: parseValue<String>(json['img'], ''),
      hasColorName: parseValue<bool>(json['has_color_name'], false),
      inRoom: parseValue<bool>(json['in_room'], false),
      lastMessage: json['last_message'] is Map<String, dynamic>
          ? LastMessageModel.fromJson(json['last_message'])
          : const LastMessageModel(),
    );
  }

}

class LastMessageModel extends LastMessageEntity {
  const LastMessageModel({
    super.id,
    super.senderId,
    super.message,
    super.type,
    super.time,
    super.status,
    super.senderDeleted,
    super.receiverDeleted,
  });

  factory LastMessageModel.fromJson(Map<String, dynamic> json) {
    return LastMessageModel(
      id: parseValue<int>(json['id'], 0),
      senderId: parseValue<int>(json['user_id'], 0),
      message: parseValue<String>(json['message'], ''),
      type: parseValue<String>(json['type'], ''),
      time: Methods.utcToLocal(
        parseValue<String>(json['created_at'], ''),
      ),
      status: parseValue<String>(json['status'], ''),
      senderDeleted: parseValue<bool>(json['sender_deleted'], false),
      receiverDeleted: parseValue<bool>(json['receiver_deleted'], false),
    );
  }

}
