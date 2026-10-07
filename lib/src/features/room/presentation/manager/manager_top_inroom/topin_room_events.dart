// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class TopInRoonEvents extends Equatable {
  const TopInRoonEvents();
}

class GetTopIn24HoursRoomEvent extends TopInRoonEvents {

  String roomId;

  GetTopIn24HoursRoomEvent(
      { required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class GetTopInTotalRoomEvent extends TopInRoonEvents {
  String roomId;

  GetTopInTotalRoomEvent(
      { required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class GetDiamondsTopDayEvent extends TopInRoonEvents {
  final String roomId;

  const GetDiamondsTopDayEvent({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class GetDiamondsTopWeeklyEvent extends TopInRoonEvents {
  final String roomId;

  const GetDiamondsTopWeeklyEvent({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class GetDiamondsTopMonthlyEvent extends TopInRoonEvents {
  final String roomId;

  const GetDiamondsTopMonthlyEvent({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class GetCoinsTopDayEvent extends TopInRoonEvents {
  final String roomId;

  const GetCoinsTopDayEvent({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class GetCoinsTopWeeklyEvent extends TopInRoonEvents {
  final String roomId;

  const GetCoinsTopWeeklyEvent({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class GetCoinsTopMonthlyEvent extends TopInRoonEvents {
  final String roomId;

  const GetCoinsTopMonthlyEvent({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class ChangeColorEvent extends TopInRoonEvents {
  final Color color;

  const ChangeColorEvent({required this.color});

  @override
  List<Object?> get props => [color];
}
