part of 'user_online_bloc.dart';

abstract class BaseUserOnlineEvent extends Equatable {
  final String? userId;
  const BaseUserOnlineEvent({this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Starts watching a peer's presence while their conversation is open: does the
/// first fetch and then keeps it live (polling every ~10s, plus any pushed
/// presence updates) until [StopUserPresenceEvent] / the bloc closes.
class UserOnlineEvent extends BaseUserOnlineEvent {
  const UserOnlineEvent({required super.userId});
}

/// A presence update pushed from a realtime source (e.g. a legacy realtime
/// presence-chat.user.{id} channel) — applied without hitting the network.
class UserPresenceChangedEvent extends BaseUserOnlineEvent {
  final int online;
  final String? lastSeen;
  const UserPresenceChangedEvent({
    required super.userId,
    required this.online,
    this.lastSeen,
  });

  @override
  List<Object?> get props => [userId, online, lastSeen];
}

/// Internal tick that re-fetches the watched peer's status while the chat is open
/// so 'متصل الآن' / 'آخر ظهور' stay current without a realtime channel.
class _UserPresencePollEvent extends BaseUserOnlineEvent {
  const _UserPresencePollEvent();
}

/// Stops the polling timer (chat closed). Safe to send when nothing is watched.
class StopUserPresenceEvent extends BaseUserOnlineEvent {
  const StopUserPresenceEvent();
}
