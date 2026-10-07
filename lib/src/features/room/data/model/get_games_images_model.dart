import 'package:equatable/equatable.dart';

class SvgaDataModel extends Equatable {
  final List<PKImages> pkIamges;
  final List<VIPImage> vipImage;
  final DiceModel? diceModel;
  final RpsModel? rpsModel;

  const SvgaDataModel({
    required this.pkIamges,
    required this.vipImage,
    required this.diceModel,
    required this.rpsModel,
  });

  factory SvgaDataModel.fromJason(Map<String, dynamic> json) {
    return SvgaDataModel(
      pkIamges: json['pk_images'] is List
          ? List<PKImages>.from((json['pk_images'] as List).whereType<Map<String, dynamic>>().map((e) => PKImages.fromJason(e)))
          : [],
      vipImage: json['vip_images'] is List
          ? List<VIPImage>.from((json['vip_images'] as List).whereType<Map<String, dynamic>>().map((e) => VIPImage.fromJason(e)))
          : [],
      diceModel: json['dice'] is Map<String, dynamic> ? DiceModel.fromJson(json['dice']) : null,
      rpsModel: json['rps'] is Map<String, dynamic> ? RpsModel.fromJson(json['rps']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pk_images': pkIamges.map((e) => e.toJson()).toList(),
      'vip_images': vipImage.map((e) => e.toJson()).toList(),
      'dice': diceModel?.toJson(),
      'rps': rpsModel?.toJson(),
    };
  }

  @override
  List<Object?> get props => [pkIamges, vipImage, diceModel, rpsModel];
}

class PKImages extends Equatable {
  final int? id;
  final String? name;
  final String? url;

  const PKImages({this.id, this.name, this.url});

  factory PKImages.fromJason(Map<String, dynamic> json) {
    return PKImages(
      id: json['id'],
      name: json['name'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
      };

  @override
  List<Object?> get props => [id, name, url];
}

class VIPImage extends Equatable {
  final int? id;
  final String? name;
  final int? level;
  final String? img;
  final String? frame;
  final int? frameId;
  final String? entro;
  final int? entroId;

  const VIPImage({
    this.id,
    this.name,
    this.level,
    this.img,
    this.frameId,
    this.entroId,
    this.entro,
    this.frame,
  });

  factory VIPImage.fromJason(Map<String, dynamic> json) {
    return VIPImage(
      name: json['name'],
      id: json['id'],
      img: json['img'],
      level: json['level'],
      frame: json['frame'] is Map<String, dynamic> ? json['frame']['img2'] : null,
      entro: json['intro'] is Map<String, dynamic> ? json['intro']['img2'] : null,
      frameId: json['frame'] is Map<String, dynamic> ? json['frame']['id'] : null,
      entroId: json['intro'] is Map<String, dynamic> ? json['intro']['id'] : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'level': level,
        'img': img,
        'frame': frame,
        'frame_id': frameId,
        'intro': entro,
        'intro_id': entroId,
      };

  @override
  List<Object?> get props =>
      [id, name, level, img, frame, frameId, entro, entroId];
}

class DiceModel extends Equatable {
  final int id;
  final String image;

  const DiceModel({required this.id, required this.image});

  factory DiceModel.fromJson(Map<String, dynamic> json) {
    return DiceModel(
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'image': image,
      };

  @override
  List<Object?> get props => [id, image];
}

class RpsModel extends Equatable {
  final int id;
  final String image;

  const RpsModel({required this.id, required this.image});

  factory RpsModel.fromJson(Map<String, dynamic> json) {
    return RpsModel(
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'image': image,
      };

  @override
  List<Object?> get props => [id, image];
}
