// ConversationEntity


// AppMessagesEntity
import '../../chats.dart';
//
// class SystemAndOfficialMessagesEntity extends Equatable {
//   final List<MessageDataEntity>? systemEntity;
//
//   const SystemAndOfficialMessagesEntity({required this.systemEntity});
//
//   @override
//   List<Object?> get props => [systemEntity];
// }


// MessageDataEntity
class SystemAndOfficialMessagesEntity extends Equatable {
  final String title;
  final String img;
  final String content;
  final String url;
  final String created;
  final String updated;
  final int fromUserId;
  final int id;
  final int userId;
  final int type;

  const SystemAndOfficialMessagesEntity({
    required this.title,
    required this.img,
    required this.content,
    required this.url,
    required this.created,
    required this.updated,
    required this.id,
    required this.userId,
    required this.type,
    required this.fromUserId,
  });

  @override
  List<Object?> get props => [
    title,
    img,
    content,
    url,
    created,
    updated,
    id,
    userId,
    type,
    fromUserId
  ];
}
