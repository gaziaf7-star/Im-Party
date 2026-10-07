import 'package:general/src/core/index.dart';

import '../../../auth/domain/entities/multi_images_entity.dart';

class UserProfileEntity extends Equatable {
  final int? id;
  final int? gender;
  final int? age;
  final String? uuid;
  final String? name;
  final String? image;
  final String? senderLevelImage;
  final String? receiverLevelImage;
  final String? bio;
  final double? distance;
  final bool? isLiked;
  final bool? hasColorName;
  final bool? isFriend;
  final List<MultiImagesEntity>? multiImages;

  const UserProfileEntity({
    this.id,
    this.uuid,
    this.name,
    this.image,
    this.bio,
    this.distance,
    this.isLiked,
    this.hasColorName,
    this.senderLevelImage,
    this.receiverLevelImage,
    this.age,
    this.gender,
    this.multiImages,
    this.isFriend,
  });

  UserProfileEntity copyWith({
    bool? isLiked,
  }) {
    return UserProfileEntity(
      id: id,
      uuid: uuid,
      name: name,
      image: image,
      bio: bio,
      distance: distance,
      hasColorName: hasColorName,
      receiverLevelImage: receiverLevelImage,
      senderLevelImage: senderLevelImage,
      age: age,
      gender: gender,
      isFriend: isFriend,
      multiImages: multiImages,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  @override
  List<Object?> get props => [
        id,
        uuid,
        name,
        image,
        bio,
        distance,
        isLiked,
        hasColorName,
        senderLevelImage,
        receiverLevelImage,
        age,
        gender,
        multiImages,
        isFriend,
      ];
}
