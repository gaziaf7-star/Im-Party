import 'package:general/src/features/games/data/model/user_top_model.dart';
import 'package:general/src/features/games/domain/entities/ranking_entity.dart';

class RankingModel extends RankingEntity {
  const RankingModel({
    required UserTopModel super.userEntity,
    required super.usersEntity,
    required super.otherUsersEntity,
  });

  factory RankingModel.fromJson(Map<String, dynamic> json) {
    return RankingModel(
      userEntity: json['user'] is Map<String, dynamic>
          ? UserTopModel.fromJson(json['user'])
          : const UserTopModel(),
      usersEntity: List<UserTopModel>.from(
        (json['top'] is List ? json['top'] as List : const [])
            .whereType<Map<String, dynamic>>()
            .map((element) => UserTopModel.fromJson(element)),
      ),
      otherUsersEntity: List<UserTopModel>.from(
        (json['other'] is List ? json['other'] as List : const [])
            .whereType<Map<String, dynamic>>()
            .map((element) => UserTopModel.fromJson(element)),
      ),
    );
  }
}
