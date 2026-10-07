part of 'charge_coin_for_user_bloc.dart';

abstract class BaseChargeCoinForUserEvent extends Equatable {
  const BaseChargeCoinForUserEvent();

  @override
  List<Object> get props => [];
}

class ChargeCoinForUserEvent extends BaseChargeCoinForUserEvent {
  final String id;
  final String amount;
  final String type;
  final BuildContext context;
  const ChargeCoinForUserEvent({
    required this.amount,
    required this.id,
    required this.type,
    required this.context,
  });

  @override
  List<Object> get props => [id, amount, type,context];
}
