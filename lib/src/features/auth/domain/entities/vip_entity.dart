import 'package:equatable/equatable.dart';

class VipCenterEntity extends Equatable {
  final int? id;
  final int? level;
  final String? name;
  final String? img1;
  final String? oldImage;
  final String? color;
  final String? colorName;
  final int? price;
  final int? expire;
  final int? targetId;
  final bool? isUsed;
  final bool? isBuy;
  final bool? vipGifts;
  final bool? isUploadGif;
  final List<PrivilegsEntity>? privilgesData;

  VipCenterEntity copyWith({
    bool? isUsed,
  }) {
    return VipCenterEntity(
      isUsed: isUsed ?? this.isUsed,
      id: id,
      level: level,
      name: name,
      img1: img1,
      price: price,
      expire: expire,
      targetId: targetId,
      isBuy: isBuy,
      vipGifts: vipGifts,
      isUploadGif: isUploadGif,
      color: color,
      colorName: colorName,
    );
  }

  const VipCenterEntity({
    this.id,
    this.level,
    this.isUsed,
    this.isBuy,
    this.vipGifts,
    this.isUploadGif,
    this.name,
    this.img1,
    this.price,
    this.expire,
    this.privilgesData,
    this.targetId,
    this.oldImage,
    this.color,
    this.colorName,
  });

  @override
  List<Object?> get props => [
        id,
        level,
        name,
        isBuy,
        vipGifts,
        isUploadGif,
        isUsed,
        img1,
        price,
        expire,
        targetId,
        privilgesData,
        oldImage,
        color,
        colorName,
      ];
}

class PrivilegsEntity extends Equatable {
  final int id;
  final String name;
  final String title;
  final String img1;
  final String img2;
  final bool active;
  final PrivilegEntity? privileg;

  const PrivilegsEntity({
    required this.id,
    required this.name,
    required this.title,
    required this.img1,
    required this.img2,
    required this.active,
    this.privileg,
  });

  @override
  List<Object?> get props => [id, name, title, img1, img2, active, privileg];
}

class PrivilegEntity extends Equatable {
  final int? id;
  final String? name;
  final String? title;
  final String? image;
  final String? imageType;
  final String? svg;

  const PrivilegEntity(
      {this.id, this.name, this.title, this.image, this.imageType, this.svg});

  @override
  List<Object?> get props => [id, name, title, image, imageType, svg];
}
