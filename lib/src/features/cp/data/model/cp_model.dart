
import 'package:general/src/features/cp/domain/entities/cp_entity.dart';

import '../../../../core/index.dart';

class CpModel extends CpEntity {
  const CpModel({super.firstThree, super.others, super.user});

  factory CpModel.fromJson(Map<String, dynamic> json) {
    return CpModel(
      user: json['user'] is Map<String, dynamic>
          ? MyUserCpModel.fromJson(json['user'])
          : null,
      firstThree: json['firstThree'] is List
          ? List<CpUserRank>.from((json['firstThree'] as List)
              .whereType<Map<String, dynamic>>()
              .map((v) => CpUserRank.fromJson(v)))
          : null,
      others: json['remain'] is List
          ? List<CpUserRank>.from((json['remain'] as List)
              .whereType<Map<String, dynamic>>()
              .map((v) => CpUserRank.fromJson(v)))
          : null,
    );
  }
}

class CpUserRank extends CpUserRankEntity {
  const CpUserRank(
      {super.id, super.level, super.exp, super.userOne, super.userTwo});

  factory CpUserRank.fromJson(Map<String, dynamic> json) {
    return CpUserRank(
      id: parseValue<int>(json['id'], 0),
      level: json['level'] is Map<String, dynamic>
          ? Level.fromJson(json['level'])
          : null,
      exp: parseValue<double>(json['exp'].toDouble(), 0),
      userOne: json['userOne'] is Map<String, dynamic>
          ? User.fromJson(json['userOne'])
          : null,
      userTwo: json['userTwo'] is Map<String, dynamic>
          ? User.fromJson(json['userTwo'])
          : null,
    );
  }
}

class Level extends LevelEntity {
  const Level({super.id, super.img});

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: parseValue<int>(json['id'], 0),
      img: parseValue<String>(json['img'], ''),
    );
  }
}

class User extends UserCpEntity {
  const User({
    super.id,
    super.uid,
    super.name,
    super.image,
    super.gender,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: parseValue<int>(json['id'], 0),
      uid: parseValue<String>(json['uid'], ''),
      name: parseValue<String>(json['name'], ''),
      image: parseValue<String>(json['image'], ''),
      gender: parseValue<int>(json['gender'], 0),
    );
  }
}

class MyUserCpModel extends MyUserCpEntity {
  const MyUserCpModel(
      {super.id,
      super.uuid,
      super.name,
      super.image,
      super.exp,
      super.senderImage,
      super.receiverImage,
      super.otherUserCpEntity});

  factory MyUserCpModel.fromJson(Map<String, dynamic> json) {
    return MyUserCpModel(
      id: parseValue<int>(json['id'], 0),
      exp: parseValue<int>(json['exp'], 0),
      uuid: parseValue<String>(json['uuid'], ''),
      name: parseValue<String>(json['name'], ''),
      image: parseValue<String>(json['image'], ''),
      receiverImage: parseValue<String>(json['reciver_level_img'], ''),
      senderImage: parseValue<String>(json['sender_level_img'], ''),
      otherUserCpEntity: (json['other'] is Map<String, dynamic>)
          ? OtherUserCpModel.fromJson(json['other'])
          : null,
    );
  }
}

class OtherUserCpModel extends OtherUserCpEntity {
  const OtherUserCpModel({
    super.id,
    super.uuid,
    super.name,
    super.image,
  });

  factory OtherUserCpModel.fromJson(Map<String, dynamic> json) {
    return OtherUserCpModel(
      id: parseValue<int>(json['id'], 0),
      uuid: parseValue<int>(json['uuid'], 0),
      name: parseValue<String>(json['name'], ''),
      image: parseValue<String>(json['image'], ''),
    );
  }
}
