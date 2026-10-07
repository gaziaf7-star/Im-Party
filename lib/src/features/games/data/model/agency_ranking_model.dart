import 'package:general/src/core/utils/methods.dart';
import 'package:general/src/features/games/domain/entities/agency_ranking_entity.dart';

class AgencyRankingModel extends AgencyRankingEntity {
  const AgencyRankingModel({
    required super.exp,
    required super.id,
    required super.target,
    required super.name,
    required super.notice,
    required super.phone,
    required super.img,
    required super.owner,
  });

  factory AgencyRankingModel.fromJson(Map<String, dynamic> json) {
    return AgencyRankingModel(
      exp: parseValue<String>(json['exp'], ''),
      id: parseValue<int>(json['id'], 0),
      target: parseValue<double>(json['target'], 0.0),
      name: parseValue<String>(json['name'], ''),
      notice: parseValue<String>(json['notice'], ''),
      phone: parseValue<String>(json['phone'], ''),
      img: parseValue<String>(json['img'], ''),
      owner: OwnerModel.fromJson(parseValue<Map<String, dynamic>>(json['owner'], {})),
    );
  }
}

class OwnerModel extends Owner {
  const OwnerModel({
    required super.id,
    required super.uuid,
    required super.diamonds,
    required super.name,
    required super.vip,
    required super.level,
    required super.profile,
    required super.hasColorName,
    required super.gender,
  });

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      id: parseValue<int>(json['id'], 0),
      uuid: parseValue<String>(json['uuid'], ''),
      diamonds: parseValue<int>(json['diamonds'], 0),
      name: parseValue<String>(json['name'], ''),
      vip: Vip.fromJson(parseValue<Map<String, dynamic>>(json['vip'], {})),
      level: LevelModel.fromJson(parseValue<Map<String, dynamic>>(json['level'], {})),
      profile: ProfileModel.fromJson(parseValue<Map<String, dynamic>>(json['profile'], {})),
      hasColorName: parseValue<bool>(json['has_color_name'], false),
      gender: parseValue<int>(json['gender'], 0),
    );
  }
}

class VipModel extends Vip {
  const VipModel();

  factory VipModel.fromJson(Map<String, dynamic> json) {
    return const VipModel();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}

class LevelModel extends Level {
  const LevelModel({
    required super.receiverImg,
    required super.senderImg,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      receiverImg: parseValue<String>(json['receiver_img'], ''),
      senderImg: parseValue<String>(json['sender_img'], ''),
    );
  }
}

class ProfileModel extends Profile {
  const ProfileModel({required super.image});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      image: parseValue<String>(json['image'], ''),
    );
  }
}
