import 'package:equatable/equatable.dart';

class GoldCoinsEntity extends Equatable {
  final int id;
  final int coin;
  final String usd;

  const GoldCoinsEntity({
    required this.id,
    required this.coin,
    required this.usd,
  });

  @override
  List<Object> get props => [id, coin, usd];
}
