import 'package:general/src/features/games/domain/entities/user_profile_entity.dart';

import '../../../../core/utils/methods.dart';
import '../../../auth/data/model/multi_images_model.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    super.id,
    super.uuid,
    super.name,
    super.image,
    super.bio,
    super.distance,
    super.isLiked,
    super.hasColorName,
    super.senderLevelImage,
    super.receiverLevelImage,
    super.age,
    super.isFriend,
    super.gender,
    super.multiImages,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: parseValue<int>(json['id'], 0),
      gender: parseValue<int>(json['gender'], 0),
      age: parseValue<int>(json['age'], 0),
      uuid: parseValue<String>(json['uuid'], ''),
      name: parseValue<String>(json['name'], ''),
      image: parseValue<String>(json['image'], ''),
      senderLevelImage: parseValue<String>(json['sender_level_img'], ''),
      receiverLevelImage: parseValue<String>(json['reciver_level_img'], ''),
      bio: parseValue<String>(json['bio'], ''),
      isFriend: parseValue<bool>(json['isFriend'], false),
      distance: parseValue<double>(json['distance'], 0.0),
      isLiked: parseValue<bool>(json['liked'], false),
      hasColorName: parseValue<bool>(json['has_color_name'], false),
      multiImages: json['multi_images'] is List
          ? (json['multi_images'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => MultiImagesModel.fromJson(e))
          .toList()
          : null,
    );
  }

}
