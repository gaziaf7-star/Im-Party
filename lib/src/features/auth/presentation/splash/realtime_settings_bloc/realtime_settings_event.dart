part of 'realtime_settings_bloc.dart';

sealed class RealtimeSettingsEvent extends Equatable {
  const RealtimeSettingsEvent();

  @override
  List<Object?> get props => [];
}

final class FetchRealtimeSettings extends RealtimeSettingsEvent {
  const FetchRealtimeSettings();

  @override
  List<Object?> get props => [];
}
