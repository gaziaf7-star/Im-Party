import 'package:general/src/core/index.dart';

class MallEntity extends Equatable {
  final String? id;
  final String? name;
  final String? title;
  final int? price;
  final String? color;
  final int? expire;
  final String? image;
  final String? svg;
  final String? imageType;

  const MallEntity({
    this.id,
    this.name,
    this.title,
    this.price,
    this.color,
    this.expire,
    this.image,
    this.svg,
    this.imageType,
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
        svg,
        imageType,
      ];
}
