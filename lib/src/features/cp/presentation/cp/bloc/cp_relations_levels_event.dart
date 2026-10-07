part of'cp_relations_levels_bloc.dart';

abstract class CpRelationsLevelsEvent extends Equatable {
  const CpRelationsLevelsEvent();

  @override
  List<Object> get props => [];
}

class GetCpRelationsLevelsEvent extends CpRelationsLevelsEvent {}
class GetCpRelationsSpecialFriendLevelsEvent extends CpRelationsLevelsEvent {}
