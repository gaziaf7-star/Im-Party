import 'package:general/src/core/index.dart';

class MyBagEntity extends Equatable {
  final int? id;
  final String? name;
  final String? type;
  final String? image;
  final String? expire;
  final int? targetId;
  final bool isUsed;
  final bool use;
  final int? isDress;
  final int? using;
  final String? svg;
  final String? imageType;


  const MyBagEntity({
     this.name,
     this.isDress,
     required this.isUsed,
     this.expire,
     this.id,
     this.image,
     this.type,
     this.targetId,
     this.svg,
     this.using,
     this.imageType,
    required this.use,
  });

  MyBagEntity copyWith({
    bool? use,
    int? using,
    bool? isUsed,
  }) {
    return MyBagEntity(
        image: image,
        name: name,
        id: id,
        type: type,
        expire: expire,
        use: use ?? this.use,
        isUsed: isUsed ?? this.isUsed,
        isDress: isDress,
        targetId: targetId,
        using: using,
        imageType: imageType,
        svg: svg);
  }

  @override
  List<Object?> get props => [
        id,
        type,
        image,
        name,
        expire,
        isUsed,
        isDress,
        targetId,
        svg,
        use,
        using,
    imageType
      ];
}
