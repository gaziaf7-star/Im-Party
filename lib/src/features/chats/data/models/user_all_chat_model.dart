
import 'package:general/src/features/chats/domain/entities/user_all_chat_entity.dart';
import 'package:general/src/features/messages/domain/entities/user_chat_entity.dart';

import '../../../../core/index.dart';
import '../../../messages/data/models/user_chat_model.dart';

class UserAllChatModel extends UserAllChatEntity {
  const UserAllChatModel({super.totalChatMessage, super.userChatEntity});

  factory UserAllChatModel.fromJson(Map<String, dynamic> json) {
    return UserAllChatModel(
        userChatEntity: parseValue<List<UserChatModel>>(
          json['chat'],
          [],
          customParser: (value) {
            if (value is List) {
              return value
                  .whereType<Map<String, dynamic>>()
                  .map((item) => UserChatModel.fromJson(item))
                  .toList();
            }
            // log("customParser: Expected List but got ${value.runtimeType}");
            return [];
          },
        ).cast<UserChatEntity>(),
        totalChatMessage: parseValue<int>(json['total_unread_messages'], 0));
  }
}
