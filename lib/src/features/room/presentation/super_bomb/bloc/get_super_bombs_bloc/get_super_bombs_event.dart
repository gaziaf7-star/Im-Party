part of 'get_super_bombs_bloc.dart';

abstract class SuperBombsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetSuperBombsEvent extends SuperBombsEvent {
  final String roomId;
  GetSuperBombsEvent(this.roomId);
}

class GetSuperBoomVideosEvent extends SuperBombsEvent {}

class GetSuperBoomRulesEvent extends SuperBombsEvent {}

class SelectSuperBomb extends SuperBombsEvent {
  final int index;
  SelectSuperBomb(this.index);
}