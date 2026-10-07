import 'package:general/src/core/index.dart';
import 'package:general/src/features/messages/messages.dart';

class MessagesModel extends MessagesEntity {
  const MessagesModel({
    super.id,
    super.userId,
    super.chatId,
    super.status,
    super.type,
    super.message,
    super.createdAt,
    super.senderDeleted,
    super.receiverDeleted,
    super.albums,
    super.reacts,
    super.replay,
    super.messageState,
  });

  factory MessagesModel.fromJson(Map<String, dynamic> json) {
    return MessagesModel(
      id: parseValue<int>(json['id'], 0),
      userId: parseValue<int>(json['user_id'], 0),
      chatId: parseValue<int>(json['chat_room_id'], 0),
      status: parseValue<String>(json['status'], ''),
      type: parseValue<String>(json['type'], ''),
      message: parseValue<String>(json['message'], ''),
      createdAt: Methods.utcToLocal(
        parseValue<String>(json['created_at'], ''),
      ),
      senderDeleted: parseValue<bool>(json['sender_deleted'], false),
      receiverDeleted: parseValue<bool>(json['receiver_deleted'], false),
      albums: (json["albums"] != null &&
              json["albums"] is List &&
              (json["albums"] as List).isNotEmpty)
          ? (json["albums"][0] is Map<String, dynamic>
              ? AlbumsModel.fromJson(json["albums"][0])
              : null)
          : null,
      reacts: json["reacts"] != null
          ? parseValue<List<ReactModel>>(
              json['reacts'],
              [],
              customParser: (value) {
                if (value is List) {
                  return value
                      .whereType<Map<String, dynamic>>()
                      .map((item) => ReactModel.fromJson(item))
                      .toList();
                }
                return [];
              },
            ).cast<ReactEntity>()
          : null,
      replay: json['replay'] is Map<String, dynamic>
          ? ReplayModel.fromJson(json['replay'])
          : null,
      messageState: MessageState.sent,
    );
  }
}

// AlbumsModel
class AlbumsModel extends AlbumsEntity {
  const AlbumsModel(
      {super.id,
      super.userId,
      super.file,
      super.type,
      super.firstFrame,
      super.isLocal,
      super.duration});

  factory AlbumsModel.fromJson(Map<String, dynamic> json) {
    return AlbumsModel(
      id: parseValue<int>(json['id'], 0),
      userId: parseValue<int>(json['user_id'], 0),
      file: parseValue<String>(json['file'], ''),
      type: parseValue<String>(json['type'], ''),
      firstFrame: parseValue<String>(json['frame'], ''),
      isLocal: false,
      // Hardcoded as per original
      duration: parseValue<String>(json['duration'], ''),
    );
  }
}

// ReactModel
class ReactModel extends ReactEntity {
  const ReactModel({
    required super.id,
    super.userReact,
    required super.react,
  });

  factory ReactModel.fromJson(Map<String, dynamic> json) {
    return ReactModel(
        id: parseValue<int>(json['id'], 0),
        react: parseValue<String>(json['react'], ''),
        userReact: json['user'] is Map<String, dynamic>
            ? UserReactModel.fromJson(json['user'])
            : null);
  }
}

// UserReactModel
class UserReactModel extends UserReactEntity {
  const UserReactModel({
    required super.userId,
    required super.userName,
    required super.userImage,
    super.hasColorName,
  });

  factory UserReactModel.fromJson(Map<String, dynamic> json) {
    return UserReactModel(
      userId: parseValue<int>(json['id'], 0),
      userName: parseValue<String>(json['name'], ''),
      userImage: parseValue<String>(json['img'], ''),
      hasColorName: parseValue<bool>(json['has_color_name'], false),
    );
  }
}

class ReplayModel extends ReplayEntity {
  const ReplayModel({
    super.messageId,
    super.messageUserId,
    super.message,
    super.messageType,
    super.albums,
    super.page,
  });

  factory ReplayModel.fromJson(Map<String, dynamic> json) {
    return ReplayModel(
      messageId: parseValue<int>(json['message_id'], 0),
      messageUserId: parseValue<int>(json['message_user_id'], 0),
      message: parseValue<String>(json['message'], ''),
      messageType: parseValue<String>(json['message_type'], ''),
      albums: (json["message_albums"] != null &&
              json["message_albums"] is List &&
              (json["message_albums"] as List).isNotEmpty)
          ? (json["message_albums"][0] is Map<String, dynamic>
              ? AlbumsModel.fromJson(json["message_albums"][0])
              : null)
          : null,
      page: parseValue<int>(json['page'], 0),
    );
  }
}
