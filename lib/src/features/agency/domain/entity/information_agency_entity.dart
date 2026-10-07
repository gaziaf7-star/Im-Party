import 'package:equatable/equatable.dart';

class InformationAgencyEntity extends Equatable {
  final int? id;
  final int? userStates;
  final String? name;
  final String? img;
  final String? bio;
  final TheOwnerEntity? owner;
  final List<StarEntity>? stars;
  final List<StarEntity>? admins;
  final List<StarEntity>? heroes;

  const InformationAgencyEntity({
    this.id,
    this.userStates,
    this.name,
    this.img,
    this.bio,
    this.owner,
    this.stars,
    this.admins,
    this.heroes,
  });

  InformationAgencyEntity copyWith({
    int? id,
    String? name,
    String? img,
    String? bio,
    TheOwnerEntity? owner,
    List<StarEntity>? stars,
    List<StarEntity>? nowStars,
    List<StarEntity>? admins,
    List<StarEntity>? heroes,
  }) {
    return InformationAgencyEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      img: img ?? this.img,
      bio: bio ?? this.bio,
      owner: owner ?? this.owner,
      stars: stars ?? this.stars,
      admins: admins ?? this.admins,
      heroes: heroes ?? this.heroes,
    );
  }

  @override
  List<Object?> get props => [id, name, img, bio,owner, stars, admins,heroes,userStates];
}

class TheOwnerEntity extends Equatable {
  final int? id;
  final String? uuid;
  final int? diamonds;
  final String? name;
  final String? phone;
  final String? coloredName;
  final TheCountryEntity? country;
  final MemberLevelEntity? level;
  final MemberProfileEntity? profile;
  final bool? hasColorName;
  final int? gender;

  const TheOwnerEntity({
    this.id,
    this.uuid,
    this.diamonds,
    this.name,
    this.phone,
    this.country,
    this.level,
    this.profile,
    this.hasColorName,
    this.gender,
    this.coloredName,
  });

  @override
  List<Object?> get props => [
        id,
        uuid,
        diamonds,
        name,
        phone,
        country,
        level,
        profile,
        hasColorName,
        gender,
        coloredName
      ];
}

class TheCountryEntity extends Equatable {
  final int? id;
  final String? name;
  final String? flag;
  final String? language;
  final String? eName;
  final String? phoneCode;
  final String? iso;

  const TheCountryEntity({
    this.id,
    this.name,
    this.flag,
    this.language,
    this.eName,
    this.phoneCode,
    this.iso,
  });

  @override
  List<Object?> get props => [id, name, flag, language, eName, phoneCode, iso];
}

class MemberLevelEntity extends Equatable {
  final String? receiverImg;
  final String? senderImg;

  const MemberLevelEntity({
    this.receiverImg,
    this.senderImg,
  });

  @override
  List<Object?> get props => [receiverImg, senderImg];
}

class MemberProfileEntity extends Equatable {
  final String? image;

  const MemberProfileEntity({this.image});

  @override
  List<Object?> get props => [image];
}

class StarEntity extends Equatable {
  final int? id;
  final String? uuid;
  final String? idImage;
  final String? name;
  final String? image;
  final String? exp;
  final String? coloredName;
  final MemberLevelEntity? levels;

  const StarEntity({
    this.id,
    this.uuid,
    this.idImage,
    this.name,
    this.image,
    this.exp,
    this.levels,
    this.coloredName,
  });

  StarEntity copyWith({
    int? id,
    String? uuid,
    String? idImage,
    String? name,
    String? image,
    String? exp,
    String? coloredName,
    MemberLevelEntity? levels,
  }) {
    return StarEntity(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      idImage: idImage ?? this.idImage,
      name: name ?? this.name,
      image: image ?? this.image,
      exp: exp ?? this.exp,
      levels: levels ?? this.levels,
      coloredName: coloredName ?? this.coloredName,
    );
  }

  @override
  List<Object?> get props => [id, uuid, name, image, exp, levels, coloredName,idImage];
}
