import 'package:equatable/equatable.dart';

class ReelsEntity extends Equatable {
  final String? url;
  final String? subFrame;
  final int? likeCount;
  final int? id;
  final int? commentCount;
  final int? sendCount;
  final bool? isLiked;
  final String? musicName;
  final String? musicImageUrl;
  final String? description;
  final String? createdAt;
  final String? updatedAt;
  final ReelUserEntity? user;

  const ReelsEntity({
    this.url,
    this.subFrame,
    this.likeCount,
    this.id,
    this.commentCount,
    this.sendCount,
    this.isLiked,
    this.musicName,
    this.musicImageUrl,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  ReelsEntity copyWith({
    String? url,
    String? subFrame,
    int? likeCount,
    int? id,
    int? commentCount,
    int? sendCount,
    bool? isLiked,
    String? musicName,
    String? musicImageUrl,
    String? description,
    String? createdAt,
    String? updatedAt,
    ReelUserEntity? user,
  }) {
    return ReelsEntity(
      url: url ?? this.url,
      subFrame: subFrame ?? this.subFrame,
      likeCount: likeCount ?? this.likeCount,
      id: id ?? this.id,
      commentCount: commentCount ?? this.commentCount,
      sendCount: sendCount ?? this.sendCount,
      isLiked: isLiked ?? this.isLiked,
      musicName: musicName ?? this.musicName,
      musicImageUrl: musicImageUrl ?? this.musicImageUrl,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [
        url,
        subFrame,
        likeCount,
        id,
        commentCount,
        sendCount,
        isLiked,
        musicName,
        musicImageUrl,
        description,
        createdAt,
        updatedAt,
        user,
      ];
}

class ReelUserEntity extends Equatable {
  final String? uuid;
  final int? id;
  final String? userName;
  final String? profileUrl;
  final String? createdAt;
  final String? updatedAt;
  final bool? isFollow;

  const ReelUserEntity({
    this.uuid,
    this.id,
    this.userName,
    this.profileUrl,
    this.createdAt,
    this.updatedAt,
    this.isFollow,
  });

  ReelUserEntity copyWith({
    String? uuid,
    int? id,
    String? userName,
    String? profileUrl,
    String? createdAt,
    String? updatedAt,
    bool? isFollow,
  }) {
    return ReelUserEntity(
      uuid: uuid ?? this.uuid,
      id: id ?? this.id,
      userName: userName ?? this.userName,
      profileUrl: profileUrl ?? this.profileUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFollow: isFollow ?? this.isFollow,
    );
  }

  @override
  List<Object?> get props => [
        uuid,
        id,
        userName,
        profileUrl,
        createdAt,
        updatedAt,
        isFollow,
      ];
}
