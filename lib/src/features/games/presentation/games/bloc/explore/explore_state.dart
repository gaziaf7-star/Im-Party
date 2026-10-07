part of 'explore_bloc.dart';
class ExploreState extends Equatable {
  final GamesEntity? innerGames;
  final RequestState innerReqStateGames;

  final GamesEntity? outerGames;
  final RequestState outerReqStateGames;

  // ✅ Keep existing fields untouched
  final List<GameDataEntity> allGames;
  final List<UserEntity> gamers;
  final List<RoomEntity> gamesRoom;
  final RequestState reqStateGamesRoom;
  final RequestState reqStateGamers;
  final List<UserProfileEntity> users;
  final RequestState reqStateUsers;
  final RequestState reqStateStopGame;
  final int pageGamers;
  final String gamersMessage;
  final String stopGameMessage;
  final int lastGamersPage;
  final int currentGamersPage;
  final bool isScrolled;
  final String isStopGamers;

  const ExploreState({
    this.innerGames,
    this.innerReqStateGames = RequestState.loading,

    this.outerGames,
    this.outerReqStateGames = RequestState.loading,

    this.gamers = const [],
    this.gamersMessage = '',
    this.stopGameMessage = '',
    this.isStopGamers = '',
    this.allGames = const [],
    this.reqStateStopGame = RequestState.loading,
    this.reqStateGamers = RequestState.loading,
    this.gamesRoom = const [],
    this.reqStateGamesRoom = RequestState.loading,
    this.users = const [],
    this.reqStateUsers = RequestState.loading,
    this.pageGamers = 2,
    this.lastGamersPage = 1,
    this.currentGamersPage = 1,
    this.isScrolled = false,
  });

  ExploreState copyWith({
    GamesEntity? innerGames,
    RequestState? innerReqStateGames,

    GamesEntity? outerGames,
    RequestState? outerReqStateGames,

    String? stopGameMessage,
    String? gamersMessage,
    RequestState? reqStateStopGame,
    List<RoomEntity>? gamesRoom,
    List<UserEntity>? gamers,
    RequestState? reqStateGamesRoom,
    RequestState? reqStateGamers,
    List<GameDataEntity>? allGames,
    List<UserProfileEntity>? users,
    RequestState? reqStateUsers,
    int? pageGamers,
    int? lastGamersPage,
    int? currentGamersPage,
    bool? isScrolled,
    String? isStopGamers,
  }) {
    return ExploreState(
      innerGames: innerGames ?? this.innerGames,
      innerReqStateGames: innerReqStateGames ?? this.innerReqStateGames,

      outerGames: outerGames ?? this.outerGames,
      outerReqStateGames: outerReqStateGames ?? this.outerReqStateGames,

      reqStateStopGame: reqStateStopGame ?? this.reqStateStopGame,
      gamersMessage: gamersMessage ?? this.gamersMessage,
      stopGameMessage: stopGameMessage ?? this.stopGameMessage,
      gamers: gamers ?? this.gamers,
      lastGamersPage: lastGamersPage ?? this.lastGamersPage,
      currentGamersPage: currentGamersPage ?? this.currentGamersPage,
      isScrolled: isScrolled ?? this.isScrolled,
      reqStateGamers: reqStateGamers ?? this.reqStateGamers,
      pageGamers: pageGamers ?? this.pageGamers,
      allGames: allGames ?? this.allGames,
      gamesRoom: gamesRoom ?? this.gamesRoom,
      reqStateGamesRoom: reqStateGamesRoom ?? this.reqStateGamesRoom,
      users: users ?? this.users,
      reqStateUsers: reqStateUsers ?? this.reqStateUsers,
      isStopGamers: isStopGamers ?? this.isStopGamers,
    );
  }

  @override
  List<Object?> get props => [
    innerGames,
    innerReqStateGames,
    outerGames,
    outerReqStateGames,
    reqStateStopGame,
    isStopGamers,
    stopGameMessage,
    gamersMessage,
    reqStateGamers,
    gamers,
    gamesRoom,
    reqStateGamesRoom,
    users,
    reqStateUsers,
    pageGamers,
    lastGamersPage,
    currentGamersPage,
    isScrolled,
  ];
}

