import 'package:general/src/core/index.dart';

class AllGamesEntity extends Equatable{
  final List<GamesDataEntity> miniGames;
  final List<GamesDataEntity> fullGames;

  const AllGamesEntity({
    required this.miniGames,
    required this.fullGames,
  });

  @override
  List<Object?> get props => [
    fullGames,
  ];
}
class GamesDataEntity extends Equatable {
  final int? id;
  final String? name;
  final String? image;
  final String? url;
  final bool? webViewConfig;
  final int? highSafety;

  const GamesDataEntity({
    required this.id,
    required this.name,
    required this.image,
    required this.url,
    this.webViewConfig,
    this.highSafety,
  });
  @override
  List<Object?> get props => [
    id,
    name,
    image,
    url,
    webViewConfig,
    highSafety
  ];
}
