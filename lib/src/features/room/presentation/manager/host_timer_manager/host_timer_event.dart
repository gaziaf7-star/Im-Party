part of 'host_timer_bloc.dart';

abstract class HostTimerEvent {}

class StartHostTimer extends HostTimerEvent {}

class StopHostTimer extends HostTimerEvent {}

class TickHostTimer extends HostTimerEvent {}
