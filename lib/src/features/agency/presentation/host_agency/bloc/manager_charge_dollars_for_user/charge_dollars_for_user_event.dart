part of'charge_dollars_for_user_bloc.dart';

abstract class BaseChargeDollarsForUserEvent extends Equatable {
  const BaseChargeDollarsForUserEvent();

  @override
  List<Object?> get props => [];
}

class ChargeDollarsForUserEvent extends BaseChargeDollarsForUserEvent {
  final String id;
  final String amount;
  final String type;

  final BuildContext context ;
  const ChargeDollarsForUserEvent({
    required this.amount,
    required this.id,
    required this.context,
    required this.type,

  });

  @override
  List<Object?> get props => [id, amount,context,type];
}
