import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/agency/data/model/information_agency_model.dart';
import 'package:general/src/features/auth/data/model/user_model.dart';

import '../../../../../reels_viewer/reels_viewer.dart';

class ShowAgencyModel extends ShowAgencyEntity {
  const ShowAgencyModel({
    super.id,
    super.name,
    super.notice,
    super.image,
    super.numOfHosts,
    super.owner,
    super.userAgencyStatus,
    super.members,
    super.agencyType,
    super.stars,
    super.admins,
    super.isJoinRequest,
  });

  @override
  ShowAgencyModel copyWith({
    int? id,
    String? name,
    String? notice,
    String? image,
    int? numOfHosts,
    UserModel? owner,
    int? userAgencyStatus,
    List<MemberModel>? members,
    String? agencyType,
    List<StarEntity>? stars,
    List<StarEntity>? admins,
    bool? isJoinRequest,
  }) {
    return ShowAgencyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      notice: notice ?? this.notice,
      image: image ?? this.image,
      numOfHosts: numOfHosts ?? this.numOfHosts,
      owner: owner ?? this.owner,
      userAgencyStatus: userAgencyStatus ?? this.userAgencyStatus,
      members: members ?? this.members,
      agencyType: agencyType ?? this.agencyType,
      stars: stars ?? this.stars,
      admins: admins ?? this.admins,
      isJoinRequest: isJoinRequest ?? this.isJoinRequest,
    );
  }

  factory ShowAgencyModel.fromJson(Map<String, dynamic> json) {
    return ShowAgencyModel(
      id: parseValue<int>(json['id'], 0),
      image: parseValue<String>(json['img'], "tic_logo.jpg"),
      name: parseValue<String>(json['name'], ''),
      notice: parseValue<String>(json['notice'], ''),
      agencyType: parseValue<String>(json['agency_type'], "shipping"),
      numOfHosts: parseValue<int>(json['num_of_hosts'], 0),
      userAgencyStatus: parseValue<int>(json['user_agency_status'], 0),
      isJoinRequest: parseValue<bool>(json['is_join_request'], false),
      owner:
      json["owner"] is Map<String, dynamic> ? UserModel.fromJson(json["owner"]) : null,
      members: json['members'] is List
          ? List<MemberModel>.from(
          (json['members'] as List).whereType<Map<String, dynamic>>().map((v) => MemberModel.fromJson(v)))
          : null,
      stars: json['star'] is List
          ? List<StarModel>.from(
          (json['star'] as List).whereType<Map<String, dynamic>>().map((v) => StarModel.fromJson(v)))
          : null,
      admins: json['admins'] is List
          ? List<StarModel>.from(
          (json['admins'] as List).whereType<Map<String, dynamic>>().map((v) => StarModel.fromJson(v)))
          : null,
    );
  }
}

