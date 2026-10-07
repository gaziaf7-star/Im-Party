import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

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
    super.privilgesData,
    super.oldImage,
    super.color,
    super.colorName,
    super.vipGifts,
    super.isUploadGif,
  });

  factory VipCenterModel.fromJson(Map<String, dynamic> jsonData) {
    return VipCenterModel(
      id: parseValue<int>(jsonData['id'], 0),
      level: parseValue<int>(jsonData['level'], 0),
      name: parseValue<String>(jsonData['name'], ''),
      img1: parseValue<String>(jsonData['vip_img'], ''),
      color: jsonData['color'] == null || jsonData['color'] == "NULL"
          ? ""
          : parseValue<String>(jsonData['color'], ''),
      colorName:
          jsonData['colored_name'] == null || jsonData['colored_name'] == "NULL"
              ? ""
              : parseValue<String>(jsonData['colored_name'], ''),
      oldImage: parseValue<String>(jsonData['img_old'], ''),
      isUsed: parseValue<bool>(jsonData['is_used'], false),
      vipGifts: parseValue<bool>(jsonData['vip_gifts'], false),
      isBuy: parseValue<bool>(jsonData['is_buyed'], false),
      price: parseValue<int>(jsonData['price'], 0),
      expire: parseValue<int>(jsonData['expire'], 0),
      isUploadGif: parseValue<bool>(jsonData['vip_upload_gif'], false),
      privilgesData: jsonData['privilegs'] == null
          ? parseValue<List<Privilegs>>(
              jsonData['privilegs'],
              [],
              customParser: (value) {
                if (value is List) {
                  return value
                      .map((item) =>
                          Privilegs.fromJson(item as Map<String, dynamic>))
                      .toList();
                }
                return [];
              },
            )
          : null,
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
      privileg: json['item'] is Map<String, dynamic>
          ? PrivilegModel.fromJson(json['item'])
          : null,
    );
  }
}

class PrivilegModel extends PrivilegEntity {
  const PrivilegModel(
      {super.id,
      super.name,
      super.title,
      super.image,
      super.imageType,
      super.svg});

  factory PrivilegModel.fromJson(Map<String, dynamic> json) {
    return PrivilegModel(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['name'], ''),
      title: parseValue<String>(json['title'], ''),
      image: parseValue<String>(
          json['svg'], parseValue<String>(json['image'], '')),
      imageType: parseValue<String>(json['image_type'], ''),
      svg: parseValue<String>(json['svg'], ''),
    );
  }
}
