import 'package:equatable/equatable.dart';

class VipBagItemEntity extends Equatable {
  final int? targetId;
  final bool? isBuyed;
  final bool? isUsed;
  final bool? using;
  final String? expire;
  final String? remainingTime;
  final VipEntity? vip;

  const VipBagItemEntity(
      {this.targetId,
      this.isBuyed,
      this.isUsed,
      this.using,
      this.expire,
      this.remainingTime,
      this.vip});

  VipBagItemEntity copyWith({
    bool? using,
    bool? isUsed,
  }) {
    return VipBagItemEntity(
      targetId: targetId,
      isBuyed: isBuyed,
      using: using ?? this.using,
      isUsed: isUsed ?? this.isUsed,
      expire: expire,
      remainingTime: remainingTime,
      vip: vip,
    );
  }

  @override
  List<Object?> get props =>
      [targetId, isBuyed, isUsed, using, expire, remainingTime, vip];
}

class VipEntity extends Equatable {
  int? id;
  int? level;
  int? sort;
  String? name;
  String? img;
  int? price;
  int? expire;
  int? exp;
  List<PrivilegsEntity>? privilegs;

  VipEntity(
      {this.id,
      this.level,
      this.sort,
      this.name,
      this.img,
      this.price,
      this.expire,
      this.exp,
      this.privilegs});

  @override
  List<Object?> get props =>
      [id, level, sort, name, img, price, expire, exp, privilegs];
}

class PrivilegsEntity extends Equatable {
  int? id;
  String? name;
  bool? active;
  int? type;
  String? title;
  String? img1;
  String? img2;
  ItemEntity? item;

  PrivilegsEntity(
      {this.id,
      this.name,
      this.active,
      this.type,
      this.title,
      this.img1,
      this.img2,
      this.item});

  @override
  List<Object?> get props => [id, name, active, type, title, img1, img2, item];
}

class ItemEntity extends Equatable {
  int? id;
  String? name;
  String? title;
  int? price;
  String? color;
  int? expire;
  String? image;
  String? img;
  String? svg;
  String? video;
  String? imageType;
  int? type;

  ItemEntity({
    this.id,
    this.name,
    this.title,
    this.price,
    this.color,
    this.expire,
    this.image,
    this.img,
    this.svg,
    this.video,
    this.imageType,
    this.type,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        title,
        price,
        color,
        expire,
        image,
        img,
        svg,
        video,
        imageType,
        type
      ];
}
