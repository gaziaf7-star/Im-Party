import 'package:equatable/equatable.dart';
import 'package:general/src/features/auth/data/model/family_model.dart';
import 'package:general/src/features/profile/data/model/gift_history_model.dart';

import '../../../cp/cp.dart';

class ExtraProfileDataEntity extends Equatable {
  final FamilyModel? familyData;
  final List<String>? achievementImages;
  final List<GiftHistoryModel>? gifts;
  final MainCp? cp;
  final bool? isFollow;

  const ExtraProfileDataEntity({
    this.familyData,
    this.achievementImages,
    this.gifts,
    this.cp,
    this.isFollow,
  });

  @override
  List<Object?> get props => [
        familyData,
        achievementImages,
        gifts,
        cp,
        isFollow,
      ];
}
