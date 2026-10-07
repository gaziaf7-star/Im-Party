import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

class MomentEntity extends Equatable {
  final int momentId;
  final int userId;
  final String moment;
  final String momentImage;
  final int commentNum;
  final int likeNum;
  final int giftsCount;
  final int frameId;
  final String frame;
  final List<ImageModel> images;
  final String creeatedTime;
  final String userName;
  final String colorName;
  final String userImage;
  final String uuid;
  final String receiverImage;
  final String senderImage;
  final int vip;
  final int gender;
  final int age;
  final bool hasColorName;
  final bool isLike;
  final bool isFriend;
  final bool isFollow;
  final List<int> typeUser;
  final VipCenterEntity? vipNew;

  const MomentEntity({
    required this.momentId,
    required this.isLike,
    required this.uuid,
    required this.hasColorName,
    required this.receiverImage,
    required this.senderImage,
    required this.vip,
    required this.isFollow,
    required this.gender,
    required this.age,
    required this.userId,
    required this.moment,
    required this.momentImage,
    required this.commentNum,
    required this.likeNum,
    required this.colorName,
    required this.images,
    required this.giftsCount,
    required this.creeatedTime,
    required this.userImage,
    required this.frameId,
    required this.frame,
    required this.userName,
    required this.isFriend,
    required this.typeUser,
    required this.vipNew,
  });

  MomentEntity copyWith({
    int? momentId,
    int? userId,
    String? moment,
    String? colorName,
    String? momentImage,
    List<ImageModel>? images,
    int? commentNum,
    int? likeNum,
    int? giftsCount,
    int? frameId,
    int? gender,
    int? age,
    String? frame,
    String? creeatedTime,
    String? userName,
    String? userImage,
    String? uuid,
    String? receiverImage,
    String? senderImage,
    int? vip,
    bool? hasColorName,
    bool? isLike,
    bool? isFriend,
    bool? isFollow,
    List<int>? typeUser,
    VipCenterEntity? vipNew,
  }) {
    return MomentEntity(
      momentId: momentId ?? this.momentId,
      userId: userId ?? this.userId,
      moment: moment ?? this.moment,
      momentImage: momentImage ?? this.momentImage,
      commentNum: commentNum ?? this.commentNum,
      likeNum: likeNum ?? this.likeNum,
      giftsCount: giftsCount ?? this.giftsCount,
      frameId: frameId ?? this.frameId,
      frame: frame ?? this.frame,
      creeatedTime: creeatedTime ?? this.creeatedTime,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      uuid: uuid ?? this.uuid,
      colorName: colorName ?? this.colorName,
      isFollow: isFollow ?? this.isFollow,
      receiverImage: receiverImage ?? this.receiverImage,
      senderImage: senderImage ?? this.senderImage,
      vip: vip ?? this.vip,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      images: images ?? this.images,
      hasColorName: hasColorName ?? this.hasColorName,
      isLike: isLike ?? this.isLike,
      isFriend: isFriend ?? this.isFriend,
      typeUser: typeUser ?? this.typeUser,
      vipNew: vipNew ?? this.vipNew,
    );
  }

  @override
  List<Object?> get props => [
        momentId,
        isLike,
        uuid,
        isFollow,
        hasColorName,
        receiverImage,
        senderImage,
        vip,
        userId,
        moment,
        momentImage,
        colorName,
        commentNum,
        likeNum,
        giftsCount,
        creeatedTime,
        userImage,
        frameId,
        frame,
        gender,
        age,
        images,
        userName,
        isFriend,
        typeUser,
        vipNew,
      ];
}

class ImageModel {
  final String image;

  ImageModel({required this.image});

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(image: parseValue(json['image'], ''));
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
    };
  }
}
