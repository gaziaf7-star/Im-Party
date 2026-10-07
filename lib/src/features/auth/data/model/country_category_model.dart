import 'package:general/src/features/auth/domain/entities/country_category_entity.dart';

class CountryCategoryModel extends CountryCategoryEntity {
  const CountryCategoryModel({
    required super.id,
    required super.title,
    required super.type,
  });

  factory CountryCategoryModel.fromJson(Map<String, dynamic> json) {
    return CountryCategoryModel(
      id: json['id'] as int,
      title: json['title'] as String,
      type: json['type'] as String,
    );
  }
}
