part of 'get_coins_history_bloc.dart';

sealed class BaseGetGoogleCoinsHistoryEvent extends Equatable {
  const BaseGetGoogleCoinsHistoryEvent();

  @override
  List<Object?> get props => [];
}

class GetGoogleCoinsHistoryEvent extends BaseGetGoogleCoinsHistoryEvent {
  const GetGoogleCoinsHistoryEvent();
}
