import 'package:equatable/equatable.dart';

abstract class OnRoomEvents extends Equatable {
  const OnRoomEvents();
}

class InitRoomEvent extends OnRoomEvents {
  @override
  List<Object?> get props => [];
}

class GetBackGroundEvent extends OnRoomEvents {
  @override
  List<Object?> get props => [];
}

class RemovePassRoomEvent extends OnRoomEvents {
  final String roomId;

  const RemovePassRoomEvent({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class LockCommentsEvent extends OnRoomEvents {
  final String roomId;

  const LockCommentsEvent({
    required this.roomId,
  });

  @override
  List<Object?> get props => [
        roomId,
      ];
}

class UnLockCommentsEvent extends OnRoomEvents {
  final String roomId;

  const UnLockCommentsEvent({
    required this.roomId,
  });

  @override
  List<Object?> get props => [
        roomId,
      ];
}

class RemoveChatRoomEvent extends OnRoomEvents {
  final String ownerId;

  const RemoveChatRoomEvent({required this.ownerId});

  @override
  List<Object?> get props => [ownerId];
}

class BanUserFromWritingEvent extends OnRoomEvents {
  final String ownerId;
  final String? userId;
  final String? time;
  final String type;

  const BanUserFromWritingEvent(
      {required this.type, required this.ownerId, this.userId, this.time});

  @override
  List<Object?> get props => [ownerId, userId, time, type];
}

class SendPobUpEvent extends OnRoomEvents {
  final String ownerId;
  final String message;

  const SendPobUpEvent({required this.ownerId, required this.message});

  @override
  List<Object?> get props => [ownerId, message];
}

class HideRoomEvent extends OnRoomEvents {
  const HideRoomEvent();

  @override
  List<Object?> get props => [];
}

class DisposeHideRoomEvent extends OnRoomEvents {
  const DisposeHideRoomEvent();

  @override
  List<Object?> get props => [];
}

class SendYallowBannerEvent extends OnRoomEvents {
  final String roomId;
  final String message;

  const SendYallowBannerEvent({required this.roomId, required this.message});

  @override
  List<Object?> get props => [roomId, message];
}

class ChangeGameModeRoomEvent extends OnRoomEvents {
  final String ownerId;
  final String gameId;

  const ChangeGameModeRoomEvent({required this.ownerId, required this.gameId});

  @override
  List<Object?> get props => [ownerId, gameId];
}
