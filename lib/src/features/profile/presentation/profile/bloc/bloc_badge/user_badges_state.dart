part of 'user_badges_bloc.dart';

class UserBadgesState extends Equatable {
  final List<ImageData>? userBadge;
  final RequestState userStates;
  final String userBadgeMessage;
  final String? lastUserId;

  final List<ImageData>? myBadge;
  final RequestState myStates;
  final String myBadgeMessage;

  const UserBadgesState({
    this.userBadge = const [],
    this.userStates = RequestState.loading,
    this.userBadgeMessage = '',
    this.lastUserId,
    this.myBadge = const [],
    this.myStates = RequestState.loading,
    this.myBadgeMessage = '',
  });

  UserBadgesState copyWith({
    List<ImageData>? userBadge,
    RequestState? userStates,
    String? userBadgeMessage,
    String? lastUserId,
    List<ImageData>? myBadge,
    RequestState? myStates,
    String? myBadgeMessage,
  }) {
    return UserBadgesState(
      userBadge: userBadge ?? this.userBadge,
      userStates: userStates ?? this.userStates,
      userBadgeMessage: userBadgeMessage ?? this.userBadgeMessage,
      lastUserId: lastUserId ?? this.lastUserId,
      myBadge: myBadge ?? this.myBadge,
      myStates: myStates ?? this.myStates,
      myBadgeMessage: myBadgeMessage ?? this.myBadgeMessage,
    );
  }

  @override
  List<Object?> get props => [
        userBadge,
        userStates,
        userBadgeMessage,
        lastUserId,
        myBadge,
        myStates,
        myBadgeMessage,
      ];
}
