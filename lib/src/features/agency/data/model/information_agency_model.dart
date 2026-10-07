import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';

class InformationAgencyModel extends InformationAgencyEntity {
  const InformationAgencyModel({
    super.id,
    super.name,
    super.img,
    super.bio,
    super.owner,
    super.stars,
    super.admins,
    super.heroes,
    super.userStates,
  });

  factory InformationAgencyModel.fromJson(Map<String, dynamic> json) {
    return InformationAgencyModel(
      id: parseValue<int>(json['id'], 0),
      userStates: parseValue<int>(json['user_agency_status'], 0),
      name: parseValue<String>(json['name'], ''),
      img: parseValue<String>(json['img'], ''),
      bio: parseValue<String>(json['bio'], ''),
      owner: json['owner'] is Map<String, dynamic>
          ? OwnerModel.fromJson(json['owner'])
          : null,
      stars: parseValue<List<StarModel>>(
        json['star'],
        [],
        customParser: (value) {
          if (value is List) {
            return value
                .whereType<Map<String, dynamic>>()
                .map((item) => StarModel.fromJson(item))
                .toList();
          }
          return [];
        },
      ).cast<StarEntity>(),
      heroes: parseValue<List<StarModel>>(
        json['heroes'],
        [],
        customParser: (value) {
          if (value is List) {
            return value
                .whereType<Map<String, dynamic>>()
                .map((item) => StarModel.fromJson(item))
                .toList();
          }
          return [];
        },
      ).cast<StarEntity>(),
      admins: parseValue<List<StarModel>>(
        json['admins'],
        [],
        customParser: (value) {
          if (value is List) {
            return value
                .whereType<Map<String, dynamic>>()
                .map((item) => StarModel.fromJson(item))
                .toList();
          }
          return [];
        },
      ).cast<StarEntity>(),
    );
  }
}

class OwnerModel extends TheOwnerEntity {
  const OwnerModel({
    super.id,
    super.uuid,
    super.diamonds,
    super.name,
    super.phone,
    super.country,
    super.level,
    super.profile,
    super.hasColorName,
    super.gender,
    super.coloredName,
  });

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      id: parseValue<int>(json['id'], 0),
      uuid: parseValue<String>(json['uuid'], ''),
      diamonds: parseValue<int>(json['diamonds'], 0),
      name: parseValue<String>(json['name'], ''),
      phone: parseValue<String>(json['phone'], ''),
      coloredName: parseValue<String>(json['colored_name'], ''),
      country: json['country'] is Map<String, dynamic>
          ? TheCountryModel.fromJson(json['country'])
          : null,
      level: json['level'] is Map<String, dynamic>
          ? MemberLevelModel.fromJson(json['level'])
          : null,
      profile: json['profile'] is Map<String, dynamic>
          ? ProfileModel.fromJson(json['profile'])
          : null,
      hasColorName: parseValue<bool>(json['has_color_name'], false),
      gender: parseValue<int>(json['gender'], 0),
    );
  }
}

class TheCountryModel extends TheCountryEntity {
  const TheCountryModel({
    super.id,
    super.name,
    super.flag,
    super.language,
    super.eName,
    super.phoneCode,
    super.iso,
  });

  factory TheCountryModel.fromJson(Map<String, dynamic> json) {
    return TheCountryModel(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['name'], ''),
      flag: parseValue<String>(json['flag'], ''),
      language: parseValue<String>(json['language'], ''),
      eName: parseValue<String>(json['e_name'], ''),
      phoneCode: parseValue<String>(json['phone_code'], ''),
      iso: parseValue<String>(json['iso'], ''),
    );
  }
}

class MemberLevelModel extends MemberLevelEntity {
  const MemberLevelModel({
    super.receiverImg,
    super.senderImg,
  });

  factory MemberLevelModel.fromJson(Map<String, dynamic> json) {
    return MemberLevelModel(
      receiverImg: parseValue<String>(json['receiver_img'], ''),
      senderImg: parseValue<String>(json['sender_img'], ''),
    );
  }
}

class ProfileModel extends MemberProfileEntity {
  const ProfileModel({super.image});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      image: parseValue<String>(json['image'], ''),
    );
  }
}

class StarModel extends StarEntity {
  const StarModel({
    super.id,
    super.uuid,
    super.name,
    super.image,
    super.exp,
    super.levels,
    super.coloredName,
    super.idImage,
  });

  factory StarModel.fromJson(Map<String, dynamic> json) {
    return StarModel(
      id: parseValue<int>(json['id'], 0),
      uuid: parseValue<String>(json['uuid'], ''),
      name: parseValue<String>(json['name'], ''),
      image: parseValue<String>(json['image'], ''),
      coloredName: parseValue<String>(json['colored_name'], ''),
      idImage: parseValue<String>(json['id_image'], ''),
      exp: parseValue<String>(json['exp'], ''),
      levels: json['level'] is Map<String, dynamic>
          ? MemberLevelModel.fromJson(json['level'])
          : null,
    );
  }
}
