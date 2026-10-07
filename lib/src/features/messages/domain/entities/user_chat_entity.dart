import 'package:general/src/core/index.dart';

class UserChatEntity extends Equatable {
  final int userId;
  final int chatId;
  final int unreadMessage;
  final String name;
  final String image;
  final bool hasColorName;
  final bool inRoom;
  final LastMessageEntity lastMessage;

  const UserChatEntity({
    required this.userId,
    required this.chatId,
    required this.unreadMessage,
    required this.name,
    required this.image,
    required this.hasColorName,
    required this.inRoom,
    required this.lastMessage,
  });

  UserChatEntity copyWith({
    int? unreadMessage,
    LastMessageEntity? lastMessage,
  }) {
    return UserChatEntity(
      unreadMessage: unreadMessage ?? this.unreadMessage,
      lastMessage: lastMessage ?? this.lastMessage,
      userId: userId,
      chatId: chatId,
      name: name,
      image: image,
      hasColorName: hasColorName,
      inRoom: inRoom,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        chatId,
        unreadMessage,
        name,
        image,
        hasColorName,
        lastMessage,
    inRoom,
      ];
}

class LastMessageEntity extends Equatable {
  final int? id;
  final int? senderId;
  final String? message;
  final String? type;
  final String? time;
  final String? status;
  final bool? senderDeleted;
  final bool? receiverDeleted;

  const LastMessageEntity({
    this.id,
    this.senderId,
    this.message,
    this.type,
    this.time,
    this.status,
    this.senderDeleted,
    this.receiverDeleted,
  });

  LastMessageEntity copyWith({
    String? status,
    bool? senderDeleted,
  }) {
    return LastMessageEntity(
      id: id,
      senderId: senderId,
      message: message,
      type: type,
      time: time,
      status: status ?? this.status,
      senderDeleted: senderDeleted??this.senderDeleted,
      receiverDeleted: receiverDeleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        senderId,
        message,
        type,
        time,
        status,
        senderDeleted,
        receiverDeleted,
      ];
}
