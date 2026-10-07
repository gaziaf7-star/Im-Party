import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

class ProfileRoomModel extends ProfileRoomEntity {
  const ProfileRoomModel({
    super.image,
    super.gender,
    super.imageId,
    super.birthday,
    super.age,
  });

  factory ProfileRoomModel.fromJson(Map<String, dynamic> map) {
    return ProfileRoomModel(
      image: parseValue<String>(map['image'], ''),
      gender: parseValue<int>(map['gender'], 0),
      imageId: parseValue<String>(map['image_id'], ''),
      birthday: parseValue<String>(map['birthday'], ''),
      age: parseValue<int>(map['age'], 0),
    );
  }
  /* ProfileRoomEntity toEntity() {
    return ProfileRoomEntity(
      image: image,
      gender: gender,
      imageId: imageId,
      birthday: birthday,
      age: age,
    );
  } */
}
