part of 'user_badges_bloc.dart';

abstract class UserBadgesEvent extends Equatable {
  const UserBadgesEvent();

  @override
  List<Object?> get props => [];
}

class GetUserBadges extends UserBadgesEvent {
  final String id;
  const GetUserBadges({required this.id});

  @override
  List<Object?> get props => [id];
}

class GetMyBadges extends UserBadgesEvent {
  const GetMyBadges();
}

class InitialUserBadges extends UserBadgesEvent {
  const InitialUserBadges();
}
