part of 'user_online_bloc.dart';

class UserOnlineState extends Equatable {
  final int online;
  final String? lastSeen;
  final RequestState reqState;

  const UserOnlineState({
    this.online = 0,
    this.lastSeen,
    this.reqState = RequestState.loading,
  });

  UserOnlineState copyWith({
    int? online,
    String? lastSeen,
    RequestState? reqState,
  }) {
    return UserOnlineState(
      online: online ?? this.online,
      lastSeen: lastSeen ?? this.lastSeen,
      reqState: reqState ?? this.reqState,
    );
  }

  @override
  List<Object?> get props => [online, lastSeen, reqState];
}
