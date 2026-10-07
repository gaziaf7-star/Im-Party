import 'package:general/src/core/utils/methods.dart';
import 'package:general/src/features/auth/auth.dart';

class FamilyModel extends FamilyEntity {
  const FamilyModel({
    super.id,
    super.maxNum,
    super.img,
    super.memberNum,
    super.name,
    super.ownerFamilyId,
    super.topStars,
  });

  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    return FamilyModel(
      id: parseValue<int>(json['id'], 0),
      maxNum: parseValue<int>(json['max_num'], 0),
      img: parseValue<String>(json['img'], ''),
      ownerFamilyId: parseValue<int>(json['owner_id'], 0),
      name: parseValue<String>(json['family_name'], ''),
      memberNum: parseValue<int>(json['num_of_members'], 0),
      topStars: parseValue<List<String>>(json['top_stars'], []),
    );
  }
}
