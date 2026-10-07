import 'package:general/src/features/games/domain/entities/game_entity.dart';

import '../../../../core/utils/methods.dart';

class GamesModel extends GamesEntity {
  const GamesModel({
    required super.miniGames,
    required super.fullGames,
  });

  factory GamesModel.fromJson(Map<String, dynamic> json) {
    return GamesModel(
      fullGames: json['full'] is List
          ? List<GameDataModel>.from((json['full'] as List)
              .whereType<Map<String, dynamic>>()
              .map((v) => GameDataModel.fromJson(v)))
          : null,
      miniGames: json['mini'] is List
          ? List<GameDataModel>.from((json['mini'] as List)
              .whereType<Map<String, dynamic>>()
              .map((v) => GameDataModel.fromJson(v)))
          : null,
    );
  }
}

class GameDataModel extends GameDataEntity {
  const GameDataModel({
    super.id,
    super.name,
    super.url,
    super.image,
    super.webViewConfig,
    super.highSafety,
    super.high,
    super.inRoom,
    super.isHot,
    super.type,
  });

  factory GameDataModel.fromJson(Map<String, dynamic> json) {
    return GameDataModel(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['name'], ''),
      url: parseValue<String>(json['url'], ''),
      image: parseValue<String>(json['image'], ''),
      highSafety: parseValue<int>(json['high_safety'], 0),
      high: parseValue<double>(json['high'], 0.0),
      webViewConfig: parseValue<bool>(json['webView_config'], false),
      inRoom: parseValue<int>(json['in_room'], 0),
      isHot: parseValue<int>(json['is_hot'], 0),
      type: parseValue<int>(json['type'], 0),
    );
  }
}
