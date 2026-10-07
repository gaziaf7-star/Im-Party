import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/games/domain/use_cases/fetch_users_gamers_uc.dart';
import 'package:general/src/features/games/domain/use_cases/stop_gamers_uc.dart';
import 'package:general/src/features/games/games.dart';

import '../../../../domain/entities/game_entity.dart';

part 'explore_event.dart';

part 'explore_state.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final FetchGamesUC _fetchGamesUC;
  final FetchGamesRoomUC _fetchGamesRoomUC;
  final FetchUsersUC _fetchUsersUC;
  final FetchUsersGamersUC _fetchUsersGamersUC;
  final StopGamersUc _stopGamersUC;

  ExploreBloc(
    this._fetchGamesUC,
    this._fetchGamesRoomUC,
    this._fetchUsersGamersUC,
    this._stopGamersUC,
    this._fetchUsersUC,
  ) : super(const ExploreState()) {
    on<FetchGamesEvent>(_fetchGamesEvent);
    on<ScrollGameEvent>(_scrollGameEvent);
    on<FetchGamesRoomEvent>(_fetchGamesRoomEvent);
    on<FetchUsersEvent>(_fetchUsersEvent);
    on<FetchMoreGamersEvent>(_fetchMoreUsersEvent);
    on<UpdateUsersEvent>(_updateUsersEvent);
    on<FetchGamersEvent>(_fetchGamersEvent);
    on<StopGameEvent>(_stopGameEvent);
  }

  Future<void> _scrollGameEvent(
    ScrollGameEvent event,
    Emitter<ExploreState> emit,
  ) async {
    emit(state.copyWith(isScrolled: event.isScrolled));
  }

  Future<void> _fetchGamesEvent(
    FetchGamesEvent event,
    Emitter<ExploreState> emit,
  ) async {
    if (event.type == 'outer') {
      emit(state.copyWith(outerReqStateGames: RequestState.loading));
    } else {
      emit(state.copyWith(innerReqStateGames: RequestState.loading));
    }

    final result = await _fetchGamesUC(event.type);

    result.fold(
      (left) {
        if (event.type == 'outer') {
          emit(state.copyWith(
            outerReqStateGames: handleErrorResponse(left),
          ));
        } else {
          emit(state.copyWith(
            innerReqStateGames: handleErrorResponse(left),
          ));
        }
      },
      (right) {
        if (event.type == 'outer') {
          emit(
            state.copyWith(
              outerGames: right.data,
              outerReqStateGames: handleLoadedResponse<GamesEntity>(right.data),
            ),
          );
        } else {
          emit(
            state.copyWith(
              innerGames: right.data,
              innerReqStateGames: handleLoadedResponse<GamesEntity>(right.data),
            ),
          );
        }
      },
    );
  }

  //
  // Future<void> _fetchGamesEvent(FetchGamesEvent event,
  //     Emitter<ExploreState> emit,) async {
  //   if (event.isGamesLoading == true) {
  //     emit(state.copyWith(reqStateGames: RequestState.loading));
  //   }
  //   final result = await _fetchGamesUC();
  //
  //   result.fold(
  //         (left) {
  //       emit(state.copyWith(reqStateGames: handleErrorResponse(left)));
  //     },
  //         (right) {
  //       emit(
  //         state.copyWith(
  //           games: right.data,
  //           allGames: [
  //             ...(right.data?.fullGames ?? []),
  //             ...(right.data?.miniGames ?? []),
  //           ],
  //           reqStateGames: handleLoadedResponse<GamesEntity>(right.data),
  //         ),
  //       );
  //     },
  //   );
  // }

  Future<void> _fetchGamesRoomEvent(
    FetchGamesRoomEvent event,
    Emitter<ExploreState> emit,
  ) async {
    if (event.isGamesRoomLoading == true) {
      emit(state.copyWith(reqStateGamesRoom: RequestState.loading));
    }
    final result = await _fetchGamesRoomUC(event.gameId);
    result.fold(
      (left) {
        emit(state.copyWith(reqStateGamesRoom: handleErrorResponse(left)));
      },
      (right) => emit(
        state.copyWith(
          gamesRoom: right.data,
          reqStateGamesRoom: handleLoadedResponse<List<RoomEntity>>(
            right.data,
          ),
        ),
      ),
    );
  }

  Future<void> _fetchUsersEvent(
    FetchUsersEvent event,
    Emitter<ExploreState> emit,
  ) async {
    if (event.isUsersLoading == true) {
      emit(state.copyWith(reqStateUsers: RequestState.loading));
    }
    final result = await _fetchUsersUC(1);
    result.fold(
      (left) {
        emit(state.copyWith(reqStateUsers: handleErrorResponse(left)));
      },
      (right) {
        emit(
          state.copyWith(
            users: right.data,
            reqStateUsers:
                handleLoadedResponse<List<UserProfileEntity>>(right.data),
          ),
        );
      },
    );
  }

  Future<void> _fetchGamersEvent(
    FetchGamersEvent event,
    Emitter<ExploreState> emit,
  ) async {
    emit(state.copyWith(reqStateGamers: RequestState.loading));

    final result = await _fetchUsersGamersUC('');
    result.fold((left) {
      emit(state.copyWith(
          reqStateGamers: handleErrorResponse(left),
          gamersMessage: NetworkExceptions.getErrorMessage(left)));
    }, (right) {
      emit(
        state.copyWith(
          gamers: right.data,
          currentGamersPage: right.paginates?.currentPage,
          lastGamersPage: right.paginates?.lastPage,
          reqStateGamers: handleLoadedResponse<List<UserEntity>>(right.data),
        ),
      );
    });
  }

  Future<void> _stopGameEvent(
    StopGameEvent event,
    Emitter<ExploreState> emit,
  ) async {
    emit(state.copyWith(reqStateStopGame: RequestState.loading));

    final result = await _stopGamersUC();
    result.fold((left) {
      emit(state.copyWith(
          reqStateStopGame: handleErrorResponse(left),
          stopGameMessage: NetworkExceptions.getErrorMessage(left)));
    }, (right) {
      emit(
        state.copyWith(
          isStopGamers: right,
          reqStateStopGame: RequestState.loaded,
        ),
      );
    });
  }

  Future<void> _fetchMoreUsersEvent(
    FetchMoreGamersEvent event,
    Emitter<ExploreState> emit,
  ) async {
    if (state.currentGamersPage >= state.lastGamersPage) {
      return;
    }

    final nextPage = state.currentGamersPage + 1;

    final result = await _fetchUsersGamersUC(nextPage.toString());

    result.fold((left) {
      emit(state.copyWith(reqStateGamers: handleErrorResponse(left)));
    }, (right) {
      final newGamers = right.data ?? [];

      if (newGamers.isNotEmpty) {
        emit(
          state.copyWith(
            gamers: [...state.gamers, ...newGamers],
            currentGamersPage: nextPage,
          ),
        );
      } else {
        emit(
          state.copyWith(
            lastGamersPage: nextPage, // ✅ نقفل التحميل عند هذه الصفحة
          ),
        );
      }
    });
  }

  void _updateUsersEvent(
    UpdateUsersEvent event,
    Emitter<ExploreState> emit,
  ) =>
      emit(state.copyWith(users: event.users));
}
