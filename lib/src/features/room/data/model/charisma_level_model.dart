import 'package:equatable/equatable.dart';
import '../../../../core/utils/methods.dart';

class CharismaLevelModel extends Equatable {
  final int id;
  final int level;
  final int points;
  final String image;

  const CharismaLevelModel({
    required this.id,
    required this.level,
    required this.points,
    required this.image,
  });

  factory CharismaLevelModel.fromJson(Map<String, dynamic> json) {
    return CharismaLevelModel(
      id: parseValue<int>(json['id'], 0),
      level: parseValue<int>(json['level'], 0),
      points: parseValue<int>(json['points'], 0),
      image: parseValue<String>(json['image'], ''),
    );
  }

  @override
  List<Object?> get props => [id, level, points, image];
}
