import 'package:general/src/features/agency/domain/entity/agency_more_info_entity.dart';

import '../../../../../reels_viewer/reels_viewer.dart';

class UserStarModel extends UserStarEntity {
  const UserStarModel(
      {super.id,
      super.uuid,
      super.name,
      super.image,
      super.exp,
      super.idImage,
      super.imageColorEntity,
      super.coloredName});

  factory UserStarModel.fromJson(Map<String, dynamic> json) {
    return UserStarModel(
      id: parseValue<int>(json['id'], 0),
      uuid: parseValue<String>(json['uuid'], ''),
      name: parseValue<String>(json['name'], ''),
      image: parseValue<String>(json['image'], ''),
      exp: parseValue<String>(json['exp'], ''),
      idImage: parseValue<String>(json['id_image'], ''),
      imageColorEntity: json['image_color'] is Map<String, dynamic>
          ? ImageColorModel.fromJson(json['image_color'])
          : null,
      coloredName: parseValue<String>(json['colored_name'], ''),
    );
  }
}

class OldTargetModel extends OldTargetEntity {
  const OldTargetModel({
    super.month,
    super.userDiamonds,
  });

  factory OldTargetModel.fromJson(Map<String, dynamic> json) {
    return OldTargetModel(
      month: parseValue<int>(json['month_number'], 0),
      userDiamonds: parseValue<int>(json['diamonds'], 0),
    );
  }
}

class TargetModel extends TargetEntity {
  const TargetModel({
    super.id,
    super.userDiamonds,
    super.userHours,
    super.userDays,
    super.diamondsNextTarget,
    super.oldTargets,
  });

  factory TargetModel.fromJson(Map<String, dynamic> json) {
    return TargetModel(
      id: parseValue<int>(json['id'], 0),
      userDiamonds: parseValue<int>(json['user_diamonds'], 0),
      userHours: parseValue<int>(json['user_hours'], 0),
      userDays: parseValue<int>(json['user_days'], 0),
      diamondsNextTarget: parseValue<int>(json['diamonds_next_target'], 0),
      oldTargets: parseValue<List<OldTargetModel>>(
        json['old_targets'],
        [],
        customParser: (value) {
          if (value is List) {
            return value
                .map((item) =>
                    OldTargetModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          // log("customParser: Expected List but got ${value.runtimeType}");
          return [];
        },
      ).cast<OldTargetEntity>(),
    );
  }
}

class UserTargetModel extends UserTargetEntity {
  const UserTargetModel({
    super.id,
    super.name,
    super.uuid,
    super.image,
    super.salary,
    super.topUsers,
    super.userDiamonds,
    super.userHours,
    super.userDays,
    super.oldTargets,
    super.idImage,
    super.imageColorEntity,
    super.coloredName,
    super.isAdmin,
  });

  factory UserTargetModel.fromJson(Map<String, dynamic> json) {
    return UserTargetModel(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['name'], ''),
      uuid: parseValue<String>(json['uuid'], ''),
      image: parseValue<String>(json['image'], ''),
      idImage: parseValue<String>(json['id_image'], ''),
      coloredName: parseValue<String>(json['colored_name'], ''),
      salary: parseValue<double>((json['salary'].toDouble()), 0.0),
      topUsers: parseValue<List<String>>(
          (json['top_users'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList(),
          []),
      userDiamonds: parseValue<int>(json['target']?['user_diamonds'], 0),
      userHours: parseValue<int>(json['target']?['user_hours'], 0),
      userDays: parseValue<int>(json['target']?['user_days'], 0),
      isAdmin: parseValue<bool>(json['']?['is_admin'], false),
      oldTargets: parseValue<List<OldTargetModel>>(
        json['old_targets'],
        [],
        customParser: (value) {
          if (value is List) {
            return value
                .map((item) =>
                    OldTargetModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
      ).cast<OldTargetEntity>(),
      imageColorEntity: json['image_color'] is Map<String, dynamic>
          ? ImageColorModel.fromJson(json['image_color'])
          : null,
    );
  }
}

class OverallStatsModel extends OverallStatsEntity {
  const OverallStatsModel({
    super.target,
    super.ratePercentage,
    super.usersTarget,
    super.days,
    super.minutes,
  });

  factory OverallStatsModel.fromJson(Map<String, dynamic> json) {
    return OverallStatsModel(
      target: parseValue<double>((json['target'] ?? 0).toDouble(), 0.0),
      ratePercentage:
          parseValue<double>((json['rate_percentage'] ?? 0).toDouble(), 0.0),
      days: parseValue<int>(json['user']?['days']?.toInt(), 0),
      minutes: parseValue<int>(json['user']?['minutes']?.toInt(), 0),
      usersTarget: parseValue<List<UserTargetModel>>(
        json['users_target'],
        [],
        customParser: (value) {
          if (value is List) {
            return value
                .map((item) =>
                UserTargetModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
      ).cast<UserTargetEntity>(),
    );
  }
}

class HostSAgencyDataModel extends Equatable {
  final String salary;
  final int target;
  final List<UserStarModel> stars;
  final List<UserStarModel> heroes;

  const HostSAgencyDataModel({
    required this.salary,
    required this.target,
    required this.stars,
    required this.heroes,
  });

  factory HostSAgencyDataModel.fromJson(Map<String, dynamic> json) {
    return HostSAgencyDataModel(
      salary: parseValue<String>((json['salary'] ?? '0').toString(), '0'),
      target: parseValue<int>((json['target'] ?? 0).toInt(), 0),
      stars: parseValue<List<UserStarModel>>(
        json['star'],
        [],
        customParser: (value) {
          if (value is List) {
            return value
                .map((item) =>
                UserStarModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
      ),


      heroes:

      parseValue<List<UserStarModel>>(
        json['heroes'],
        [],
        customParser: (value) {
          if (value is List) {
            return value
                .map((item) =>
                UserStarModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
      ),
      // (json['heroes'] as List<dynamic>? ?? [])
      //     .map((e) => UserStarModel.fromJson(e))
      //     .toList(),
    );
  }

  @override
  List<Object?> get props => [salary, target, stars, heroes];
}
