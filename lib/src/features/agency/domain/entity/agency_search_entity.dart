import 'package:general/src/features/agency/domain/entity/information_agency_entity.dart';

class AgencySearchEntity {
  final List<AgenciesEntity>? agencies;
  final List<AgencyMastersEntity>? agencyMasters;

  const AgencySearchEntity({
    this.agencies,
    this.agencyMasters,
  });


}


class AgencyMastersEntity {
  final int? id;
  final String? uuid;
  final String? name;
  final String? image;
  final int? totalMember;
  final String? agencyId;
  final AgencyEntity? agency;

  const AgencyMastersEntity({
    this.id,
    this.uuid,
    this.name,
    this.image,
    this.totalMember,
    this.agencyId,
    this.agency,
  });
}

class AgenciesEntity {
  final int? id;
  final String? name;
  final String? bio;
  final String? image;
  final String? agencyType;
  final int? totalMembers;
  final List<MemberEntity>? members;
  final AgencyOwnerEntity? owner;
  final List<StarEntity>? stars;
  final List<StarEntity>? admins;
  final bool? isJoinRequest;

  const AgenciesEntity({
    this.id,
    this.name,
    this.image,
    this.totalMembers,
    this.members,
    this.owner,
    this.agencyType,
    this.stars,
    this.admins,
    this.bio,
    this.isJoinRequest = false,
  });

  AgenciesEntity copyWith({
    int? id,
    String? name,
    String? bio,
    String? image,
    String? agencyType,
    int? totalMembers,
    List<MemberEntity>? members,
    AgencyOwnerEntity? owner,
    List<StarEntity>? stars,
    List<StarEntity>? admins,
    bool? isJoinRequest,
  }) {
    return AgenciesEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      image: image ?? this.image,
      agencyType: agencyType ?? this.agencyType,
      totalMembers: totalMembers ?? this.totalMembers,
      members: members ?? this.members,
      owner: owner ?? this.owner,
      stars: stars ?? this.stars,
      admins: admins ?? this.admins,
      isJoinRequest: isJoinRequest ?? this.isJoinRequest,
    );
  }
}

class AgencyEntity {
  final int? id;
  final String? name;
  final String? image;
  final List<MemberEntity>? members;

  const AgencyEntity({
    this.id,
    this.name,
    this.image,
    this.members,
  });
}

class MemberEntity {
  final int? id;
  final String? uuid;
  final String? name;
  final String? image;

  const MemberEntity({
    this.id,
    this.uuid,
    this.name,
    this.image,
  });
}

class AgencyOwnerEntity {
  final int? id;
  final String? uuid;
  final String? name;
  final String? image;
  final String? frame;
  final String? frameType;

  const AgencyOwnerEntity({
  this.id,
  this.uuid,
  this.name,
  this.image,
  this.frame,
  this.frameType,
  });
}
