import 'package:equatable/equatable.dart';

abstract class BasePickMyBadgesState extends Equatable {
  const BasePickMyBadgesState();

  @override
  List<Object?> get props => [];
}

class PickMyBadgesInitial extends BasePickMyBadgesState {
  const PickMyBadgesInitial();
}

class PickMyBadgesLoadingState extends BasePickMyBadgesState {
  const PickMyBadgesLoadingState();
}

class PickMyBadgesErrorState extends BasePickMyBadgesState {
  final String error;
  const PickMyBadgesErrorState({required this.error});
  @override
  List<Object> get props => [error];
}

class PickMyBadgesSucssesState extends BasePickMyBadgesState {
  final String message;
  const PickMyBadgesSucssesState({required this.message});
  @override
  List<Object> get props => [];
}
