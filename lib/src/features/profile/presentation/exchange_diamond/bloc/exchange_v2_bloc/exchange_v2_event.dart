part of 'exchange_v2_bloc.dart';

abstract class ExchangeV2Event extends Equatable {
  const ExchangeV2Event();

  @override
  List<Object?> get props => [];
}

class GetExchangeSettingsEvent extends ExchangeV2Event {
  const GetExchangeSettingsEvent();
}

class MakeExchangeEvent extends ExchangeV2Event {
  final int diamonds;
  final int exchange;
  final BuildContext context;

  const MakeExchangeEvent({
    required this.diamonds,
    required this.exchange,
    required this.context,
  });

  @override
  List<Object?> get props => [diamonds, exchange];
}

class GetExchangeLogsEvent extends ExchangeV2Event {
  final int type;

  const GetExchangeLogsEvent({this.type = 0});

  @override
  List<Object?> get props => [type];
}