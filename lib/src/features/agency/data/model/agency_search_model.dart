import 'package:general/src/features/agency/agency.dart';

import '../../../../../reels_viewer/reels_viewer.dart';
import 'information_agency_model.dart';

class AgencySearchModel extends AgencySearchEntity {
  AgencySearchModel({
    super.agencies,
    super.agencyMasters,
  });

  AgencySearchModel copyWith({
    List<AgenciesEntity>? agencies,
    List<AgencyMastersEntity>? agencyMasters,
  }) {
    return AgencySearchModel(
      agencies: agencies ?? this.agencies,
      agencyMasters: agencyMasters ?? this.agencyMasters,
    );
  }

  factory AgencySearchModel.fromJson(Map<String, dynamic> json) {
    return AgencySearchModel(
      agencies: json['agencies'] != null
          ? parseValue<List<AgenciesEntity>>(
        json['agencies'],
        [],
        customParser: (value) {
          if (value is List) {
            return value
                .map(
                  (item) => AgenciesModel.fromJson(
                item as Map<String, dynamic>,
              ),
            )
                .toList();
          }
          return [];
        },
      )
          : null,
      agencyMasters: json['agency_masters'] != null
          ? parseValue<List<AgencyMastersEntity>>(
        json['agency_masters'],
        [],
        customParser: (value) {
          if (value is List) {
            return value
                .map(
                  (item) => AgencyMastersModel.fromJson(
                item as Map<String, dynamic>,
              ),
            )
                .toList();
          }
          return [];
        },
      )
          : null,
    );
  }
}


class AgencyMastersModel extends AgencyMastersEntity {
  AgencyMastersModel({
    super.id,
    super.uuid,
    super.name,
    super.image,
    super.totalMember,
    super.agencyId,
    super.agency,
  });

  factory AgencyMastersModel.fromJson(Map<String, dynamic> json) {
    return AgencyMastersModel(
      agencyId: parseValue<String>(json['agency_id'], ''),
      id: parseValue<int>(json['id'], 0),
      uuid: parseValue<String>(json['uuid'], ''),
      name: parseValue<String>(json['name'], ''),
      image: parseValue<String>(json['image'], ''),
      totalMember: parseValue<int>(json['total_member'], 0),
      agency:
          json['agency'] is Map<String, dynamic> ? AgencyModel.fromJson(json['agency']) : null,
    );
  }
}

class AgenciesModel extends AgenciesEntity {
  AgenciesModel({
    super.id,
    super.name,
    super.image,
    super.totalMembers,
    super.members,
    super.owner,
    super.agencyType,
    super.stars,
    super.admins,
    super.bio,
    super.isJoinRequest,
  });

  factory AgenciesModel.fromJson(Map<String, dynamic> json) {
    return AgenciesModel(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['name'], ''),
      image: parseValue<String>(json['image'], ''),
      agencyType: parseValue<String>(json['agency_type'] ?? "shipping", ''),
      isJoinRequest: parseValue<bool>(json['is_join_request'], false),
      totalMembers: parseValue<int>(json['total_members'], 0),
      bio: parseValue<String>(json['bio'], ''),
      members: parseValue<List<MemberModel>>(
        json['members'],
        [],
        customParser: (value) {
          if (value is List) {
            return value
                .map((item) =>
                    MemberModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
      ).cast<MemberEntity>(),
      stars: parseValue<List<StarModel>>(
        json['star'],
        [],
        customParser: (value) {
          if (value is List) {
            return value
                .map((item) => StarModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
      ).cast<StarEntity>(),
      admins: parseValue<List<StarModel>>(
        json['admins'],
        [],
        customParser: (value) {
          if (value is List) {
            return value
                .map((item) => StarModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
      ).cast<StarEntity>(),
      owner: json['owner'] is Map<String, dynamic>
          ? AgencyOwnerModel.fromJson(json['owner'])
          : null,
    );
  }
}

class AgencyModel extends AgencyEntity {
  AgencyModel({
    super.id,
    super.name,
    super.image,
    super.members,
  });

  factory AgencyModel.fromJson(Map<String, dynamic> json) {
    return AgencyModel(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['name'], ''),
      image: parseValue<String>(json['image'], ''),
      members: parseValue<List<MemberModel>>(
        json['members'],
        [],
        customParser: (value) {
          if (value is List) {
            return value
                .map((item) =>
                    MemberModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
      ).cast<MemberEntity>(),
    );
  }
}

class MemberModel extends MemberEntity {
  MemberModel({
    super.id,
    super.uuid,
    super.name,
    super.image,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: parseValue<int>(json['id'], 0),
      uuid: parseValue<String>(json['uuid'], ''),
      name: parseValue<String>(json['name'], ''),
      image: parseValue<String>(json['image'], ''),
    );
  }
}

class AgencyOwnerModel extends AgencyOwnerEntity {
  AgencyOwnerModel({
    super.id,
    super.uuid,
    super.name,
    super.image,
    super.frame,
    super.frameType,
  });

  factory AgencyOwnerModel.fromJson(Map<String, dynamic> json) {
    return AgencyOwnerModel(
      id: parseValue<int>(json['id'], 0),
      uuid: parseValue<String>(json['uuid'], ''),
      name: parseValue<String>(json['name'], ''),
      image: parseValue<String>(json['image'], ''),
      frame: parseValue<String>(json['frame'], ''),
      frameType: parseValue<String>(json['frame_type'], ''),
    );
  }
}
