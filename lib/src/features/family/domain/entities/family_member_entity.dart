import 'package:general/src/features/auth/auth.dart';
import 'package:equatable/equatable.dart';

class AllFamilyMemberEntity extends Equatable {
  final List<MemberFamilyEntity> members;
  final List<MemberFamilyEntity> admin;
  final MemberFamilyEntity owner;

  const AllFamilyMemberEntity({
    required this.admin,
    required this.members,
    required this.owner,
  });

  // copyWith method to create a new instance with modified properties
  AllFamilyMemberEntity copyWith({
    List<MemberFamilyEntity>? members,
    List<MemberFamilyEntity>? admin,
    MemberFamilyEntity? owner,
  }) {
    return AllFamilyMemberEntity(
      members: members ?? this.members,
      admin: admin ?? this.admin,
      owner: owner ?? this.owner,
    );
  }

  @override
  List<Object?> get props => [members, admin, owner];
}


class MemberFamilyEntity extends Equatable {
  final int id;
  final String name;
  final String image;
  final int age;
  final int gender;
  final int frameId;
  final int familyStatus;
  final String frame;
  final bool isFamilyAdmin;
  final String familyId;
  final ManagerTypeEntity? managerTypeEntity;
  final int myType;
  final int vipLevel;
  final int monthlyDiamond;

  const MemberFamilyEntity({
    required this.id,
    required this.name,
    required this.image,
    required this.age,
    required this.gender,
    required this.frameId,
    required this.frame,
    required this.isFamilyAdmin,
    required this.familyId,
    this.managerTypeEntity,
    required this.myType,
    required this.familyStatus,
    required this.vipLevel,
    required this.monthlyDiamond,
  });

  // copyWith method to create a new instance with updated properties
  MemberFamilyEntity copyWith({
    int? id,
    String? name,
    String? image,
    int? age,
    int? gender,
    int? frameId,
    String? frame,
    bool? isFamilyAdmin,
    String? familyId,
    ManagerTypeEntity? managerTypeEntity,
    int? myType,
    int? familyStatus,
    int? vipLevel,
    int? monthlyDiamond,
  }) {
    return MemberFamilyEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      frameId: frameId ?? this.frameId,
      frame: frame ?? this.frame,
      isFamilyAdmin: isFamilyAdmin ?? this.isFamilyAdmin,
      familyId: familyId ?? this.familyId,
      managerTypeEntity: managerTypeEntity ?? this.managerTypeEntity,
      myType: myType ?? this.myType,
      familyStatus: familyStatus ?? this.familyStatus,
      vipLevel: vipLevel ?? this.vipLevel,
      monthlyDiamond: monthlyDiamond ?? this.monthlyDiamond,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        image,
        age,
        gender,
        frameId,
        frame,
        isFamilyAdmin,
        familyId,
        managerTypeEntity,
        myType,
        familyStatus,
        monthlyDiamond,
        vipLevel
      ];
}
