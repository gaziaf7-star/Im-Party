


import 'package:general/src/core/index.dart';
import 'package:general/src/features/reels/domain/entities/reel_entity.dart';

/// Resolves a media path while preserving nullability: absolute http(s) and
/// protocol-relative URLs pass through unchanged; only relative paths are
/// prefixed via [EndPoints.getImage]. Returns null for null/empty input so the
/// entity's nullable url contract is respected (no '' default that hides a
/// missing source).
String? _resolveMediaUrl(dynamic raw) {
  final value = raw is String ? raw : null;
  if (value == null || value.isEmpty) return null;
  if (value.startsWith('http://') ||
      value.startsWith('https://') ||
      value.startsWith('//')) {
    return value;
  }
  return EndPoints.getImage(value);
}

class ReelsMainModel extends ReelsEntity {
  const ReelsMainModel({
    super.url,
    super.subFrame,
    super.likeCount,
    super.id,
    super.commentCount,
    super.sendCount,
    super.isLiked,
    super.musicName,
    super.musicImageUrl,
    super.description,
    super.createdAt,
    super.updatedAt,
    super.user,
  });

  factory ReelsMainModel.fromJson(Map<String, dynamic> json) {
    return ReelsMainModel(
      url: _resolveMediaUrl(json['url']),
      subFrame: _resolveMediaUrl(json['sub_video'] ?? json['sub_frame']),
      likeCount: parseValue<int>(json['likes_count'], 0),
      id: parseValue<int>(json['id'], 0),
      commentCount: parseValue<int>(json['comments_count'], 0),
      sendCount: parseValue<int>(json['share_count'], 0),
      isLiked: parseValue<bool>(json['likes_exists'], false),
      musicName: parseValue<String>(json['music_name'] ?? json['musicName'], ''),
      musicImageUrl: parseValue<String>(
          json['music_image_url'] ?? json['musicImageUrl'], ''),
      description: parseValue<String>(json['description'], ''),
      createdAt: parseValue<String>(json['created_at'], ''),
      updatedAt: parseValue<String>(json['updated_at'], ''),
      user: json['user'] != null
          ? ReelUserModel.fromJson(
              parseValue<Map<String, dynamic>>(json['user'], const {}))
          : null,
    );
  }


  // static packageReels.ReelsModel convertToReelsModel(ReelsEntity data) {
  //
  //   return packageReels.ReelsModel(
  //     url: EndPoints.getImage(data.url),
  //     likeCount: data.likeCount,
  //     commentCount: data.commentCount,
  //     sendCount: data.sendCount,
  //     isLiked: data.isLiked,
  //     musicName: data.musicName,
  //     musicImageUrl: data.musicImageUrl,
  //     description: data.description,
  //     createdAt: data.createdAt,
  //     updatedAt: data.updatedAt,
  //     user: data.user != null
  //         ? packageReels.User(
  //             userName: data.user?.userName,
  //             profileUrl: EndPoints.getImage(data.user?.profileUrl),
  //             createdAt: data.user?.createdAt,
  //             updatedAt: data.user?.updatedAt,
  //             isFollow: data.user?.isFollow,
  //           )
  //         : null,
  //     reelComments: [],
  //   );
  // }
}

class ReelUserModel extends ReelUserEntity {
  const ReelUserModel({
    super.uuid,
    super.id,
    super.userName,
    super.profileUrl,
    super.createdAt,
    super.updatedAt,
    super.isFollow,
  });

  factory ReelUserModel.fromJson(Map<String, dynamic> json) {
    return ReelUserModel(
      id: parseValue<int>(json['id'], 0),
      uuid: parseValue<String>(json['uuid'], ''),
      userName: parseValue<String>(json['name'], ''),
      profileUrl: parseValue<String>(json['image'], ''),
      createdAt: parseValue<String?>(json['createdAt'], ''),
      updatedAt: parseValue<String?>(json['updatedAt'], ''),
      isFollow: parseValue<bool>(json['is_follow'], false),
    );
  }
}

