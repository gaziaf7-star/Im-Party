import 'dart:async';

import 'package:general/src/features/games/domain/entities/agency_ranking_entity.dart';
import 'package:general/src/features/games/games.dart';

part 'ranking_events.dart';
part 'ranking_states.dart';

class RankingBloc extends Bloc<RankingEvents, RankingStates> {
  final FetchRankingUC _fetchRankingUC;
  // final FetchRankingCpUC _fetchRankingCpUC;
  final FetchAgencyRankingUC _fetchAgencyRankingUC;

  RankingBloc(
    this._fetchRankingUC,
    this._fetchAgencyRankingUC,
  ) : super(const RankingStates()) {
    on<FetchDiamondsHourEvent>(_fetchDiamondsHourEvent);
    on<FetchDiamondsDayEvent>(_fetchDiamondsDayEvent);
    on<FetchDiamondsWeeklyEvent>(_fetchDiamondsWeeklyEvent);
    on<FetchDiamondsMonthlyEvent>(_fetchDiamondsMonthlyEvent);

    on<FetchCoinsHourEvent>(_fetchCoinsHourEvent);
    on<FetchCoinsDayEvent>(_fetchCoinsDayEvent);
    on<FetchCoinsWeeklyEvent>(_fetchCoinsWeeklyEvent);
    on<FetchCoinsMonthlyEvent>(_fetchCoinsMonthlyEvent);

    on<FetchRoomHourEvent>(_fetchRoomHourEvent);
    on<FetchRoomsDayEvent>(_fetchRoomsDayEvent);
    on<FetchRoomWeeklyEvent>(_fetchRoomWeeklyEvent);
    on<FetchRoomMonthlyEvent>(_fetchRoomMonthlyEvent);

    on<FetchGamersHourEvent>(_fetchGamersHourEvent);
    on<FetchGamersDayEvent>(_fetchGamersDayEvent);
    on<FetchGamersWeeklyEvent>(_fetchGamersWeeklyEvent);
    on<FetchGamersMonthlyEvent>(_fetchGamersMonthlyEvent);

    on<FetchAgencyHourEvent>(_fetchAgencyHourEvent);
    on<FetchAgencyDayEvent>(_fetchAgencyDayEvent);
    on<FetchAgencyWeeklyEvent>(_fetchAgencyWeeklyEvent);
    on<FetchAgencyMonthlyEvent>(_fetchAgencyMonthlyEvent);

    on<FetchLuckyHourEvent>(_fetchLuckyHourEvent);
    on<FetchLuckyDayEvent>(_fetchLuckyDayEvent);
    on<FetchLuckyWeeklyEvent>(_fetchLuckyWeeklyEvent);
    on<FetchLuckyMonthlyEvent>(_fetchLuckyMonthlyEvent);

    on<HandleInfoCurrentRankEvent>(_handleInfoCurrentRankEvent);
  }

