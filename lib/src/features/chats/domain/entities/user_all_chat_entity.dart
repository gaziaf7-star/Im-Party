
import 'package:general/src/features/chats/chats.dart';
import 'package:general/src/features/messages/domain/entities/user_chat_entity.dart';

class UserAllChatEntity extends Equatable {
  final List<UserChatEntity>? userChatEntity;
  final int? totalChatMessage;

  const UserAllChatEntity({this.userChatEntity,this.totalChatMessage});

  UserAllChatEntity copyWith({
    int? totalChatMessage,
  }) {
    return UserAllChatEntity(
      totalChatMessage: totalChatMessage ?? this.totalChatMessage,
      userChatEntity: userChatEntity,
    );
  }

  @override
  List<Object?> get props => [
    userChatEntity,
    totalChatMessage
  ];
}
