import 'package:general/src/features/chats/domain/entities/user_all_chat_entity.dart';
import 'package:general/src/features/messages/domain/entities/user_chat_entity.dart';

import '../../../../core/index.dart';
import '../../../messages/data/models/user_chat_model.dart';

class UserAllChatRequestModel extends UserAllChatEntity {
  const UserAllChatRequestModel({super.totalChatMessage, super.userChatEntity});

  factory UserAllChatRequestModel.fromJson(Map<String, dynamic> json) {
    return UserAllChatRequestModel(
        userChatEntity: List<UserChatEntity>.from(
          json['request_chat'].map((x) => UserChatModel.fromJson(x)),
        ),
        totalChatMessage: parseValue<int>(json['total_unread_messages'], 0));
  }
}
