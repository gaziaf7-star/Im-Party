import 'package:general/src/features/home/domain/entities/top_rank_images_entity.dart';

import '../../../../../reels_viewer/reels_viewer.dart';

class TopRankImagesModel extends TopRankImagesEntity {
  const TopRankImagesModel({
    required super.sender,
    required super.receiver,
    required super.room,
    required super.topCpEntity,
    required super.topGamers,
  });

  factory TopRankImagesModel.fromJson(Map<String, dynamic> json) {
    return TopRankImagesModel(
      sender: List<String>.from(json['sender'] is List ? json['sender'] as List : []),
      receiver: List<String>.from(json['receiver'] is List ? json['receiver'] as List : []),
      room: List<String>.from(json['room'] is List ? json['room'] as List : []),
      topCpEntity: parseValue<List<Map<String, dynamic>>>(
        json['top_cp'],
        [],
      ).map((item) => TopCpModel.fromJson(item)).toList(),
      topGamers: parseValue<List<Map<String, dynamic>>>(
        json['top_gamer'],
        [],
      ).map((item) => TopGamerModel.fromJson(item)).toList(),
    );
  }
}

class TopCpModel extends TopCpEntity {
  const TopCpModel({super.userOne, super.userTwo});

  factory TopCpModel.fromJson(Map<String, dynamic> json) {
    return TopCpModel(
      userOne: json['userOne'] is Map<String, dynamic>
          ? UserOneModel.fromJson(json['userOne'])
          : null,
      userTwo: json['userTwo'] is Map<String, dynamic>
          ? UserOneModel.fromJson(json['userTwo'])
          : null,
    );
  }
}

class UserOneModel extends UserEntity {
  const UserOneModel({
    super.image,
  });

  factory UserOneModel.fromJson(Map<String, dynamic> json) {
    return UserOneModel(
      image: parseValue<String>(json['image'], ''),
    );
  }
}

class TopGamerModel extends TopGamersEntity {
  const TopGamerModel({super.image});

  factory TopGamerModel.fromJson(Map<String, dynamic> json) {
    return TopGamerModel(
      image: parseValue<String>(
          json['user'] is Map<String, dynamic> ? json['user']['image'] : null,
          ''),
    );
  }
}
