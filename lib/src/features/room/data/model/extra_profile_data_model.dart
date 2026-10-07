import 'package:general/src/features/auth/data/model/family_model.dart';
import 'package:general/src/features/cp/cp.dart';

import '../../../../core/utils/methods.dart';
import '../../../profile/data/model/gift_history_model.dart';
import '../../domain/entities/extra_profile_data_entity.dart';

class ExtraProfileDataModel extends ExtraProfileDataEntity {
  const ExtraProfileDataModel(
      {super.familyData,
      super.achievementImages,
      super.gifts,
      super.cp,
      super.isFollow});

  factory ExtraProfileDataModel.fromJson(Map<String, dynamic> json) {
    return ExtraProfileDataModel(
      familyData: json['family_data'] is Map<String, dynamic>
          ? FamilyModel.fromJson(json['family_data'] as Map<String, dynamic>)
          : null,
      isFollow: parseValue<bool>(json['is_followed'], false),
      achievementImages:
          parseValue<List<String>>(json['achievement_images'], <String>[]),
      gifts: json['gifts'] is List
          ? (json['gifts'] as List)
              .whereType<Map<String, dynamic>>()
              .map((x) => GiftHistoryModel.fromJson(x))
              .toList()
          : null,
      cp: json['cp'] is Map<String, dynamic>
          ? MainCp.fromJson(json['cp'] as Map<String, dynamic>)
          : null,
    );
  }
}
