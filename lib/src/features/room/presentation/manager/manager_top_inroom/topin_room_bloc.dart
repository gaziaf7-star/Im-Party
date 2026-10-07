import 'dart:async';
import 'package:general/src/features/games/games.dart';
import 'package:general/src/features/room/presentation/manager/manager_top_inroom/topin_room_states.dart';
import 'package:general/src/features/room/room.dart';

class RankingRoomBloc extends Bloc<TopInRoonEvents, RankingRoomState> {
  final GetTopRoomUC _fetchTopRoomUC;

  RankingRoomBloc(this._fetchTopRoomUC)
      : super(RankingRoomState(
    backgroundImage: AssetsManager.rich,
  )) {
    on<GetDiamondsTopDayEvent>(_fetchDiamondsDayEvent);
    on<GetDiamondsTopWeeklyEvent>(_fetchDiamondsWeeklyEvent);
    on<GetDiamondsTopMonthlyEvent>(_fetchDiamondsMonthlyEvent);
    on<GetCoinsTopDayEvent>(_fetchCoinsDayEvent);
    on<GetCoinsTopWeeklyEvent>(fetchCoinsWeeklyEvent);
    on<GetCoinsTopMonthlyEvent>(_fetchCoinsMonthlyEvent);
    on<ChangeColorEvent>(_changeColorEvent);
  }

  Future<void> _fetchDiamondsDayEvent(
      GetDiamondsTopDayEvent event, Emitter<RankingRoomState> emit) async {
    final result = await _fetchTopRoomUC(
        TopParameterInRoom(date: '1', innerType: '1', roomId: event.roomId));

    result.fold(
          (left) => emit(
        state.copyWith(
          dayDiamondError: NetworkExceptions.getErrorMessage(left),
          dayDiamondState: handleErrorResponse(left),
        ),
      ),
          (right) => emit(
        state.copyWith(
          dayDiamondUsersRank: right.data,
          dayDiamondState: handleLoadedResponse(right),
        ),
      ),
    );
  }

  Future<void> _fetchDiamondsWeeklyEvent(
      GetDiamondsTopWeeklyEvent event, Emitter<RankingRoomState> emit) async {
    final result = await _fetchTopRoomUC(
        TopParameterInRoom(date: '1', innerType: '2', roomId: event.roomId));

    result.fold(
          (left) => emit(
        state.copyWith(
          weekDiamondError: NetworkExceptions.getErrorMessage(left),
          weekDiamondState: handleErrorResponse(left),
        ),
      ),
          (right) => emit(
        state.copyWith(
          weekDiamondUsersRank: right.data,
          weekDiamondState: handleLoadedResponse(right),
        ),
      ),
    );
  }

  Future<void> _fetchDiamondsMonthlyEvent(
      GetDiamondsTopMonthlyEvent event, Emitter<RankingRoomState> emit) async {
    final result = await _fetchTopRoomUC(
        TopParameterInRoom(date: '1', innerType: '3', roomId: event.roomId));

    result.fold(
          (left) => emit(
        state.copyWith(
          monthDiamondError: NetworkExceptions.getErrorMessage(left),
          monthDiamondState: handleErrorResponse(left),
        ),
      ),
          (right) => emit(
        state.copyWith(
          monthDiamondUsersRank: right.data,
          monthDiamondState: handleLoadedResponse(right),
        ),
      ),
    );
  }

  Future<void> _fetchCoinsDayEvent(
      GetCoinsTopDayEvent event, Emitter<RankingRoomState> emit,) async {

    final result = await _fetchTopRoomUC(
      TopParameterInRoom(
        date: '2',
        innerType: '1',
        roomId: event.roomId,
      ),
    );

    result.fold(
          (left) => emit(
        state.copyWith(
          dayCoinError: NetworkExceptions.getErrorMessage(left),
          dayCoinState: handleErrorResponse(left),
        ),
      ),
          (right) => emit(
        state.copyWith(
          dayCoinUsersRank: right.data,
          dayCoinState: handleLoadedResponse(right),
        ),
      ),
    );
  }

  Future<void> fetchCoinsWeeklyEvent(
      GetCoinsTopWeeklyEvent event, Emitter<RankingRoomState> emit) async {
    final result = await _fetchTopRoomUC(
        TopParameterInRoom(date: '2', innerType: '2', roomId: event.roomId));

    result.fold(
          (left) => emit(
        state.copyWith(
          weekCoinError: NetworkExceptions.getErrorMessage(left),
          weekCoinState: handleErrorResponse(left),
        ),
      ),
          (right) => emit(
        state.copyWith(
          weekCoinUsersRank: right.data,
          weekCoinState: handleLoadedResponse(right),
        ),
      ),
    );
  }

  Future<void> _fetchCoinsMonthlyEvent(
      GetCoinsTopMonthlyEvent event, Emitter<RankingRoomState> emit) async {
    final result = await _fetchTopRoomUC(
        TopParameterInRoom(date: '2', innerType: '3', roomId: event.roomId));

    result.fold(
          (left) => emit(
        state.copyWith(
          monthCoinError: NetworkExceptions.getErrorMessage(left),
          monthCoinState: handleErrorResponse(left),
        ),
      ),
          (right) => emit(
        state.copyWith(
          monthCoinUsersRank: right.data,
          monthCoinState: handleLoadedResponse(right),
        ),
      ),
    );
  }

  Future<void> _changeColorEvent(
      ChangeColorEvent event, Emitter<RankingRoomState> emit) async {
    emit(state.copyWith(colorBackground: event.color));
  }
}
