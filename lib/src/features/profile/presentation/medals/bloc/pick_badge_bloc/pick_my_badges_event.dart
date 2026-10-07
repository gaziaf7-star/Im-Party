import 'package:equatable/equatable.dart';

abstract class BasePickMyBadgesEvent extends Equatable {
  const BasePickMyBadgesEvent();
}

class PickMyBadgesEvent extends BasePickMyBadgesEvent {
  final List<int> ids;
  const PickMyBadgesEvent({required this.ids});

  @override
  List<Object?> get props => [ids];
}


