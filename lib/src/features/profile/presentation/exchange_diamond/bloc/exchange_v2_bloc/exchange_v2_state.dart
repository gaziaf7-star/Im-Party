part of 'exchange_v2_bloc.dart';

class ExchangeV2State extends Equatable {
  final RequestState reqStateSettings;
  final RequestState reqStateExchange;
  final RequestState reqStateLogs;
  final ExchangeSettingsModel? settings;
  final ExchangeLogModel? logs;
  final String? messageSettings;
  final String? messageExchange;
  final String? messageLogs;

  const ExchangeV2State({
    this.reqStateSettings = RequestState.idle,
    this.reqStateExchange = RequestState.idle,
    this.reqStateLogs = RequestState.idle,
    this.settings,
    this.logs,
    this.messageSettings,
    this.messageExchange,
    this.messageLogs,
  });

  ExchangeV2State copyWith({
    RequestState? reqStateSettings,
    RequestState? reqStateExchange,
    RequestState? reqStateLogs,
    ExchangeSettingsModel? settings,
    ExchangeLogModel? logs,
    String? messageSettings,
    String? messageExchange,
    String? messageLogs,
  }) {
    return ExchangeV2State(
      reqStateSettings: reqStateSettings ?? this.reqStateSettings,
      reqStateExchange: reqStateExchange ?? this.reqStateExchange,
      reqStateLogs: reqStateLogs ?? this.reqStateLogs,
      settings: settings ?? this.settings,
      logs: logs ?? this.logs,
      messageSettings: messageSettings ?? this.messageSettings,
      messageExchange: messageExchange ?? this.messageExchange,
      messageLogs: messageLogs ?? this.messageLogs,
    );
  }

  @override
  List<Object?> get props => [
    reqStateSettings,
    reqStateExchange,
    reqStateLogs,
    settings,
    logs,
    messageSettings,
    messageExchange,
    messageLogs,
  ];
}