import 'package:equatable/equatable.dart';

/// Diamond -> Coin exchange settings from `GET /wallets/exchange/v2/list` --
/// per the API spec provided for this feature: "gets exchange percentage +
/// user's current diamond info". [rate] is how many coins 1 diamond is
/// worth; [diamonds] is the user's current diamond balance as reported by
/// this endpoint (the Wallet screen's own balance, from MyStoreBloc, is
/// still treated as the source of truth for display -- this is only used to
/// compute the live "you will receive" preview and as a fallback).
class ExchangeSettingsEntity extends Equatable {
  final num rate;
  final num diamonds;

  const ExchangeSettingsEntity({
    required this.rate,
    required this.diamonds,
  });

  @override
  List<Object?> get props => [rate, diamonds];
}