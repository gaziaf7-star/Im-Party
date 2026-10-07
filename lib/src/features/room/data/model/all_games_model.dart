import 'package:general/src/features/room/domain/entities/all_games_entity.dart';

import '../../../../core/utils/methods.dart';

class AllGamesModel extends AllGamesEntity {
  const AllGamesModel({
    required super.miniGames,
    required super.fullGames,
  });

  factory AllGamesModel.fromJson(Map<String, dynamic> json) {
    List<GamesDataModel> miniGames = [];
    List<GamesDataModel> fullGames = [];

    if (json['mini'] is List) {
      miniGames = List<GamesDataModel>.from((json['mini'] as List)
          .whereType<Map<String, dynamic>>()
          .map((element) => GamesDataModel.fromJson(element)));
    }

    if (json['full'] is List) {
      fullGames = List<GamesDataModel>.from((json['full'] as List)
          .whereType<Map<String, dynamic>>()
          .map((element) => GamesDataModel.fromJson(element)));
    }

    return AllGamesModel(
      miniGames: miniGames,
      fullGames: fullGames,
    );
  }
}

class GamesDataModel extends GamesDataEntity {
  const GamesDataModel({
    required super.id,
    required super.name,
    required super.image,
    required super.url,
    super.webViewConfig,
    super.highSafety,
  });

  factory GamesDataModel.fromJson(Map<String, dynamic> json) {
    return GamesDataModel(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['name'], ''),
      image: parseValue<String>(json['image'], ''),
      url: parseValue<String>(json['url'], ''),
      webViewConfig: parseValue<bool>(json['webView_config'], false),
      highSafety: parseValue<int>(json['high_safety'], 0),
    );
  }
}
