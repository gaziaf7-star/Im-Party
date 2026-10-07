import 'package:general/src/features/mall_bag/mall_bag.dart';

import '../../../../core/utils/methods.dart';

class MallModel extends MallEntity {
  const MallModel({
     super.id,
     super.name,
     super.title,
     super.price,
     super.color,
     super.expire,
     super.image,
     super.svg,
     required super.imageType,
  });

  factory MallModel.fromJson(Map<String, dynamic> json) {
    return MallModel(
      id: parseValue<String>(json['id'], ''),
      name: parseValue<String>(json['name'], ''),
      title: parseValue<String>(json['title'], ''),
      price: parseValue<int>(json['price'], 0),
      color: parseValue<String>(json['color'], ''),
      expire: parseValue<int>(json['expire'], 0),
      image: parseValue<String>(json['image'], ''),
      svg: parseValue<String>(json['svg'], ''),
      imageType: parseValue<String>(json['image_type'], ''),
    );
  }
}
