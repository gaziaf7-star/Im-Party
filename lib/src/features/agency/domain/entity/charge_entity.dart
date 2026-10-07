import 'package:equatable/equatable.dart';

class ChargeEntity extends Equatable {
  final String? coins;
  final String? usd;

  const ChargeEntity({
    this.coins,
    this.usd,
  });

  @override
  List<Object?> get props => [coins, usd];

  ChargeEntity copyWith({
    String? coins,
    String? usd,
  }) {
    return ChargeEntity(
      coins: coins ?? this.coins,
      usd: usd ?? this.usd,
    );
  }
}
