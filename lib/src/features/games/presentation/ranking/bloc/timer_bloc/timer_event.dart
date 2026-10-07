import 'package:equatable/equatable.dart';
import '../../../../../../core/constants/enums.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object> get props => [];
}

class UpdateDailyTimeLeftEvent extends TimerEvent {}

class UpdateWeeklyTimeLeftEvent extends TimerEvent {}

class UpdateMonthlyTimeLeftEvent extends TimerEvent {}

class ActivateCountdownEvent extends TimerEvent {
  final CountdownType type;

  const ActivateCountdownEvent(this.type);

  @override
  List<Object> get props => [type];
}
class CloseTimerEvent extends TimerEvent {}

