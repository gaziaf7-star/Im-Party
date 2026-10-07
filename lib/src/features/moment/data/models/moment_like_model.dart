import 'package:general/src/core/index.dart';

import '../../domain/entities/moment_likes_entity.dart';

class MomentLikeModel extends MomentLikesEntity {
  const MomentLikeModel({
    required super.userId,
    required super.senderImage,
    required super.receiverImage,
    required super.createdAt,
    required super.userImage,
    required super.userName,
    required super.uuid,
  });

  factory MomentLikeModel.fromJson(Map<String, dynamic> json) {
    final user = json["user"] ?? {};
    return MomentLikeModel(
      userId: parseValue<int>(user['id'], 0),
      uuid: parseValue<String>(user['uuid'], ''),
      userImage: parseValue<String>(user['image'], ''),
      userName: parseValue<String>(user['name'], ''),
      senderImage: parseValue<String>(user['sender_img'], ''),
      receiverImage: parseValue<String>(user['receiver_img'], ''),
      createdAt: parseValue<String>(json['created_at'], ''),
    );
  }
}
