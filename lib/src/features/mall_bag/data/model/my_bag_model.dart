import 'package:general/src/features/mall_bag/mall_bag.dart';

import '../../../../core/utils/methods.dart';

class MyBagModel extends MyBagEntity {
  const MyBagModel({
    required super.name,
    required super.isDress,
    required super.isUsed,
    required super.expire,
    required super.id,
    required super.image,
    required super.type,
    required super.targetId,
    required super.svg,
    required super.use,
    required super.using,
    required super.imageType,
  });

  factory MyBagModel.fromJson(Map<String, dynamic> json) {
    return MyBagModel(
      name: parseValue<String>(json['name'], ''),
      isDress: parseValue<int>(json['is_dress'], 0),
      using: parseValue<int>(json['using'], 0),
      isUsed: parseValue<bool>(json['is_used'], false),
      targetId: parseValue<int>(json['target_id'], 0),
      expire:parseValue<String>(json['expire'], ''),
      id: parseValue<int>(json['id'], 0),
      image: parseValue<String>(json['show_img'], ''),
      type: parseValue<String>(json['type'], ''),
      imageType: parseValue<String>(json['image_type'], ''),
      svg: json.containsKey('svg') ? parseValue<String>(json['svg'], '') : '',
      use: json.containsKey('use')
          ? parseValue<bool>(json['use'], false)
          : false,
    );
  }
}
