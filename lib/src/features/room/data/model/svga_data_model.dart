import 'package:general/src/features/room/domain/entities/svga_data_entity.dart';

class SvgDataModel extends SvgDataEntity {

  const SvgDataModel(
      {required super.pkImages, required super.vipImage, required super.rpsEntity});

  factory SvgDataModel.fromJason(Map<String, dynamic> json) {
    return SvgDataModel(
      rpsEntity: json['rps'] is Map<String, dynamic>
          ? RpsModel.fromJson(json['rps'])
          : null,
      pkImages: json['pk_images'] is List
          ? List<PKImagesModel>.from((json['pk_images'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => PKImagesModel.fromJason(e)))
          : [],
      vipImage: json['vip_images'] is List
          ? List<VIPImageModel>.from((json['vip_images'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => VIPImageModel.fromJason(e)))
          : [],
    );
  }

  @override
  List<Object?> get props => [
    pkImages,
    vipImage,
    rpsEntity,
  ];
}

class PKImagesModel extends PKImagesEntity {

  const PKImagesModel({super.id, super.name, super.url});

  factory PKImagesModel.fromJason(Map<String, dynamic> json) {
    return PKImagesModel(id: json['id'], name: json['name'], url: json['url']);
  }

  @override
  List<Object?> get props => [
    id,
    name,
    url
  ];
}

class VIPImageModel extends VIPImageEntity {

  const VIPImageModel(
      {super.id,
      super.name,
      super.level,
      super.img,
      super.frameId,
      super.introId,
      super.intro,
      super.frame});

  factory VIPImageModel.fromJason(Map<String, dynamic> json) {
    return VIPImageModel(
        name: json['name'],
        id: json['id'],
        img: json['img'],
        level: json['level'],
        frame: json['frame'] is Map<String, dynamic> ? json['frame']['img2'] : null,
        intro: json['intro'] is Map<String, dynamic> ? json['intro']['img2'] : null,
        frameId: json['frame'] is Map<String, dynamic> ? json['frame']['id'] : null,
        introId: json['intro'] is Map<String, dynamic> ? json['intro']['id'] : null);
  }

  @override
  List<Object?> get props => [
    id,
    name,
    level,
    img,
    frameId,
    introId,
    intro,
    frame
  ];
}

class RpsModel extends  RpsEntity{

  const RpsModel({required super.id, required super.image});

  factory RpsModel.fromJson(Map<String, dynamic> json) {
    return RpsModel(
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
    id,
    image,
  ];
}
