part of 'get_charge_coins_history_bloc.dart';

sealed class BaseGetChargeCoinsHistoryEvent extends Equatable {
  const BaseGetChargeCoinsHistoryEvent();
  @override
  List<Object?> get props => [];
}
 class GetChargeCoinsHistoryEvent extends BaseGetChargeCoinsHistoryEvent {
  const GetChargeCoinsHistoryEvent();
}
