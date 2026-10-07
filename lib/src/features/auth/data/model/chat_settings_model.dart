import 'package:general/src/core/index.dart';

import '../../domain/entities/chat_settings_entity.dart';

class ChatSettingsModel extends ChatSettingsEntity {
  const ChatSettingsModel({
    super.chatWithFriends,
    super.chatWithFollowers,
    super.chatWithAll,
  });

  factory ChatSettingsModel.fromJson(Map<String, dynamic> json) {
    return ChatSettingsModel(
      chatWithAll: parseValue<bool>(json['chat_with_all'], false),
      chatWithFollowers: parseValue<bool>(json['chat_with_followers'], false),
      chatWithFriends: parseValue<bool>(json['chat_with_friends'], false),
    );
  }
}
