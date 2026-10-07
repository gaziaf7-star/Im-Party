part of 'explore_bloc.dart';

abstract class ExploreEvent extends Equatable {
  final bool isGamesLoading, isGamesRoomLoading, isUsersLoading;
  final String gameId;
  final List<UserProfileEntity> users;

  const ExploreEvent({
    this.isGamesLoading = true,
    this.isGamesRoomLoading = true,
    this.isUsersLoading = true,
    this.gameId = '',
    this.users =const [],
  });

  @override
  List<Object?> get props =>
      [
        gameId,
        isGamesLoading,
        isGamesRoomLoading,
        isUsersLoading,
        users,
      ];
}

class ScrollGameEvent extends ExploreEvent {
  final bool? isScrolled;
  const ScrollGameEvent({this.isScrolled});
}

class FetchGamesEvent extends ExploreEvent {
  final String type;

  const FetchGamesEvent({
    required this.type ,
    super.isGamesLoading,
  });

}
class FetchGamesRoomEvent extends ExploreEvent {
  const FetchGamesRoomEvent({super.gameId, super.isGamesRoomLoading});
}

class FetchUsersEvent extends ExploreEvent {
  const FetchUsersEvent({super.isUsersLoading});
}

class FetchMoreGamersEvent extends ExploreEvent {
  const FetchMoreGamersEvent({super.isUsersLoading});
}

class UpdateUsersEvent extends ExploreEvent {
  const UpdateUsersEvent({super.users});
}

class StopGameEvent extends ExploreEvent {
  const StopGameEvent();
}

class FetchGamersEvent extends ExploreEvent {
  const FetchGamersEvent();
}
