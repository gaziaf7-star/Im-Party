import 'package:equatable/equatable.dart';
import 'package:general/src/features/family/domain/entities/family_member_entity.dart';

class ShowFamilyEntity extends Equatable {
  final int? id;
  final String? name;
  final String? introduce;
  final String? img;
  final bool? amIMember;
  final int? maxNumOfMembers;
  final int? numOfMembers;
  final bool? amIOwner;
  final bool? requested;
  final bool? amIAdmin;
  final List<MemberFamilyEntity>? members;
  final int? numOfRequests;
  final FamilyLevelEntity? familyLevelEntity;
  final MemberFamilyEntity? memberFamilyEntity;


  const ShowFamilyEntity({
    this.id,
    this.img,
    this.introduce,
    this.maxNumOfMembers,
    this.name,
    this.numOfMembers,
    this.amIAdmin,
    this.amIOwner,
    this.members,
    this.amIMember,
    this.numOfRequests,
    this.familyLevelEntity,
    this.memberFamilyEntity,
    this.requested,
  });

  ShowFamilyEntity copyWith({
    String? name,
    String? introduce,
    String? img,
    int? numOfMembers,
    int? numOfRequests,
    List<MemberFamilyEntity>? members,

  }) {
    return ShowFamilyEntity(
      name: name??this.name,
      introduce: introduce??this.introduce,
      img: img??this.img,
      id: id,
      amIMember: amIMember,
      maxNumOfMembers: maxNumOfMembers,
      numOfMembers: numOfMembers??this.numOfMembers,
      amIAdmin: amIAdmin,
      members: members??this.members,
      numOfRequests: numOfRequests??this.numOfRequests,
      familyLevelEntity: familyLevelEntity,
      memberFamilyEntity: memberFamilyEntity,
      amIOwner: amIOwner,
      requested: requested,
    );
  }

  @override
  List<Object?> get props => [
        id,
        img,
        introduce,
        maxNumOfMembers,
        name,
        numOfMembers,
        amIAdmin,
        amIOwner,
        members,
        amIMember,
        numOfRequests,
        familyLevelEntity,
        memberFamilyEntity,
    requested,
      ];
}

class FamilyLevelEntity extends Equatable {
  final int? levelExp;
  final String? levelName;
  final String? levelImage;
  final int? familyExp;
  final int? overCurrentLevelExp;
  final int? nextExp;
  final String? nextName;
  final String? nextImage;
  final double? per;
  final double? rem;
  final bool? isLastLevel;

  const FamilyLevelEntity({
    this.levelExp,
    this.levelName,
    this.levelImage,
    this.familyExp,
    this.overCurrentLevelExp,
    this.nextExp,
    this.nextImage,
    this.nextName,
    this.per,
    this.rem,
    this.isLastLevel,
  });

  @override
  List<Object?> get props => [
        levelExp,
        levelName,
        levelImage,
        familyExp,
        overCurrentLevelExp,
        nextExp,
        nextImage,
        nextName,
        per,
        rem,
        isLastLevel,
      ];
}
