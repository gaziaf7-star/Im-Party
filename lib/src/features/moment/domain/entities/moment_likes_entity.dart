import 'package:equatable/equatable.dart';

class MomentLikesEntity extends Equatable {
  final int? userId;
  final String? uuid;
  final String userImage;
  final String userName;
  final String createdAt;
  final String? senderImage;
  final String? receiverImage;
  /*



  String? userImage;
  */

  const MomentLikesEntity({
    required this.userId,
    required this.uuid,
    required this.userImage,
    required this.userName,
    required this.createdAt,
    required this.senderImage,
    required this.receiverImage,
  });

  @override
  List<Object?> get props => [
        userId,
        uuid,
        userImage,
        userName,
        createdAt,
        senderImage,
        receiverImage,
      ];
}
