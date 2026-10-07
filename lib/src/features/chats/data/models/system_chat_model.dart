import '../../chats.dart';

// MessageDataEntity
class SystemAndOfficialMessagesModel extends SystemAndOfficialMessagesEntity {

  const SystemAndOfficialMessagesModel({
    required super.title,
    required super.img,
    required super.content,
    required super.url,
    required super.created,
    required super.updated,
    required super.id,
    required super.userId,
    required super.type,
    required super.fromUserId,
  });

  factory SystemAndOfficialMessagesModel.fromJson(Map<String, dynamic> jsonData) =>
      SystemAndOfficialMessagesModel(
        title: parseValue<String>(jsonData['title'], ""),
        type: parseValue<int>(jsonData['type'], 0),
        content: parseValue<String>(jsonData['content'], ""),
        created: Methods.utcToLocal(
          parseValue<String>(jsonData['created_at'], ""),
        ),
        updated: parseValue<String>(jsonData['updated_at'], ""),
        url: parseValue<String>(jsonData['url'], ""),
        userId: parseValue<int>(jsonData['user_id'], 0),
        id: parseValue<int>(jsonData['id'], 0),
        img: parseValue<String>(jsonData['img'], ""),
        fromUserId: parseValue<int>(jsonData['from_user_id'], 0),
      );


}
