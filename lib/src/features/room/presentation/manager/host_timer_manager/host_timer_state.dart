part of 'host_timer_bloc.dart';

class HostTimerState {
  final int elapsedSeconds;
  final bool isRunning;

  HostTimerState({
    required this.elapsedSeconds,
    required this.isRunning,
  });

  factory HostTimerState.initial() => HostTimerState(
        elapsedSeconds: 0,
        isRunning: false,
      );

  HostTimerState copyWith({
    int? elapsedSeconds,
    bool? isRunning,
  }) {
    return HostTimerState(
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}
