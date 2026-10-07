import 'package:equatable/equatable.dart';

abstract class PKEvents extends Equatable {}

class ShowPKEvent extends PKEvents {
  final String roomId;

  ShowPKEvent({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class StartPKEvent extends PKEvents {
  final String roomId;
  final String time;

  StartPKEvent({required this.time, required this.roomId});

  @override
  List<Object?> get props => [roomId, time];
}

class ClosePKEvent extends PKEvents {
  final String roomId;
  final String pkId;

  ClosePKEvent({required this.roomId, required this.pkId});

  @override
  List<Object?> get props => [roomId, pkId];
}

class HidePKEvent extends PKEvents {
  final String roomId;

  HidePKEvent({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}
