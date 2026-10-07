import 'package:general/src/core/index.dart';

import '../../domain/entities/multi_images_entity.dart';

class MultiImagesModel extends MultiImagesEntity {
  const MultiImagesModel({
    required super.img,
    required super.id,
  });

  factory MultiImagesModel.fromJson(Map<String, dynamic> json) {
    return MultiImagesModel(
      img: parseValue<String>(json['img'], ''),
      id: parseValue<int>(json['id'], 0),
    );
  }
}
