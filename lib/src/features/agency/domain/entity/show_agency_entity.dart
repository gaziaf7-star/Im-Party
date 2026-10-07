import 'package:equatable/equatable.dart';
import 'package:general/src/features/agency/data/model/agency_search_model.dart';
import 'package:general/src/features/agency/domain/entity/information_agency_entity.dart';
import 'package:general/src/features/auth/data/model/user_model.dart';

class ShowAgencyEntity extends Equatable {
  final int? id;
  final String? name;
  final String? notice;
  final String? image;
  final String? agencyType;
  final int? numOfHosts;
  final int? userAgencyStatus;
  final bool? isJoinRequest;
  final UserModel? owner;
  final List<MemberModel>? members;
  final List<StarEntity>? stars;
  final List<StarEntity>? admins;

  const ShowAgencyEntity({
    this.id,
    this.name,
    this.notice,
    this.image,
    this.numOfHosts,
    this.userAgencyStatus,
    this.owner,
    this.members,
    this.agencyType,
    this.stars,
    this.admins,
    this.isJoinRequest,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        notice,
        image,
        isJoinRequest,
        numOfHosts,
        owner,
        members,
        userAgencyStatus,
        agencyType,
        admins,
        stars
      ];

  ShowAgencyEntity copyWith({
    int? id,
    String? name,
    String? notice,
    String? image,
    int? numOfHosts,
    int? userAgencyStatus,
    UserModel? owner,
  }) {
    return ShowAgencyEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      notice: notice ?? this.notice,
      image: image ?? this.image,
      numOfHosts: numOfHosts ?? this.numOfHosts,
      owner: owner ?? this.owner,
      userAgencyStatus: userAgencyStatus ?? this.userAgencyStatus,
    );
  }
}
