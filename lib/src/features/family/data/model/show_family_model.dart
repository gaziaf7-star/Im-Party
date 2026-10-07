import 'package:general/src/features/family/family.dart';

import '../../../../core/utils/methods.dart';

class ShowFamilyModel extends ShowFamilyEntity {
  const ShowFamilyModel({
    super.id,
    super.img,
    super.introduce,
    super.maxNumOfMembers,
    super.name,
    super.numOfMembers,
    super.amIAdmin,
    super.amIOwner,
    super.members,
    super.amIMember,
    super.numOfRequests,
    super.familyLevelEntity,
    super.memberFamilyEntity,
    super.requested,
  });

  factory ShowFamilyModel.fromJson(Map<String, dynamic> json) {
    return ShowFamilyModel(
      id: parseValue<int>(json['id'], 0),
      img: parseValue<String>(json["image"], ''),
      introduce: parseValue<String>(json["introduce"], ''),
      maxNumOfMembers: parseValue<int>(json["max_num_of_members"], 0),
      numOfMembers: parseValue<int>(json["num_of_members"], 0),
      name: parseValue<String>(json["name"], ''),
      amIAdmin: parseValue<bool>(json['am_i_admin'], false),
      requested: parseValue<bool>(json['requested'], false),
      amIOwner: parseValue<bool>(json['am_i_owner'], false),
      amIMember: parseValue<bool>(json['am_i_member'], false),
      numOfRequests: parseValue<int>(json['num_of_requests'], 0),
      memberFamilyEntity: json['owner'] is Map<String, dynamic>
          ? MemberFamilyDataModel.fromJson(json['owner'])
          : null,
      members: (json['members'] is List)
          ? List<MemberFamilyDataModel>.from(
              (json['members'] as List)
                  .whereType<Map<String, dynamic>>()
                  .map((x) => MemberFamilyDataModel.fromJson(x)))
          : null,
      familyLevelEntity: json['level'] is Map<String, dynamic>
          ? FamilyLevelModel.fromJson(json['level'])
          : null,
    );
  }

  @override
  ShowFamilyModel copyWith(
      {String? name,
      String? introduce,
      String? img,
      int? numOfMembers,
      List<MemberFamilyEntity>? members,
      int? numOfRequests}) {
    return ShowFamilyModel(
      name: name ?? this.name,
      introduce: introduce ?? this.introduce,
      img: img ?? this.img,
      id: id,
      amIMember: amIMember,
      maxNumOfMembers: maxNumOfMembers,
      numOfMembers: numOfMembers ?? this.numOfMembers,
      numOfRequests: numOfRequests ?? this.numOfRequests,
      amIAdmin: amIAdmin,
      members: members ?? this.members,
      familyLevelEntity: familyLevelEntity,
      memberFamilyEntity: memberFamilyEntity,
      amIOwner: amIOwner,
      requested: requested,
    );
  }

  // @override
  // ShowFamilyModel copyWith({
  //   int? id,
  //   String? name,
  //   String? introduce,
  //   String? img,
  //   bool? amIMember,
  //   int? maxNumOfMembers,
  //   int? numOfMembers,
  //   bool? amIOwner,
  //   bool? amIAdmin,
  //   List<MemberFamilyDataModel>? members,
  //   int? numOfRequests,
  //   FamilyLevelModel? familyLevel,
  //   MemberFamilyDataModel? ownerData,
  // }) {
  //   return ShowFamilyModel(
  //     id: id ?? this.id,
  //     name: name ?? this.name,
  //     introduce: introduce ?? this.introduce,
  //     img: img ?? this.img,
  //     amIMember: amIMember ?? this.amIMember,
  //     maxNumOfMembers: maxNumOfMembers ?? this.maxNumOfMembers,
  //     numOfMembers: numOfMembers ?? this.numOfMembers,
  //     amIOwner: amIOwner ?? this.amIOwner,
  //     amIAdmin: amIAdmin ?? this.amIAdmin,
  //     members: members ?? this.members,
  //     numOfRequests: numOfRequests ?? this.numOfRequests,
  //     familyLevel: familyLevel ?? this.familyLevel,
  //     ownerData: ownerData ?? this.ownerData,
  //   );
  // }
}

class FamilyLevelModel extends FamilyLevelEntity {
  const FamilyLevelModel({
    super.levelExp,
    super.levelName,
    super.levelImage,
    super.familyExp,
    super.overCurrentLevelExp,
    super.nextExp,
    super.nextImage,
    super.nextName,
    super.per,
    super.rem,
    super.isLastLevel,
  });

  factory FamilyLevelModel.fromJson(Map<String, dynamic> json) {
    return FamilyLevelModel(
      levelExp: parseValue<int>(json['level_exp'], 0),
      levelName: parseValue<String>(json['level_name'], ''),
      levelImage: parseValue<String>(json['level_img'], ''),
      familyExp: parseValue<int>(json['family_exp'], 0),
      overCurrentLevelExp: parseValue<int>(json['over_current_level_exp'], 0),
      nextExp: parseValue<int>(json['next_exp'], 0),
      nextImage: parseValue<String>(json['next_img'], ''),
      nextName: parseValue<String>(json['next_name'], ''),
      per: parseValue<double>(json['per'], 0.0),
      rem: parseValue<double>(json['rem'], 0.0),
      isLastLevel: parseValue<bool>(json['is_last_level'], false),
    );
  }
}
