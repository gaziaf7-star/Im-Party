import 'package:equatable/equatable.dart';

class ReelCommentEntity extends Equatable {
  final int? id;
  final int? reelId;
  final int? userId;
  final String? comment;
  final String? userProfilePic;
  final String? userName;
  final String? commentTime;

  const ReelCommentEntity({
    this.id,
    this.reelId,
    this.userId,
     this.comment,
     this.userProfilePic,
     this.userName,
     this.commentTime,
  });

  ReelCommentEntity copyWith({
    int? id,
    int? reelId,
    int? userId,
    String? comment,
    String? userProfilePic,
    String? userName,
    String? commentTime,
  }) {
    return ReelCommentEntity(
      id: id ?? this.id,
      reelId: reelId ?? this.reelId,
      userId: userId ?? this.userId,
      comment: comment ?? this.comment,
      userProfilePic: userProfilePic ?? this.userProfilePic,
      userName: userName ?? this.userName,
      commentTime: commentTime ?? this.commentTime,
    );
  }

  @override
  List<Object?> get props => [
    id,
    reelId,
    userId,
    comment,
    userProfilePic,
    userName,
    commentTime,
  ];
}
