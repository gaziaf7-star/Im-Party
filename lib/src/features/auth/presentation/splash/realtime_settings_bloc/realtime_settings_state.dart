part of 'realtime_settings_bloc.dart';


class RealtimeSettingsStates extends Equatable {
  final RequestState reqState;
  final String message;

  const RealtimeSettingsStates(
      {this.reqState = RequestState.idle, this.message = ''});



  RealtimeSettingsStates copyWith({
    RequestState? reqState,
    String? message,
  }) {
    return RealtimeSettingsStates(
      reqState: reqState ?? this.reqState,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    message,
    reqState,
  ];
}