  Future<void> _fetchDiamondsHourEvent(
    FetchDiamondsHourEvent event,
    Emitter<RankingStates> emit,
  ) async {
    emit(state.copyWith(dhState: RequestState.loading));
    final result = await _fetchRankingUC(
      const TopParameter(sendOrReceiver: '1', isHome: '0', date: '0'),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          dhError: failure,
          dhState: handleErrorResponse(failure),
        ),
      ),
      (success) => emit(
        state.copyWith(
          usersRankDh: success.data,
          dhState: handleLoadedResponse(success.data),
        ),
      ),
    );
  }

  Future<void> _fetchDiamondsDayEvent(
    FetchDiamondsDayEvent event,
    Emitter<RankingStates> emit,
  ) async {
    final result = await _fetchRankingUC(
      const TopParameter(sendOrReceiver: '1', isHome: '0', date: '1'),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          dDError: failure,
          dDState: handleErrorResponse(failure),
        ),
      ),
      (success) => emit(
        state.copyWith(
          usersRankDD: success.data,
          dDState: handleLoadedResponse(success.data),
        ),
      ),
    );
  }

  Future<void> _fetchDiamondsWeeklyEvent(
    FetchDiamondsWeeklyEvent event,
    Emitter<RankingStates> emit,
  ) async {
    //emit(state.copyWith(dWState: RequestState.loading));
    final result = await _fetchRankingUC(
      const TopParameter(sendOrReceiver: '1', isHome: '0', date: '2'),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          dWError: failure,
          dWState: handleErrorResponse(failure),
        ),
      ),
      (success) => emit(
        state.copyWith(
          usersRankDW: success.data,
          dWState: handleLoadedResponse(success.data),
        ),
      ),
    );
  }

  Future<void> _fetchDiamondsMonthlyEvent(
    FetchDiamondsMonthlyEvent event,
    Emitter<RankingStates> emit,
  ) async {
    //emit(state.copyWith(dMState: RequestState.loading));
    final result = await _fetchRankingUC(
      const TopParameter(sendOrReceiver: '1', isHome: '0', date: '3'),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          dMError: failure,
          dMState: handleErrorResponse(failure),
        ),
      ),
      (success) => emit(
        state.copyWith(
          usersRankDM: success.data,
          dMState: handleLoadedResponse(success.data),
        ),
      ),
    );
  }

  Future<void> _fetchCoinsHourEvent(
    FetchCoinsHourEvent event,
    Emitter<RankingStates> emit,
  ) async {
//emit(state.copyWith(chState: RequestState.loading));
    final result = await _fetchRankingUC(
      const TopParameter(sendOrReceiver: '2', isHome: '0', date: '0'),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          chError: failure,
          chState: handleErrorResponse(failure),
        ),
      ),
      (success) => emit(
        state.copyWith(
          usersRankCh: success.data,
          chState: handleLoadedResponse(success.data),
        ),
      ),
    );
  }

  Future<void> _fetchCoinsDayEvent(
    FetchCoinsDayEvent event,
    Emitter<RankingStates> emit,
  ) async {
    //emit(state.copyWith(cDState: RequestState.loading));
    final result = await _fetchRankingUC(
      const TopParameter(sendOrReceiver: '2', isHome: '0', date: '1'),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          cDError: failure,
          cDState: handleErrorResponse(failure),
        ),
      ),
      (success) => emit(
        state.copyWith(
            usersRankCD: success.data,
            cDState: handleLoadedResponse(success.data)),
      ),
    );
  }

  Future<void> _fetchCoinsWeeklyEvent(
    FetchCoinsWeeklyEvent event,
    Emitter<RankingStates> emit,
  ) async {
    //emit(state.copyWith(cWState: RequestState.loading));
    final result = await _fetchRankingUC(
        const TopParameter(sendOrReceiver: '2', isHome: '0', date: '2'));

    result.fold(
      (failure) => emit(
        state.copyWith(
          cWError: failure,
          cWState: handleErrorResponse(failure),
        ),
      ),
      (success) => emit(
        state.copyWith(
          usersRankCW: success.data,
          cWState: handleLoadedResponse(success.data),
        ),
      ),
    );
  }

  Future<void> _fetchCoinsMonthlyEvent(
    FetchCoinsMonthlyEvent event,
    Emitter<RankingStates> emit,
  ) async {
    //emit(state.copyWith(cMState: RequestState.loading));
    final result = await _fetchRankingUC(
        const TopParameter(sendOrReceiver: '2', isHome: '0', date: '3'));

    result.fold(
      (failure) => emit(
        state.copyWith(
          cMError: failure,
          cMState: handleErrorResponse(failure),
        ),
      ),
      (success) => emit(
        state.copyWith(
          usersRankCM: success.data,
          cMState: handleLoadedResponse(success.data),
        ),
      ),
    );
  }

  Future<void> _fetchRoomHourEvent(
    FetchRoomHourEvent event,
    Emitter<RankingStates> emit,
  ) async {
    final result = await _fetchRankingUC(
        const TopParameter(sendOrReceiver: '3', isHome: '0', date: '0'));

    result.fold(
      (failure) => emit(
        state.copyWith(
          rhError: failure,
          rhState: handleErrorResponse(failure),
        ),
      ),
      (success) => emit(
        state.copyWith(
          usersRankRh: success.data,
          rhState: handleLoadedResponse(success.data),
        ),
      ),
    );
  }

  Future<void> _fetchRoomsDayEvent(
    FetchRoomsDayEvent event,
    Emitter<RankingStates> emit,
  ) async {
    //emit(state.copyWith(rDState: RequestState.loading));
    final result = await _fetchRankingUC(
        const TopParameter(sendOrReceiver: '3', isHome: '0', date: '1'));

    result.fold(
      (failure) => emit(
        state.copyWith(
          rDError: failure,
          rDState: handleErrorResponse(failure),
        ),
      ),
      (success) => emit(
        state.copyWith(
          usersRankRD: success.data,
          rDState: handleLoadedResponse(success.data),
        ),
      ),
    );
  }

  Future<void> _fetchRoomWeeklyEvent(
    FetchRoomWeeklyEvent event,
    Emitter<RankingStates> emit,
  ) async {
    //emit(state.copyWith(rWState: RequestState.loading));
    final result = await _fetchRankingUC(
        const TopParameter(sendOrReceiver: '3', isHome: '0', date: '2'));

    result.fold(
      (failure) => emit(
        state.copyWith(
          rWError: failure,
          rWState: handleErrorResponse(failure),
        ),
      ),
      (success) => emit(
        state.copyWith(
          usersRankRW: success.data,
          rWState: handleLoadedResponse(success.data),
        ),
      ),
    );
  }

  Future<void> _fetchRoomMonthlyEvent(
    FetchRoomMonthlyEvent event,
    Emitter<RankingStates> emit,
  ) async {
    //emit(state.copyWith(rMState: RequestState.loading));
    final result = await _fetchRankingUC(
        const TopParameter(sendOrReceiver: '3', isHome: '0', date: '3'));

    result.fold(
      (failure) => emit(
        state.copyWith(
          rMError: failure,
          rMState: handleErrorResponse(failure),
        ),
      ),
      (success) {
        emit(
          state.copyWith(
            usersRankRM: success.data,
            rMState: handleLoadedResponse(success.data),
          ),
        );
      },
    );
  }

  Future<void> _fetchGamersHourEvent(
    FetchGamersHourEvent event,
    Emitter<RankingStates> emit,
  ) async {
    final result = await _fetchRankingUC(
        const TopParameter(sendOrReceiver: '6', isHome: '0', date: '0'));

    result.fold(
      (failure) => emit(
        state.copyWith(
          ghError: failure,
          ghState: handleErrorResponse(failure),
        ),
      ),
      (success) => emit(
        state.copyWith(
          usersRankGh: success.data,
          ghState: handleLoadedResponse(success.data),
        ),
      ),
    );
  }

  Future<void> _fetchGamersDayEvent(
    FetchGamersDayEvent event,
    Emitter<RankingStates> emit,
  ) async {
    //emit(state.copyWith(rDState: RequestState.loading));
    final result = await _fetchRankingUC(
        const TopParameter(sendOrReceiver: '6', isHome: '0', date: '1'));

    result.fold(
      (failure) => emit(
        state.copyWith(
          gDError: failure,
          gDState: handleErrorResponse(failure),
        ),
      ),
      (success) => emit(
        state.copyWith(
          usersRankGD: success.data,
          gDState: handleLoadedResponse(success.data),
        ),
      ),
    );
  }

  Future<void> _fetchGamersWeeklyEvent(
    FetchGamersWeeklyEvent event,
    Emitter<RankingStates> emit,
  ) async {
    //emit(state.copyWith(rWState: RequestState.loading));
    final result = await _fetchRankingUC(
        const TopParameter(sendOrReceiver: '6', isHome: '0', date: '2'));

    result.fold(
      (failure) => emit(
        state.copyWith(
          gWError: failure,
          gWState: handleErrorResponse(failure),
        ),
      ),
      (success) => emit(
        state.copyWith(
          usersRankGW: success.data,
          gWState: handleLoadedResponse(success.data),
        ),
      ),
    );
  }

  Future<void> _fetchGamersMonthlyEvent(
    FetchGamersMonthlyEvent event,
    Emitter<RankingStates> emit,
  ) async {
    //emit(state.copyWith(rMState: RequestState.loading));
    final result = await _fetchRankingUC(
        const TopParameter(sendOrReceiver: '6', isHome: '0', date: '3'));

    result.fold(
      (failure) => emit(
        state.copyWith(
          gMError: failure,
          gMState: handleErrorResponse(failure),
        ),
      ),
      (success) {
        emit(
          state.copyWith(
            usersRankGM: success.data,
            gMState: handleLoadedResponse(success.data),
          ),
        );
      },
    );
  }

  Future<void> _fetchAgencyHourEvent(
    FetchAgencyHourEvent event,
    Emitter<RankingStates> emit,
  ) async {
    final result = await _fetchAgencyRankingUC(
        const TopParameter(sendOrReceiver: '5', isHome: '0', date: '0'));

    result.fold(
      (failure) => emit(
        state.copyWith(
          agencyHError: failure,
          agencyHState: handleErrorResponse(failure),
        ),
      ),
      (success) {
        emit(
          state.copyWith(
            usersRankAgencyH: success.data,
            agencyHState: handleLoadedResponse(success.data),
          ),
        );
      },
    );
  }

  Future<void> _fetchAgencyDayEvent(
    FetchAgencyDayEvent event,
    Emitter<RankingStates> emit,
  ) async {
    //emit(state.copyWith(agencyDState: RequestState.loading));
    final result = await _fetchAgencyRankingUC(
        const TopParameter(sendOrReceiver: '5', isHome: '0', date: '1'));

    result.fold(
      (failure) => emit(
        state.copyWith(
          agencyDError: failure,
          agencyDState: handleErrorResponse(failure),
        ),
      ),
      (success) {
        emit(
          state.copyWith(
            usersRankAgencyD: success.data,
            agencyDState: handleLoadedResponse(success.data),
          ),
        );
      },
    );
  }

  Future<void> _fetchAgencyWeeklyEvent(
    FetchAgencyWeeklyEvent event,
    Emitter<RankingStates> emit,
  ) async {
    //emit(state.copyWith(agencyWState: RequestState.loading));
    final result = await _fetchAgencyRankingUC(
        const TopParameter(sendOrReceiver: '5', isHome: '0', date: '2'));

    result.fold(
      (failure) => emit(
        state.copyWith(
          agencyWError: failure,
          agencyWState: handleErrorResponse(failure),
        ),
      ),
      (success) {
        emit(
          state.copyWith(
            usersRankAgencyW: success.data,
            agencyWState: handleLoadedResponse(success.data),
          ),
        );
      },
    );
  }

  Future<void> _fetchAgencyMonthlyEvent(
    FetchAgencyMonthlyEvent event,
    Emitter<RankingStates> emit,
  ) async {
    final result = await _fetchAgencyRankingUC(const TopParameter(
      sendOrReceiver: '5',
      isHome: '0',
      date: '3',
    ));

    result.fold(
      (failure) => emit(
        state.copyWith(
          agencyMError: failure,
          agencyMState: handleErrorResponse(failure),
        ),
      ),
      (success) {
        emit(
          state.copyWith(
            usersRankAgencyM: success.data,
            agencyMState: handleLoadedResponse(success.data),
          ),
        );
      },
    );
  }

  Future<void> _fetchLuckyHourEvent(
    FetchLuckyHourEvent event,
    Emitter<RankingStates> emit,
  ) async {
    final result = await _fetchRankingUC(
        const TopParameter(sendOrReceiver: '4', isHome: '0', date: '0'));

    result.fold(
      (failure) => emit(
        state.copyWith(
          lhError: failure,
          lhState: handleErrorResponse(failure),
        ),
      ),
      (success) => emit(
        state.copyWith(
          usersRankLh: success.data,
          lhState: handleLoadedResponse(success.data),
        ),
      ),
    );
  }

  Future<void> _fetchLuckyDayEvent(
    FetchLuckyDayEvent event,
    Emitter<RankingStates> emit,
  ) async {
    final result = await _fetchRankingUC(
        const TopParameter(sendOrReceiver: '4', isHome: '0', date: '1'));

    result.fold(
      (failure) => emit(
        state.copyWith(
          lDError: failure,
          lDState: handleErrorResponse(failure),
        ),
      ),
      (success) => emit(
        state.copyWith(
          usersRankLD: success.data,
          lDState: handleLoadedResponse(success.data),
        ),
      ),
    );
  }

  Future<void> _fetchLuckyWeeklyEvent(
    FetchLuckyWeeklyEvent event,
    Emitter<RankingStates> emit,
  ) async {
    final result = await _fetchRankingUC(
        const TopParameter(sendOrReceiver: '4', isHome: '0', date: '2'));

    result.fold(
      (failure) => emit(
        state.copyWith(
          lWError: failure,
          lWState: handleErrorResponse(failure),
        ),
      ),
      (success) => emit(
        state.copyWith(
          usersRankLW: success.data,
          lWState: handleLoadedResponse(success.data),
        ),
      ),
    );
  }

  Future<void> _fetchLuckyMonthlyEvent(
    FetchLuckyMonthlyEvent event,
    Emitter<RankingStates> emit,
  ) async {
    final result = await _fetchRankingUC(
        const TopParameter(sendOrReceiver: '4', isHome: '0', date: '3'));

    result.fold(
      (failure) => emit(
        state.copyWith(
          lMError: failure,
          lMState: handleErrorResponse(failure),
        ),
      ),
      (success) => emit(
        state.copyWith(
          usersRankLM: success.data,
          lMState: handleLoadedResponse(success.data),
        ),
      ),
    );
  }

  void _handleInfoCurrentRankEvent(
    HandleInfoCurrentRankEvent event,
    Emitter<RankingStates> emit,
  ) {
    if (state.index == event.currentIndex) return;
    switch (event.currentIndex) {
      case 0:
        emit(
          state.copyWith(
            index: 0,
            imageRank: AssetsManager.backgroundCharmRAnk,
            imageBackground: AssetsManager.roomRankingBackground,
            backgroundColor: const Color(0xff656565),
          ),
        );
        break;
      case 1:
        emit(
          state.copyWith(
            index: 1,
            imageRank: AssetsManager.reciverRankImage,
            imageBackground: AssetsManager.wealthRankingBackground,
            backgroundColor: const Color(0xff7C7045),
          ),
        );
        break;
      case 2:
        emit(
          state.copyWith(
            index: 2,
            imageRank: AssetsManager.roomImageRank,
            imageBackground: AssetsManager.charmRankingBackground,
            backgroundColor: const Color(0xff4C6E9C),
          ),
        );
        break;
      case 3:
        emit(
          state.copyWith(
            index: 3,
            imageRank: AssetsManager.roomImageRank,
            imageBackground: AssetsManager.gameRankingBackground,
            backgroundColor: const Color(0xff390915),
          ),
        );
      case 4:
        emit(
          state.copyWith(
            index: 4,
            imageRank: AssetsManager.roomImageRank,
            imageBackground: AssetsManager.agencyRankingBackground,
            backgroundColor: const Color(0xff304967),
          ),
        );
      case 5:
        emit(
          state.copyWith(
            index: 5,
            imageRank: AssetsManager.roomImageRank,
            imageBackground: AssetsManager.gameRankingBackground,
            backgroundColor: const Color(0xff390915),
          ),
        );
        break;
    }
  }
}
