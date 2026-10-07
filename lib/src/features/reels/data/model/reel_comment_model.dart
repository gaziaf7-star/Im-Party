import 'package:general/src/features/reels/domain/entities/reel_comment_entity.dart';

import '../../../../core/utils/methods.dart';

class ReelCommentModel extends ReelCommentEntity {
  const ReelCommentModel({
    super.id,
    super.reelId,
    super.userId,
    super.comment,
    super.userProfilePic,
    super.userName,
    super.commentTime,
  });

  factory ReelCommentModel.fromJson(Map<String, dynamic> json) {
    final user = parseValue<Map<String, dynamic>>(json['user'], const {});
    return ReelCommentModel(
      id: parseValue<int>(json['id'], 0),
      userId: parseValue<int>(json['user_id'], 0),
      reelId: parseValue<int>(json['reel_id'] ?? json['real_id'], 0),
      comment: parseValue<String>(json['comment'], ''),
      commentTime: parseValue<String>(json['created_at'], ''),
      userName: parseValue<String>(user['name'], ''),
      userProfilePic: parseValue<String>(user['image'], ''),
    );
  }

}
