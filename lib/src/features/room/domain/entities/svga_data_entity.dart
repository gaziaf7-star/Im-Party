import 'package:equatable/equatable.dart';

class SvgDataEntity extends Equatable {
  final List<PKImagesEntity> pkImages;

  final List<VIPImageEntity> vipImage;

  final RpsEntity? rpsEntity;

  const SvgDataEntity(
      {required this.pkImages, required this.vipImage, required this.rpsEntity});


  @override
  List<Object?> get props => [
    pkImages,
    vipImage,
    rpsEntity,
  ];
}

class PKImagesEntity extends Equatable {
  final int? id;
  final String? name;
  final String? url;

  const PKImagesEntity({this.id, this.name, this.url});


  @override
  List<Object?> get props => [
    id,
    name,
    url
  ];
}

class VIPImageEntity extends Equatable {
  final int? id;
  final String? name;
  final int? level;
  final String? img;
  final String? frame;
  final int? frameId;
  final String? intro;
  final int? introId;

  const VIPImageEntity(
      {this.id,
      this.name,
      this.level,
      this.img,
      this.frameId,
      this.introId,
      this.intro,
      this.frame});


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

class RpsEntity extends Equatable {
  final int id;
  final String image;

  const RpsEntity({required this.id, required this.image});

  @override
  List<Object?> get props => [
    id,
    image,
  ];
}
