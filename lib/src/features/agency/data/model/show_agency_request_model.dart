import 'package:general/src/features/agency/agency.dart';

import '../../../../../reels_viewer/reels_viewer.dart';

class ShowAgencyRequestModel extends ShowAgencyRequestModelEntity {
  const ShowAgencyRequestModel({
    super.id,
    super.uuid,
    super.diamonds,
    super.name,
    Level? super.level,
    Profile? super.profile,
    super.hasColorName,
    super.status,
    super.operator,
    super.date,
  });

  factory ShowAgencyRequestModel.fromJson(Map<String, dynamic> json) {
    return ShowAgencyRequestModel(
      id:parseValue<int>(json['id'],0)  ,
      uuid: parseValue<String>(json['uuid'] ,''),
      diamonds: parseValue<int>(json['diamonds'],0) ,
      name:parseValue<String>(json['name'],'') ,
      level: json['level'] is Map<String, dynamic> ? Level.fromJson(json['level']) : null,
      profile:
          json['profile'] is Map<String, dynamic> ? Profile.fromJson(json['profile']) : null,
      hasColorName: parseValue<bool>(json['has_color_name'], false) ,
      status:parseValue<int>(json['status'],0)  ,
      operator:parseValue<String>(json['operator'],'') ,
      date:parseValue<String>(json['date'],'')  ,
    );
  }
}

class Level extends LevelEntity {
  const Level({super.receiverImg, super.senderImg});

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      receiverImg: parseValue<String>(json['receiver_img'],'') ,
      senderImg:parseValue<String>(json['sender_img'],'')  ,
    );
  }
}

class Profile extends ProfileEntity {
  const Profile({super.image});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      image:parseValue<String>(json['image'],'')  ,
    );
  }
}
