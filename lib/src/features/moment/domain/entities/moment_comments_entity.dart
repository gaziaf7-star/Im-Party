import 'package:equatable/equatable.dart';

class MomentCommentsEntity extends Equatable {
  final int? commentId;
  final int? momentId;
  final int? userId;
  final String? uuid;
  final String comment;
  final String userProfilePic;
  final String userName;
  final String commentTime;

  const MomentCommentsEntity({
    required this.commentId,
    required this.momentId,
    required this.userId,
    required this.uuid,
    required this.comment,
    required this.userProfilePic,
    required this.userName,
    required this.commentTime,
  });

  @override
  List<Object?> get props => [
        commentId,
        momentId,
        userId,
        uuid,
        comment,
        userProfilePic,
        userName,
        commentTime
      ];
}
