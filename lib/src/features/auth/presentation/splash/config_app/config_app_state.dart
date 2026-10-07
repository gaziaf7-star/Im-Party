part of 'config_app_bloc.dart';

class ConfigAppState extends Equatable {
  final RequestState requestState;
  final ConfigModel? config;

  const ConfigAppState({
    this.requestState = RequestState.idle,
    this.config,
  });

  ConfigAppState copyWith({
    RequestState? requestState,
    ConfigModel? config,
  }) {
    return ConfigAppState(
      requestState: requestState ?? this.requestState,
      config: config ?? config,
    );
  }

  @override
  List<Object?> get props => [requestState, config];
}