// class ExploreState extends Equatable {
//   final GamesEntity? innerGames;
//   final RequestState innerReqStateGames;
//
//   final GamesEntity? outerGames;
//   final RequestState outerReqStateGames;
//   //complete in con and copywith and remove that is not in here
//
//   final List<GameDataEntity> allGames;
//   final List<UserEntity> gamers;
//   final List<RoomEntity> gamesRoom;
//   final RequestState reqStateGamesRoom;
//   final RequestState reqStateGamers;
//   final List<UserProfileEntity> users;
//   final RequestState reqStateUsers;
//   final RequestState reqStateStopGame;
//   final int pageGamers;
//   final String gamersMessage;
//   final String stopGameMessage;
//   final int lastGamersPage;
//   final int currentGamersPage;
//   final bool isScrolled;
//   final String isStopGamers;
//
//   const ExploreState({
//     this.games,
//     this.gamers = const [],
//     this.gamersMessage = '',
//     this.stopGameMessage = '',
//     this.isStopGamers = '',
//     this.allGames = const [],
//     this.reqStateStopGame = RequestState.loading,
//     this.reqStateGames = RequestState.loading,
//     this.reqStateGamers = RequestState.loading,
//     this.gamesRoom = const [],
//     this.reqStateGamesRoom = RequestState.loading,
//     this.users = const [],
//     this.reqStateUsers = RequestState.loading,
//     this.pageGamers = 2,
//     this.lastGamersPage = 1,
//     this.currentGamersPage = 1,
//     this.isScrolled = false,
//   });
//
//   ExploreState copyWith({
//     GamesEntity? games,
//     String? stopGameMessage,
//     String? gamersMessage,
//     RequestState? reqStateGames,
//     RequestState? reqStateStopGame,
//     List<RoomEntity>? gamesRoom,
//     List<UserEntity>? gamers,
//     RequestState? reqStateGamesRoom,
//     RequestState? reqStateGamers,
//     List<GameDataEntity>? allGames,
//     List<UserProfileEntity>? users,
//     RequestState? reqStateUsers,
//     int? pageGamers,
//     int? lastGamersPage,
//     int? currentGamersPage,
//     bool? isScrolled,
//     String? isStopGamers,
//   }) {
//     return ExploreState(
//       games: games ?? this.games,
//       reqStateStopGame: reqStateStopGame ?? this.reqStateStopGame,
//       gamersMessage: gamersMessage ?? this.gamersMessage,
//       stopGameMessage: stopGameMessage ?? this.stopGameMessage,
//       gamers: gamers ?? this.gamers,
//       lastGamersPage: lastGamersPage ?? this.lastGamersPage,
//       currentGamersPage: currentGamersPage ?? this.currentGamersPage,
//       isScrolled: isScrolled ?? this.isScrolled,
//       reqStateGamers: reqStateGamers ?? this.reqStateGamers,
//       pageGamers: pageGamers ?? this.pageGamers,
//       allGames: allGames ?? this.allGames,
//       reqStateGames: reqStateGames ?? this.reqStateGames,
//       gamesRoom: gamesRoom ?? this.gamesRoom,
//       reqStateGamesRoom: reqStateGamesRoom ?? this.reqStateGamesRoom,
//       users: users ?? this.users,
//       reqStateUsers: reqStateUsers ?? this.reqStateUsers,
//       isStopGamers: isStopGamers ?? this.isStopGamers,
//     );
//   }
//
//   @override
//   List<Object?> get props => [
//         reqStateStopGame,
//         games,
//         isStopGamers,
//         stopGameMessage,
//         gamersMessage,
//         reqStateGamers,
//         gamers,
//         reqStateGames,
//         gamesRoom,
//         reqStateGamesRoom,
//         users,
//         reqStateUsers,
//         pageGamers,
//         lastGamersPage,
//         currentGamersPage,
//         isScrolled,
//       ];
// }
