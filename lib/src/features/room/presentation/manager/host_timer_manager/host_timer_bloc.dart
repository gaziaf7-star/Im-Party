import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:general/src/features/room/presentation/room_ticker.dart';

part 'host_timer_event.dart';
part 'host_timer_state.dart';

class HostTimerBloc extends Bloc<HostTimerEvent, HostTimerState> {
  StreamSubscription<int>? _tickerSubscription;

  HostTimerBloc() : super(HostTimerState.initial()) {
    on<StartHostTimer>(_onStart);
    on<StopHostTimer>(_onStop);
    on<TickHostTimer>(_onTick);
  }

  void _onStart(StartHostTimer event, Emitter<HostTimerState> emit) {
    RoomTicker.instance.unsubscribe(_tickerSubscription);
    emit(state.copyWith(elapsedSeconds: 0, isRunning: true));

    _tickerSubscription = RoomTicker.instance.subscribe((_) {
      add(TickHostTimer());
    });
  }

  void _onStop(StopHostTimer event, Emitter<HostTimerState> emit) {
    RoomTicker.instance.unsubscribe(_tickerSubscription);
    _tickerSubscription = null;
    emit(state.copyWith(isRunning: false));
  }

  void _onTick(TickHostTimer event, Emitter<HostTimerState> emit) {
    emit(state.copyWith(elapsedSeconds: state.elapsedSeconds + 1));
  }

  @override
  Future<void> close() {
    RoomTicker.instance.unsubscribe(_tickerSubscription);
    _tickerSubscription = null;
    return super.close();
  }
}
