import 'package:equatable/equatable.dart';

class GiftsEntity extends Equatable {
  final int? id;
  final String? name;
  final String? type;
  final String? img;
  final String? showImg;
  final String? showImg2;
  final String? giftType;
  final int? isMusic;
  final int? price;
  final int? vipLevel;
  final int? musicGift;
  final int? expiry;
  final int? quantity;

  const GiftsEntity({
    this.id,
    this.name,
    this.type,
    this.img,
    this.showImg,
    this.price,
    this.showImg2,
    this.vipLevel,
    this.musicGift,
    this.giftType,
    this.expiry,
    this.quantity,
    this.isMusic,
  });

  @override
  List<Object?> get props =>
      [
        id,
        name,
        type,
        img, isMusic,
        showImg,
        showImg2,
        price,
        vipLevel,
        musicGift,
        giftType,
        quantity,
        expiry,
      ];
}


// class GiftsExtendedEntity extends GiftsEntity {
//   final int? expiry;
//   final int? quantity;
//
//   const GiftsExtendedEntity({
//     super.id,
//     super.name,
//     super.type,
//     super.img,
//     super.showImg,
//     super.showImg2,
//     super.price,
//     super.vipLevel,
//     super.musicGift,
//     super.giftType,
//     this.expiry,
//     this.quantity,
//   });
//
//   @override
//   List<Object?> get props => [
//     ...super.props,
//     expiry,
//     quantity,
//   ];
// }

