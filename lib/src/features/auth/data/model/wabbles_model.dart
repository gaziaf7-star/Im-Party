import 'package:general/src/core/index.dart';

class WabblesModel extends Equatable {
  final int? id;
  final String? image;
  final String? imageType;
  final Map<String, dynamic>? keyJson;

  const WabblesModel({
    this.id,
    this.image,
    this.imageType,
    this.keyJson,
  });

  factory WabblesModel.fromJson(Map<String, dynamic> json) {
    return WabblesModel(
      id: parseValue<int>(json['id'], 0),
      image: parseValue<String>(json['img'], ''),
      imageType: parseValue<String>(json['image_type'], ''),
      keyJson: json['key_json'] != null
          ? Map<String, dynamic>.from(json['key_json'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'img': image,
        'image_type': imageType,
        'key_json': keyJson,
      };

  @override
  List<Object?> get props => [id, image, imageType, keyJson];
}
