

import 'package:general/src/features/cp/domain/entities/cp_relations_levels_gifts_entity.dart';

import '../../../../core/index.dart';

class CpRelationLevelsGiftsModel extends LevelDataEntity{

  const CpRelationLevelsGiftsModel({
    required super.level,
    super.title,
    required super.have,
    super.gifts,
  });

  factory CpRelationLevelsGiftsModel.fromJson(Map<String, dynamic> json) {
    return CpRelationLevelsGiftsModel(
      level: parseValue<int>(json['level'], 0),
      title: parseValue<String>(json['title'], ''),
      have: parseValue<bool>(json['have'], false),
      gifts: (json['gifts'] is List)
          ? (json['gifts'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => Gift.fromJson(e))
          .toList()
          : null,
    );
  }

}

class Gift extends GiftEntity{
  const Gift({
    super.title,
    super.images,
  });

  factory Gift.fromJson(Map<String, dynamic> json) {
    return Gift(
      title: parseValue<String>(json['title'], ''),
      images: parseValue<List<String>>(json['images'], []),
    );
  }
}
