import 'package:general/src/features/auth/data/model/manager_type_model.dart';
import 'package:general/src/features/family/domain/entities/family_member_entity.dart';

import '../../../../core/index.dart';

class FamilyMemberModel extends AllFamilyMemberEntity {
  const FamilyMemberModel({
    required super.admin,
    required super.members,
    required super.owner,
  });

  // Factory method to parse from JSON
  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      admin: List<MemberFamilyDataModel>.from(
        (json['admins'] is List ? json['admins'] as List : const [])
            .whereType<Map<String, dynamic>>()
            .map((x) => MemberFamilyDataModel.fromJson(x)),
      ),
      members: List<MemberFamilyDataModel>.from(
        (json['members'] is List ? json['members'] as List : const [])
            .whereType<Map<String, dynamic>>()
            .map((x) => MemberFamilyDataModel.fromJson(x)),
      ),
      owner: MemberFamilyDataModel.fromJson(json['owner']),
    );
  }
}

class MemberFamilyDataModel extends MemberFamilyEntity {
  const MemberFamilyDataModel({
    required super.id,
    required super.name,
    required super.image,
    required super.age,
    required super.gender,
    required super.frameId,
    required super.frame,
    required super.isFamilyAdmin,
    required super.familyId,
    super.managerTypeEntity,
    required super.myType,
    required super.familyStatus,
    required super.monthlyDiamond,
    required super.vipLevel,
  });

  factory MemberFamilyDataModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] is Map<String, dynamic> ? json['profile'] : {};

    return MemberFamilyDataModel(
      id: parseValue<int>(json['id'], 0),
      age: parseValue<int>(profile['age'], 0),
      gender: parseValue<int>(profile['gender'], 0),
      image: parseValue<String>(profile['image'], "tic_logo.jpg"),
      frame: parseValue<String>(json['frame'], ""),
      frameId: parseValue<int>(json['frame_id'], 0),
      isFamilyAdmin: parseValue<bool>(json['is_family_admin'], false),
      name: parseValue<String>(json['name'], ""),
      familyId: parseValue<String>(json['family_id'], ''),
      monthlyDiamond: parseValue<int>(json['monthly_diamond_received'], 0),
      vipLevel: parseValue<int>(json['vip_level'], 0),
      managerTypeEntity: json["manger_type"] is Map<String, dynamic>
          ? ManagerTypeModel.fromJson(json["manger_type"])
          : null,
      myType: parseValue<int>(json['type_user'], 0),
      familyStatus: parseValue<int>(json['family_status'], -1),
    );
  }

}
