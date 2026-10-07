import 'package:general/src/core/index.dart';

class CpEntity extends Equatable {
  final List<CpUserRankEntity>? firstThree;
  final List<CpUserRankEntity>? others;
  final MyUserCpEntity? user;

  const CpEntity({this.firstThree, this.others, this.user});

  @override
  List<Object?> get props => [firstThree, others, user];
}

class CpUserRankEntity extends Equatable {
  final int? id;
  final LevelEntity? level;
  final double? exp;
  final UserCpEntity? userOne;
  final UserCpEntity? userTwo;

  const CpUserRankEntity(
      {this.id, this.level, this.exp, this.userOne, this.userTwo});

  @override
  List<Object?> get props => [id, level, exp, userOne, userTwo];
}

class LevelEntity extends Equatable {
  final int? id;
  final String? img;

  const LevelEntity({this.id, this.img});

  @override
  List<Object?> get props => [id, img];
}

class UserCpEntity extends Equatable {
  final int? id;
  final String? uid;
  final String? name;
  final String? image;
  final int? gender;

  const UserCpEntity({
    this.id,
    this.uid,
    this.name,
    this.image,
    this.gender,
  });

  @override
  List<Object?> get props => [
        id,
        uid,
        name,
        image,
        gender,
      ];
}

class OtherUserCpEntity extends Equatable {
  final int? id;
  final int? uuid;
  final String? name;
  final String? image;

  const OtherUserCpEntity({
    this.id,
    this.uuid,
    this.name,
    this.image,
  });

  @override
  List<Object?> get props => [
        id,
        uuid,
        name,
        image,
      ];
}

class MyUserCpEntity extends Equatable {
  final int? id;
  final int? exp;
  final String? uuid;
  final String? name;
  final String? image;
  final String? senderImage;
  final String? receiverImage;
  final OtherUserCpEntity? otherUserCpEntity;

  const MyUserCpEntity({
    this.id,
    this.uuid,
    this.name,
    this.exp,
    this.senderImage,
    this.receiverImage,
    this.image,
    this.otherUserCpEntity,
  });

  @override
  List<Object?> get props => [
        id,
        uuid,
        name,
        image,
        exp,
        senderImage,
        receiverImage,
        otherUserCpEntity
      ];
}
