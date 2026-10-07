import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/domain/entities/moment_comments_entity.dart';

class MomentCommentsModel extends MomentCommentsEntity {
  const MomentCommentsModel({
    required super.commentId,
    required super.momentId,
    required super.userId,
    required super.uuid,
    required super.comment,
    required super.userProfilePic,
    required super.userName,
    required super.commentTime,
  });

  factory MomentCommentsModel.fromJson(Map<String, dynamic> jsonData) {
    final user = jsonData['user'] ?? {};

    return MomentCommentsModel(
      commentId: parseValue<int>(jsonData['id'], 0),
      userId: parseValue<int>(user['id'], 0),
      uuid: parseValue<String>(user['uuid'], ''),
      momentId: parseValue<int>(jsonData['moment_id'], 0),
      comment: parseValue<String>(jsonData['comment'], ''),
      commentTime: parseValue<String>(jsonData['created_at'], ''),
      userName: parseValue<String>(user['name'], ''),
      userProfilePic: parseValue<String>(user['image'], ''),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = commentId;
    map['moment_id'] = momentId;
    map['user']['id'] = userId;
    map['user']['uuid'] = uuid;
    map['comment'] = comment;
    map['user']['image'] = userProfilePic;
    map['user']['name'] = userName;
    map['created_at'] = commentTime;
    return map;
  }
}
