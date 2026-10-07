import 'package:general/src/features/agency/agency.dart';
import '../../../../../reels_viewer/reels_viewer.dart';

class AgencyMemberModel extends AgencyMemberEntity {
  const AgencyMemberModel({
    int super.id = 0,
    String super.uuid = '',
    String super.gender = '',
    int super.diamonds = 0,
    String super.name = '',
    LevelModel super.level = const LevelModel(),
    ProfileModel super.profile = const ProfileModel(),
    bool super.hasColorName = false,
  });

  factory AgencyMemberModel.fromJson(Map<String, dynamic> json) {
    return AgencyMemberModel(
      id: parseValue<int>(json['id'],0) ,
      uuid: parseValue<String>(json['uuid']?.toString(),''),
      gender: parseValue<String>(json['gender']?.toString(),''),
      diamonds: parseValue<int>(json['diamonds'] ,0),
      name: parseValue<String>(json['name']?.toString() ,''),
      level: json['level'] is Map<String, dynamic>
          ? LevelModel.fromJson(json['level'])
          : const LevelModel(),
      profile: json['profile'] is Map<String, dynamic>
          ? ProfileModel.fromJson(json['profile'])
          : const ProfileModel(),
      hasColorName: parseValue<bool>(json['has_color_name'], false),
    );
  }
}

class LevelModel extends LevelEntity {
  const LevelModel({
    String super.receiverImg = '',
    String super.senderImg = '',
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      receiverImg: parseValue<String>(json['receiver_img']?.toString(),'') ,
      senderImg:  parseValue<String>(json['sender_img']?.toString() ,''),
    );
  }
}

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    String super.image = '',
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      image: parseValue<String>(json['image']?.toString(),''),
    );
  }
}




// class AgencyMemberModel extends AgencyMemberEntity {
//   const AgencyMemberModel({
//      super.id,
//      super.uuid,
//      super.gender,
//      super.diamonds,
//      super.name,
//      LevelModel? super.level,
//      ProfileModel? super.profile,
//      super.hasColorName,
//   });
//
//   factory AgencyMemberModel.fromJson(Map<String, dynamic> json) {
//     return AgencyMemberModel(
//       id: json['id'],
//       uuid: json['uuid'],
//       gender: json['gender'].toString(),
//       diamonds: json['diamonds'],
//       name: json['name'],
//       level: json['level'] != null ? LevelModel.fromJson(json['level']) : null,
//       profile: json['profile'] != null ? ProfileModel.fromJson(json['profile']) : null,
//       hasColorName: json['has_color_name'],
//     );
//   }
//
// }
//
// class LevelModel extends LevelEntity {
//   const LevelModel({
//      super.receiverImg,
//      super.senderImg,
//   });
//
//   factory LevelModel.fromJson(Map<String, dynamic> json) {
//     return LevelModel(
//       receiverImg: json['receiver_img'],
//       senderImg: json['sender_img'],
//     );
//   }
// }
//
// class ProfileModel extends ProfileEntity {
//   const ProfileModel({
//      super.image,
//   });
//
//   factory ProfileModel.fromJson(Map<String, dynamic> json) {
//     return ProfileModel(
//       image: json['image'],
//     );
//   }
// }
