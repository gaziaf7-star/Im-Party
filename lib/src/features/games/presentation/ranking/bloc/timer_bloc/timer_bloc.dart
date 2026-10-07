// // timer_bloc.dart
// import 'dart:async';
// import 'dart:developer';

import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/constants/enums.dart';
import 'timer_event.dart';
import 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  TimerBloc() : super(const TimerState()) {
    // _streamController = StreamController<DateTime>.broadcast();
    on<ActivateCountdownEvent>(_onUpdateTimeLeft);
    on<UpdateDailyTimeLeftEvent>(_onUpdateDailyTimeLeft);
    on<UpdateWeeklyTimeLeftEvent>(_onUpdateWeeklyTimeLeft);
    on<UpdateMonthlyTimeLeftEvent>(_onUpdateMonthlyTimeLeft);
    on<CloseTimerEvent>(_closeTimer);
  }

StreamSubscription? periodicSubscription;
  Stream<TimerState>? dailyStream;
  StreamSubscription<TimerState>? h;
  void _onUpdateTimeLeft(
      ActivateCountdownEvent event, Emitter<TimerState> emit) {
    switch (event.type) {
      case CountdownType.daily:
        h?.cancel();
        h = null;
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

  void _onUpdateDailyTimeLeft(
      UpdateDailyTimeLeftEvent event, Emitter<TimerState> emit) async {
    await emit.forEach(
      dailyStream = Stream.periodic(const Duration(seconds: 1), (_) {
        //   final nowhere = DateTime.now();
        final nowUtc = DateTime.now().toUtc();
        log('stream is working');
        //     final nowUtc = DateTime.utc(nowhere.year, nowhere.month, nowhere.day, nowhere.hour - 2, nowhere.minute, nowhere.second); // Testing 23:55
//final now = DateTime.utc(2024, 11, 8, 0, 5);   // Testing 00:05

        // Calculate target time for next UTC midnight.
        DateTime targetTime;
        if (nowUtc.hour >= 22) {
          // If it's after 10 PM UTC, set target to the next midnight (24:00 UTC)
          targetTime = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day, 24);
        } else {
          // Otherwise, set target to midnight today
          targetTime = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day + 1);
        }

        final timeLeft = targetTime.difference(nowUtc);
        return state.copyWith(dailyCountdown: timeLeft);
      }),
      onData: (updatedState) => updatedState,
    );
  }



  void _onUpdateWeeklyTimeLeft(
      UpdateWeeklyTimeLeftEvent event, Emitter<TimerState> emit) async {
    await emit.forEach(
      Stream.periodic(const Duration(seconds: 1), (_) {
        //  final now = DateTime.now().toUtc().add(const Duration(hours: -2));
       // final nowhere = DateTime.now();
        final nowUtc = DateTime.now().toUtc();
        //   final nowUtc = DateTime.utc(nowhere.year, nowhere.month, nowhere.day, nowhere.hour - 2, nowhere.minute, nowhere.second);
        DateTime targetTime;
        int daysUntilSaturday;
        if (nowUtc.weekday <= DateTime.friday) {
          daysUntilSaturday = DateTime.friday - nowUtc.weekday;
        } else {
          daysUntilSaturday = 7 - nowUtc.weekday + DateTime.friday;

          //  daysUntilSaturday = 7 - nowUtc.weekday - 1;
          log('_onUpdateWeeklyTimeLeft daysUntilFriday more $daysUntilSaturday');
          log('_onUpdateWeeklyTimeLeft daysUntilFriday more ${nowUtc.weekday}');
        }
        if (nowUtc.hour >= 22) {
          // If it's after 10 PM UTC, set target to the next midnight (24:00 UTC)
          targetTime = DateTime.utc(
              nowUtc.year, nowUtc.month, nowUtc.day + daysUntilSaturday, 24);
        } else {
          // Otherwise, set target to midnight today
          targetTime = DateTime.utc(
              nowUtc.year, nowUtc.month, nowUtc.day + daysUntilSaturday + 1);
        }

        final timeLeft = targetTime.difference(nowUtc);

        return state.copyWith(weeklyCountdown: timeLeft);
      }),
      onData: (updatedState) => updatedState,
    );
  }

  void _onUpdateMonthlyTimeLeft(
      UpdateMonthlyTimeLeftEvent event, Emitter<TimerState> emit) async {
    //  _timer?.cancel();
    await emit.forEach(
      Stream.periodic(const Duration(seconds: 1), (_) {
        final nowUtc = DateTime.now().toUtc();
        DateTime targetTime;
        log('_onUpdateWeeklyTimeLeft nowUtc: $nowUtc');

        if (nowUtc.hour >= 22) {
          // If it's after 10 PM UTC, set target to the next midnight (24:00 UTC)
          targetTime = DateTime.utc(nowUtc.year, nowUtc.month + 1, 1, 24);
        } else {
          // Otherwise, set target to midnight today
          targetTime = DateTime.utc(nowUtc.year, nowUtc.month + 1, 1);
        }
        log('_onUpdateWeeklyTimeLeft targetTime: $targetTime');

        // targetTime = DateTime(now.year, now.month + 1, 1);
        final timeLeft = targetTime.difference(nowUtc);
        log('_onUpdateWeeklyTimeLeft timeLeft: $timeLeft');

        return state.copyWith(monthlyCountdown: timeLeft);
      }),
      onData: (updatedState) => updatedState,
    );
  }

  void _closeTimer(CloseTimerEvent event, Emitter<TimerState> emit) {
    periodicSubscription?.cancel();
    periodicSubscription = null;
    h?.cancel();
    h = null;
    emit(state.copyWith(
      dailyCountdown: Duration.zero,
      weeklyCountdown: Duration.zero,
      monthlyCountdown: Duration.zero,
    ));
  }

  @override
  Future<void> close() {
    periodicSubscription?.cancel();
    h?.cancel();
    return super.close();
  }
}
