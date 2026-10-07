import 'package:equatable/equatable.dart';

class AgencyMemberEntity extends Equatable {
  final int? id;
  final String? uuid;
  final String? gender;
  final int? diamonds;
  final String? name;
  final LevelEntity? level;
  final ProfileEntity? profile;
  final bool? hasColorName;

  const AgencyMemberEntity({
    required this.id,
    required this.uuid,
    required this.gender,
    required this.diamonds,
    required this.name,
    required this.level,
    required this.profile,
    required this.hasColorName,
  });

  @override
  List<Object?> get props => [id, uuid, gender, diamonds, name, level, profile, hasColorName];
}

class LevelEntity extends Equatable {
  final String? receiverImg;
  final String? senderImg;

  const LevelEntity({
    required this.receiverImg,
    required this.senderImg,
  });

  @override
  List<Object?> get props => [receiverImg, senderImg];
}

class ProfileEntity extends Equatable {
  final String? image;

  const ProfileEntity({
    required this.image,
  });

  @override
  List<Object?> get props => [image];
}
