import 'package:general/src/features/games/games.dart';

class GamesEntity extends Equatable {
  final List<GameDataEntity>? fullGames;
  final List<GameDataEntity>? miniGames;

  const GamesEntity({
    this.fullGames,
    this.miniGames,
  });

  @override
  List<Object?> get props => [fullGames, miniGames];
}

class GameDataEntity extends Equatable {
  final int? id;
  final String? name;
  final String? image;
  final String? url;
  final bool? webViewConfig;
  final bool? isStatic;
  final int? highSafety;
  final double? high;
  final int? inRoom;
  final int? isHot;
  final int? type;

  const GameDataEntity({
    this.id,
    this.name,
    this.image,
    this.url,
    this.webViewConfig,
    this.highSafety,
    this.high,
    this.inRoom,
    this.isHot,
    this.isStatic = false,
    this.type,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        image,
        url,
        webViewConfig,
        isStatic,
        highSafety,
        high,
        inRoom,
        type,
      ];
}
