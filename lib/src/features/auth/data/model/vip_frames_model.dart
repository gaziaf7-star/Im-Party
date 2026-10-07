import 'package:general/src/core/index.dart';

class VipFramesModel extends Equatable {
  final int? id;
  final String? image;
  final int? level;
  final String? imageType;
  final bool? isHalfFrame;

  const VipFramesModel({
    this.id,
    this.image,
    this.level,
    this.imageType,
    this.isHalfFrame,
  });

  factory VipFramesModel.fromJson(Map<String, dynamic> json) {
    return VipFramesModel(
      id: parseValue<int>(json['id'], 0),
      image: parseValue<String>(json['img2'], ''),
      level: parseValue<int>(json['level'], 0),
      imageType: parseValue<String>(json['image_type'], ''),
      isHalfFrame: parseValue<bool>(json['half_image_profile'], false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'img2': image,
      'level': level,
      'half_image_profile': isHalfFrame,
      'image_type': imageType,
    };
  }

  @override
  List<Object?> get props => [id, image, level, imageType, isHalfFrame];
}
