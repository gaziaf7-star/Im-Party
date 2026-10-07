import 'package:equatable/equatable.dart';

class ReplaceWithGoldItemEntity extends Equatable{
  final int id;
  final int coin;
  final int diamonds;

  const ReplaceWithGoldItemEntity({
    required this.id,
    required this.coin,
    required this.diamonds,
  });

  @override
  List<Object?> get props => [
    id,
    coin,
    diamonds,
  ];

}

class ReplaceWithGoldEntity extends Equatable{
  final int diamonds;
  final List<ReplaceWithGoldItemEntity> data;

  const ReplaceWithGoldEntity({
    required this.diamonds,
    required this.data,
  });

  @override
  List<Object?> get props => [
    diamonds,
    data,
  ];

}
