

part of 'get_setting_bloc.dart';

// Unified GetSettingState class to manage all states
class GetSettingState extends Equatable {
  final RequestState state; // To track loading, success, message
  final SettingModel? settingModel; // Only used in success state
  final String? message; // Only used in message state

  const GetSettingState({
    this.state = RequestState.idle,
    this.settingModel,
    this.message,
  });

  GetSettingState copyWith({
    RequestState? state,
    SettingModel? settingModel,
    String? message,
  }) {
    return GetSettingState(
      state: state ?? this.state,
      settingModel: settingModel ?? this.settingModel,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [state, settingModel, message];
}

