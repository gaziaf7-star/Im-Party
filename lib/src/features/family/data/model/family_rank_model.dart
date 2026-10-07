import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/family/data/model/show_family_model.dart';
import 'package:general/src/features/family/domain/entities/family_rank_entity.dart';

import '../../../../core/utils/methods.dart';


class FamilyRankModel extends FamilyRankEntity {
  const FamilyRankModel({
    required super.id,
    required super.name,
    required super.introduce,
    required super.img,
    required super.rank,
    required super.countryEntity,
    required super.familyLevelEntity,
     super.joinFamilyRequestState,
  });

  factory FamilyRankModel.fromJson(Map<String, dynamic> json) {
    return FamilyRankModel(
      id: parseValue<int>(json['id'], 0),
      img: parseValue<String>(json['image'], ""),
      introduce: parseValue<String>(json['introduce'], ""),
      name: parseValue<String>(json['name'], ""),
      rank: parseValue<String>(json['rank'], ""),
      countryEntity: json['country'] is Map<String, dynamic>
          ? CountryModel.fromJson(json['country'])
          : null,
      familyLevelEntity: json['level'] is Map<String, dynamic>
          ? FamilyLevelModel.fromJson(json['level'])
          : null,
    );
  }

}
