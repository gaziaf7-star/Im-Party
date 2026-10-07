import 'package:equatable/equatable.dart';

class AgencyRankingEntity extends Equatable {
  final String exp;
  final int id;
  final double target;
  final String name;
  final String notice;
  final String phone;
  final String img;
  final Owner owner;

  const AgencyRankingEntity({
    required this.exp,
    required this.id,
    required this.target,
    required this.name,
    required this.notice,
    required this.phone,
    required this.img,
    required this.owner,
  });


  @override
  List<Object?> get props => [exp, id, target, name, notice, phone, img, owner];
}

class Owner extends Equatable {
  final int id;
  final String uuid;
  final int diamonds;
  final String name;
  final Vip vip;
  final Level level;
  final Profile profile;
  final bool hasColorName;
  final int gender;

  const Owner({
    required this.id,
    required this.uuid,
    required this.diamonds,
    required this.name,
    required this.vip,
    required this.level,
    required this.profile,
    required this.hasColorName,
    required this.gender,
  });



  @override
  List<Object?> get props => [
        id,
        uuid,
        diamonds,
        name,
        vip,
        level,
        profile,
        hasColorName,
        gender,
      ];
}

class Vip extends Equatable {
  const Vip();

  factory Vip.fromJson(Map<String, dynamic> json) {
    return const Vip(); // Adjust as necessary based on actual VIP fields.
  }

  @override
  List<Object?> get props => [];
}

class Level extends Equatable {
  final String receiverImg;
  final String senderImg;

  const Level({
    required this.receiverImg,
    required this.senderImg,
  });


  @override
  List<Object?> get props => [receiverImg, senderImg];
}

class Profile extends Equatable {
  final String image;

  const Profile({required this.image});

 

  @override
  List<Object?> get props => [image];
}