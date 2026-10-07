import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/entities/free_games_images_entity.dart';

class FreeGamesModel extends FreeGamesEntity {
  const FreeGamesModel({
    required super.dice,
    required super.rps,
    required super.giftBox,
  });

  factory FreeGamesModel.fromJson(Map<String, dynamic> json) {
    return FreeGamesModel(
      dice: FreeGameEntity(
        id: parseValue<int>(json['dice']?['id'], 0),
        image: parseValue<String>(json['dice']?['image'], ''),
      ),
      rps: FreeGameEntity(
        id: parseValue<int>(json['rps']?['id'], 0),
        image: parseValue<String>(json['rps']?['image'], ''),
      ),
      giftBox: FreeGameEntity(
        id: parseValue<int>(json['gift_box']?['id'], 0),
        image: parseValue<String>(json['gift_box']?['image'], ''),
      ),
    );
  }
}
