import 'package:general/src/features/auth/auth.dart';

import '../../../../../reels_viewer/reels_viewer.dart';

class VipCenterModel extends VipCenterEntity {
  const VipCenterModel({
    super.id,
    super.level,
    super.name,
    super.img1,
    super.isBuy,
    super.isUsed,
    super.price,
    super.expire,
    super.targetId,
    super.privilgesData,
  });

  factory VipCenterModel.fromJson(Map<String, dynamic> jsonData) {
    return VipCenterModel(
      id: parseValue<int>(jsonData['id'], 0),
      level: parseValue<int>(jsonData['level'], 0),
      name: parseValue<String>(jsonData['name'], ''),
      img1: parseValue<String>(jsonData['img'], ''),
      price: parseValue<int>(jsonData['price'], 0),
      expire: parseValue<int>(jsonData['expire'], 0),
      targetId: parseValue<int>(jsonData['target_id'], 0),
      isUsed: parseValue<bool>(jsonData['is_used'], false),
      isBuy: parseValue<bool>(jsonData['is_buyed'], false),
      privilgesData: jsonData['privilegs'] is! List
          ? []
          : List<Privilegs>.from(
              (jsonData['privilegs'] as List)
                  .whereType<Map<String, dynamic>>()
                  .map((element) => Privilegs.fromJson(element)),
            ),
    );
  }
}

class Privilegs extends PrivilegsEntity {
  const Privilegs({
    required super.id,
    required super.name,
    required super.title,
    required super.img1,
    required super.img2,
    required super.active,
    super.privileg,
  });

  factory Privilegs.fromJson(Map<String, dynamic> json) {
    return Privilegs(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['name'], ''),
      title: parseValue<String>(json['title'], ''),
      img1: parseValue<String>(json['img1'], ''),
      img2: parseValue<String>(json['img2'], ''),
      active: parseValue<bool>(json['active'], false),
      privileg:
          json['item'] is! Map<String, dynamic> ? null : PrivilegModel.fromJson(json['item']),
    );
  }
}

class PrivilegModel extends PrivilegEntity {
  const PrivilegModel({
    super.id,
    super.name,
    super.title,
    super.image,
  });
  factory PrivilegModel.fromJson(Map<String, dynamic> json) {
    return PrivilegModel(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['name'], ''),
      title: parseValue<String>(json['title'], ''),
      image: parseValue<String>(json['image'], ''),
    );
  }
}
