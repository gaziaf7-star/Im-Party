import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/domain/entities/statistic_entity.dart';

class StatisticModel extends StatisticEntity {
  const StatisticModel({
    super.visitors,
    super.like,
    super.followers,
    super.bio,
  });

  factory StatisticModel.fromJson(Map<String, dynamic> json) {
    return StatisticModel(
      visitors: parseValue<int>(json['visitors'], 0),
      like: parseValue<int>(json['licked'], 0),
      followers: parseValue<int>(json['followers'], 0),
      bio: parseValue<String>(json['bio'], ''),
    );
  }
}
