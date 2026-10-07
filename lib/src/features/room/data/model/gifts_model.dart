import 'package:general/src/features/room/domain/entities/gifts_entity.dart';

import '../../../../core/utils/methods.dart';

class GiftsModel extends GiftsEntity {
  const GiftsModel({
    required super.id,
    required super.name,
    required super.type,
    required super.img,
    required super.showImg,
    required super.price,
    required super.showImg2,
    required super.vipLevel,
    required super.musicGift,
    required super.giftType,
    required super.expiry,
    required super.quantity,
    required super.isMusic,
  });

  factory GiftsModel.fromJson(Map<String, dynamic> json) {
    return GiftsModel(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['name'], 'no_name'),
      type: parseValue<String>(json['type'], ''),
      vipLevel: parseValue<int>(json['vip_level'], 0),
      price: parseValue<int>(json['price'], 0),
      img: parseValue<String>(json['img'], ''),
      showImg: parseValue<String>(json['show_img'], ''),
      showImg2: parseValue<String>(json['show_img2'], ''),
      musicGift: parseValue<int>(json['music_gift'], 0),
      expiry: parseValue<int>(json['expire'], 0),
      quantity: parseValue<int>(json['quantity'], 0),
      giftType: parseValue<String>(json['image_type'], ''),
      isMusic: parseValue<int>(json['music_gift'], 0),
    );
  }
}
