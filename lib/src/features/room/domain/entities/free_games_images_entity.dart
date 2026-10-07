import 'package:equatable/equatable.dart';

class FreeGameEntity extends Equatable {
  final int id;
  final String image;

  const FreeGameEntity({
    required this.id,
    required this.image,
  });

  @override
  List<Object> get props => [id, image];
}


class FreeGamesEntity extends Equatable {
  final FreeGameEntity dice;
  final FreeGameEntity rps;
  final FreeGameEntity giftBox;

  const FreeGamesEntity({
    required this.dice,
    required this.rps,
    required this.giftBox,
  });

  @override
  List<Object> get props => [dice, rps, giftBox];
}

