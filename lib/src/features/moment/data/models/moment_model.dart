import 'package:general/src/features/moment/domain/entities/moment_entity.dart';

import '../../../../core/utils/methods.dart';
import '../../../auth/data/model/vip_model.dart';

class MomentModel extends MomentEntity {
  const MomentModel({
    required super.momentId,
    required super.isLike,
    required super.uuid,
    required super.colorName,
    required super.hasColorName,
    required super.receiverImage,
    required super.senderImage,
    required super.vip,
    required super.userId,
    required super.moment,
    required super.momentImage,
    required super.commentNum,
    required super.likeNum,
    required super.giftsCount,
    required super.creeatedTime,
    required super.userImage,
    required super.frameId,
    required super.frame,
    required super.userName,
    required super.isFollow,
    required super.gender,
    required super.age,
    required super.isFriend,
    required super.images,
    required super.typeUser,
    required super.vipNew,
  });

  factory MomentModel.fromEntity(MomentEntity entity) {
    return MomentModel(
      momentId: entity.momentId,
      userId: entity.userId,
      moment: entity.moment,
      momentImage: entity.momentImage,
      commentNum: entity.commentNum,
      likeNum: entity.likeNum,
      giftsCount: entity.giftsCount,
      creeatedTime: entity.creeatedTime,
      userImage: entity.userImage,
      userName: entity.userName,
      uuid: entity.uuid,
      colorName: entity.colorName,
      isFollow: entity.isFollow,
      isLike: entity.isLike,
      isFriend: entity.isFriend,
      frameId: entity.frameId,
      frame: entity.frame,
      vip: entity.vip,
      age: entity.age,
      gender: entity.gender,
      hasColorName: entity.hasColorName,
      receiverImage: entity.receiverImage,
      senderImage: entity.senderImage,
      images: entity.images,
      typeUser: entity.typeUser,
      vipNew: entity.vipNew,
    );
  }

  factory MomentModel.fromJson(Map<String, dynamic> jsonData) {
    final Map<String, dynamic> userJson =
        jsonData['user'] is Map<String, dynamic> ? jsonData['user'] as Map<String, dynamic> : {};
    return MomentModel(
      momentId: parseValue<int>(jsonData['id'], 0),
      userId: parseValue<int>(jsonData['user_id'], 0),
      moment: parseValue<String>(jsonData['description'], ''),
      momentImage: parseValue<String>(jsonData['img'], ''),
      commentNum: parseValue<int>(jsonData['comment_num'], 0),
      likeNum: parseValue<int>(jsonData['like_num'], 0),
      giftsCount: parseValue<int>(jsonData['gifts_count'], 0),
      creeatedTime: parseValue<String>(jsonData['created_at'], ''),
      userImage: parseValue<String>(userJson['image'], ''),
      userName: parseValue<String>(userJson['name'], ''),
      uuid: parseValue<String>(userJson['uuid'], ''),
      colorName: parseValue<String>(userJson['color_name'], ''),
      gender: parseValue<int>(userJson['gender'], 1),
      vip: parseValue<int>(userJson['vip'], 0),
      age: parseValue<int>(userJson['age'], 0),
      isFollow: parseValue<bool>(userJson['is_follow'], false),
      isFriend: parseValue<bool>(userJson['is_friend'], false),
      isLike: parseValue<bool>(jsonData['is_like'], false),
      images: (jsonData['images'] is List ? jsonData['images'] as List : const [])
          .whereType<Map<String, dynamic>>()
          .map((imageJson) => ImageModel.fromJson(imageJson))
          .toList(),
      senderImage: parseValue<String>(userJson['sender_img'], ''),
      receiverImage: parseValue<String>(userJson['receiver_img'], ''),
      hasColorName: parseValue<bool>(userJson['has_color_name'], false),
      frameId: parseValue<int>(userJson['frame_id'], 0),
      frame: parseValue<String>(userJson['frame'], ''),
      typeUser:  parseValue<List<int>>(userJson['user_types'], []),
      vipNew: userJson['new_vip'] is Map<String, dynamic> ? VipCenterModel.fromJson(userJson['new_vip']) : null,
     /* vipNew: parseValue<VipCenterModel>(
        userJson['new_vip'],
        {},
        customParser: (data) => VipCenterModel.fromJson(data),
      ),*/
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};

    map['id'] = momentId;
    map['user_id'] = userId;
    map['description'] = moment;
    map['img'] = momentImage;
    map['comment_num'] = commentNum;
    map['like_num'] = likeNum;
    map['gifts_count'] = giftsCount;
    map['created_at'] = creeatedTime;
    map['is_like'] = isLike;

    // تحويل الصور لقائمة من JSON
    map['images'] = images.map((e) => e.toJson()).toList();

    // بيانات المستخدم
    final userMap = <String, dynamic>{};
    userMap['image'] = userImage;
    userMap['name'] = userName;
    userMap['uuid'] = uuid;
    userMap['color_name'] = colorName;
    userMap['is_follow'] = isFollow;
    userMap['age'] = age;
    userMap['gender'] = gender;
    userMap['sender_img'] = senderImage;
    userMap['receiver_img'] = receiverImage;
    userMap['has_color_name'] = hasColorName;
    userMap['frame_id'] = frameId;
    userMap['frame'] = frame;
    userMap['user_types'] = typeUser;
  /*  if (vipNew != null) {
      userMap['new_vip'] = vipNew!.toJson();
    }*/

    map['user'] = userMap;

    return map;
  }


}

