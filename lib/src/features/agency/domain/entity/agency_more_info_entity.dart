import 'package:equatable/equatable.dart';
import 'package:general/src/features/auth/domain/entities/my_data_entity.dart';

class UserStarEntity extends Equatable {
  final int? id;
  final String? uuid;
  final String? name;
  final String? image;
  final String? exp;
  final String? idImage;
  final ImageColorEntity? imageColorEntity;
  final String? coloredName;

  const UserStarEntity({
    this.id,
    this.uuid,
    this.name,
    this.image,
    this.exp,
    this.idImage,
    this.imageColorEntity,
    this.coloredName,
  });

  UserStarEntity copyWith({
    int? id,
    String? uuid,
    String? name,
    String? image,
    String? exp,
    String? coloredName,
  }) {
    return UserStarEntity(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      image: image ?? this.image,
      exp: exp ?? this.exp,
      coloredName: coloredName ?? this.coloredName,
    );
  }

  @override
  List<Object?> get props =>
      [id, uuid, name, image, exp, imageColorEntity, idImage, coloredName];
}

class OldTargetEntity extends Equatable {
  final int? month;
  final int? userDiamonds;

  const OldTargetEntity({
    this.month,
    this.userDiamonds,
  });

  OldTargetEntity copyWith({
    int? id,
    int? userDiamonds,
  }) {
    return OldTargetEntity(
      month: id ?? month,
      userDiamonds: userDiamonds ?? this.userDiamonds,
    );
  }

  @override
  List<Object?> get props => [month, userDiamonds];
}

class TargetEntity extends Equatable {
  final int? id;
  final int? userDiamonds;
  final int? userHours;
  final int? userDays;
  final int? diamondsNextTarget;
  final List<OldTargetEntity>? oldTargets;

  const TargetEntity({
    this.id,
    this.userDiamonds,
    this.userHours,
    this.userDays,
    this.diamondsNextTarget,
    this.oldTargets,
  });

  TargetEntity copyWith({
    int? id,
    int? userDiamonds,
    int? userHours,
    int? userDays,
    int? diamondsNextTarget,
    List<OldTargetEntity>? oldTargets,
  }) {
    return TargetEntity(
      id: id ?? this.id,
      userDiamonds: userDiamonds ?? this.userDiamonds,
      userHours: userHours ?? this.userHours,
      userDays: userDays ?? this.userDays,
      diamondsNextTarget: diamondsNextTarget ?? this.diamondsNextTarget,
      oldTargets: oldTargets ?? this.oldTargets,
    );
  }

  @override
  List<Object?> get props =>
      [id, userDiamonds, userHours, userDays, diamondsNextTarget, oldTargets];
}

class UserTargetEntity extends Equatable {
  final int? id;
  final String? name;
  final String? uuid;
  final String? image;
  final bool? isAdmin;
  final int? isHost;
  final double? salary;
  final List<String>? topUsers;
  final int? userDiamonds;
  final int? userHours;
  final int? userDays;
  final List<OldTargetEntity>? oldTargets;
  final String? idImage;
  final String? coloredName;
  final ImageColorEntity? imageColorEntity;

  const UserTargetEntity({
    this.id,
    this.name,
    this.uuid,
    this.image,
    this.isHost,
    this.topUsers,
    this.salary,
    this.userDiamonds,
    this.userHours,
    this.userDays,
    this.oldTargets,
    this.idImage,
    this.imageColorEntity,
    this.coloredName,
    this.isAdmin,
  });

  UserTargetEntity copyWith({
    int? id,
    String? name,
    String? uuid,
    String? image,
    int? isHost,
    List<UserStarEntity>? senderGifts,
  }) {
    return UserTargetEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      uuid: uuid ?? this.uuid,
      image: image ?? this.image,
      isHost: isHost ?? this.isHost,
      // topUsers: senderGifts ?? this.topUsers,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,isAdmin,
        uuid,
        image,
        isHost,
        topUsers,
        oldTargets,
        userDays,
        userHours,
        userDiamonds,
        imageColorEntity,
        idImage,
        coloredName
      ];
}

class OverallStatsEntity extends Equatable {
  final double? target;
  final int? minutes;
  final int? days;
  final double? ratePercentage;
  final List<UserStarEntity>? stars;
  final List<UserStarEntity>? heroes;
  final List<UserTargetEntity>? usersTarget;

  const OverallStatsEntity({
    this.target,
    this.ratePercentage,
    this.stars,
    this.heroes,
    this.usersTarget,
    this.minutes,
    this.days,
  });

  OverallStatsEntity copyWith({
    double? target,
    double? ratePercentage,
    List<UserStarEntity>? stars,
    List<UserStarEntity>? heroes,
    List<UserTargetEntity>? usersTarget,
  }) {
    return OverallStatsEntity(
      target: target ?? this.target,
      ratePercentage: ratePercentage ?? this.ratePercentage,
      stars: stars ?? this.stars,
      heroes: heroes ?? this.heroes,
      usersTarget: usersTarget ?? this.usersTarget,
    );
  }

  @override
  List<Object?> get props =>
      [target, ratePercentage, stars, heroes, usersTarget];
}
