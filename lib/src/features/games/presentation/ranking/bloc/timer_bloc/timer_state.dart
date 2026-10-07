import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:general/src/features/games/presentation/ranking/bloc/timer_bloc/timer_event.dart';

import '../../../../../../core/constants/enums.dart';

class TimerState extends Equatable {
  final Duration dailyCountdown;
  final Duration weeklyCountdown;
  final Duration monthlyCountdown;

  const TimerState({
    this.dailyCountdown = Duration.zero,
    this.weeklyCountdown = Duration.zero,
    this.monthlyCountdown = Duration.zero,
  });

  TimerState copyWith({
    Duration? dailyCountdown,
    Duration? weeklyCountdown,
    Duration? monthlyCountdown,
  }) {
    return TimerState(
      dailyCountdown: dailyCountdown ?? this.dailyCountdown,
      weeklyCountdown: weeklyCountdown ?? this.weeklyCountdown,
      monthlyCountdown: monthlyCountdown ?? this.monthlyCountdown,
    );
  }

  @override
  List<Object> get props => [dailyCountdown, weeklyCountdown, monthlyCountdown];
}

class TimerWithControllerBloc extends Bloc<TimerEvent, TimerState> {
  late StreamController<DateTime> _streamController;
  bool _isTimerActive = false; // Flag to control if the stream is active

  TimerWithControllerBloc() : super(const TimerState()) {
    _streamController = StreamController<DateTime>.broadcast();

    on<ActivateCountdownEvent>(_onUpdateTimeLeft);
    on<UpdateDailyTimeLeftEvent>(_onUpdateDailyTimeLeft);
    on<UpdateWeeklyTimeLeftEvent>(_onUpdateWeeklyTimeLeft);
    on<UpdateMonthlyTimeLeftEvent>(_onUpdateMonthlyTimeLeft);
    on<CloseTimerEvent>(_closeTimer);
  }

  // Handling the ActivateCountdownEvent and starting the appropriate timer
  void _onUpdateTimeLeft(
      ActivateCountdownEvent event, Emitter<TimerState> emit) {
    switch (event.type) {
      case CountdownType.daily:
        add(UpdateDailyTimeLeftEvent());
        break;
      case CountdownType.weekly:
        add(UpdateWeeklyTimeLeftEvent());
        break;
      case CountdownType.monthly:
        add(UpdateMonthlyTimeLeftEvent());
        break;
    }
  }

  // Handle daily countdown with the periodic stream
  void _onUpdateDailyTimeLeft(
      UpdateDailyTimeLeftEvent event, Emitter<TimerState> emit) async {
    if (_isTimerActive) {
      return; // Prevent starting another stream if already active
    }

    _isTimerActive = true;

    await emit.forEach(
      _streamController
          .stream, // Listen to the stream controlled by StreamController
      onData: (currentTime) {
        final targetTime = DateTime.utc(
            currentTime.year, currentTime.month, currentTime.day + 1);
        final timeLeft = targetTime.difference(currentTime);
        return state.copyWith(dailyCountdown: timeLeft); // Update the state
      },
    );

    _startDailyStream(); // Start the stream after subscribing
  }

  // Handle weekly countdown with the periodic stream
  void _onUpdateWeeklyTimeLeft(
      UpdateWeeklyTimeLeftEvent event, Emitter<TimerState> emit) async {
    if (_isTimerActive) return;

    _isTimerActive = true;

    await emit.forEach(
      _streamController.stream,
      onData: (currentTime) {
        int daysUntilSaturday = DateTime.friday - currentTime.weekday;
        DateTime targetTime;
        if (currentTime.hour >= 22) {
          targetTime = DateTime.utc(currentTime.year, currentTime.month,
              currentTime.day + daysUntilSaturday, 24);
        } else {
          targetTime = DateTime.utc(currentTime.year, currentTime.month,
              currentTime.day + daysUntilSaturday + 1);
        }
        final timeLeft = targetTime.difference(currentTime);
        return state.copyWith(weeklyCountdown: timeLeft);
      },
    );

    _startWeeklyStream();
  }

  // Handle monthly countdown with the periodic stream
  void _onUpdateMonthlyTimeLeft(
      UpdateMonthlyTimeLeftEvent event, Emitter<TimerState> emit) async {
    if (_isTimerActive) return;

    _isTimerActive = true;

    await emit.forEach(
      _streamController.stream,
      onData: (currentTime) {
        DateTime targetTime;
        if (currentTime.hour >= 22) {
          targetTime =
              DateTime.utc(currentTime.year, currentTime.month + 1, 1, 24);
        } else {
          targetTime = DateTime.utc(currentTime.year, currentTime.month + 1, 1);
        }
        final timeLeft = targetTime.difference(currentTime);
        return state.copyWith(monthlyCountdown: timeLeft);
      },
    );

    _startMonthlyStream();
  }

  // Start the daily stream
  void _startDailyStream() {
    _streamController =
        StreamController<DateTime>.broadcast(); // Restart stream
    Stream.periodic(const Duration(seconds: 1), (_) {
      final nowUtc = DateTime.now().toUtc();
      _streamController.add(nowUtc); // Add current UTC time to stream
    });
  }

  // Start the weekly stream
  void _startWeeklyStream() {
    _streamController =
        StreamController<DateTime>.broadcast(); // Restart stream
    Stream.periodic(const Duration(seconds: 1), (_) {
      final nowUtc = DateTime.now().toUtc();
      _streamController.add(nowUtc); // Add current UTC time to stream
    });
  }

  // Start the monthly stream
  void _startMonthlyStream() {
    _streamController =
        StreamController<DateTime>.broadcast(); // Restart stream
    Stream.periodic(const Duration(seconds: 1), (_) {
      final nowUtc = DateTime.now().toUtc();
      _streamController.add(nowUtc); // Add current UTC time to stream
    });
  }

  // Close the timer and reset the countdowns
  void _closeTimer(CloseTimerEvent event, Emitter<TimerState> emit) {
    _streamController.close(); // Close the stream
    _isTimerActive = false; // Reset the active flag
    emit(state.copyWith(
      dailyCountdown: Duration.zero,
      weeklyCountdown: Duration.zero, 
      monthlyCountdown: Duration.zero,
    ));
  }

  @override
  Future<void> close() {
    _streamController
        .close(); // Ensure the stream is closed when the bloc is disposed
    return super.close();
  }
}
