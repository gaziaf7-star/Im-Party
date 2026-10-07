import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/data/model/user_badges_model.dart';

class GetUserBadgesState extends Equatable {
  final UserBadgesModel? userBadge;
  final RequestState userStates;
  final String userBadgeMessage;
  final int? lastUserId;

  const GetUserBadgesState({
    this.userBadge,
    this.userStates = RequestState.loading,
    this.userBadgeMessage = '',
    this.lastUserId,
  });

  GetUserBadgesState copyWith({
    UserBadgesModel? userBadge,
    RequestState? userStates,
    String? userBadgeMessage,
    int? lastUserId,
  }) {
    return GetUserBadgesState(
      userBadge: userBadge ?? this.userBadge,
      userStates: userStates ?? this.userStates,
      userBadgeMessage: userBadgeMessage ?? this.userBadgeMessage,
      lastUserId: lastUserId ?? this.lastUserId,
    );
  }

  @override
  List<Object?> get props => [
        userBadge,
        userStates,
        userBadgeMessage,
        lastUserId,
      ];
}
