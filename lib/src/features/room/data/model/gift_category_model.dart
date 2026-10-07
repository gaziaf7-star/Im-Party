import 'package:general/src/features/room/domain/entities/gift_category_entity.dart';

class GiftCategoryModel extends GiftCategoryEntity {
  const GiftCategoryModel({
    required super.id,
    required super.title,
    required super.type,
  });

  factory GiftCategoryModel.fromJson(Map<String, dynamic> json) {
    return GiftCategoryModel(
      id: json['id'] as int,
      title: json['title'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
    };
  }
}
