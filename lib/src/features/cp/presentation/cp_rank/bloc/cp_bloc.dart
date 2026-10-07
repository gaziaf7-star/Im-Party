import 'dart:async';

import 'package:general/src/features/cp/domain/cp_use_case/fetch_ranking_cp_uc.dart';
import 'package:general/src/features/cp/domain/entities/cp_entity.dart';

import '../../../../../core/index.dart';


part 'cp_events.dart';
part 'cp_states.dart';

class CpBloc extends Bloc<CpEvents, CpStates> {
  final FetchRankingCpUC _fetchRankingCpUC;

  CpBloc(this._fetchRankingCpUC) : super(const CpStates()) {
    on<FetchFriendsCpDayEvent>(_fetchFriendsCpDayEvent);
    on<FetchFriendsCpWeeklyEvent>(_fetchFriendsCpWeeklyEvent);
    on<FetchFriendsCpMonthlyEvent>(_fetchFriendsCpMonthlyEvent);

    on<FetchBroCpDayEvent>(_fetchBroCpDayEvent);
    on<FetchBroCpWeeklyEvent>(_fetchBroCpWeeklyEvent);
    on<FetchBroCpMonthlyEvent>(_fetchBroCpMonthlyEvent);

    on<FetchLoveCpDayEvent>(_fetchLoveCpDayEvent);
    on<FetchLoveCpWeeklyEvent>(_fetchLoveCpWeeklyEvent);
    on<FetchLoveCpMonthlyEvent>(_fetchLoveCpMonthlyEvent);
  }

  Future<void> _fetchFriendsCpDayEvent(
      FetchFriendsCpDayEvent event,
    Emitter<CpStates> emit,
  ) async {
    emit(state.copyWith(cpFriendsDState: RequestState.loading));
    final result = await _fetchRankingCpUC(
      const TopParameter(sendOrReceiver: '1', isHome: '0', date: '1'),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          cpFriendsDError: failure,
          cpFriendsDState: handleErrorResponse(failure),
        ),
      ),
      (success) => emit(
        state.copyWith(
          usersRankFriendsCpD: success.data,
          cpFriendsDState: handleLoadedResponse(success.data),
        ),
      ),
    );
  }


  Future<void> _fetchFriendsCpWeeklyEvent(
      FetchFriendsCpWeeklyEvent event,
      Emitter<CpStates> emit,
      ) async {
    emit(state.copyWith(cpFriendsWState: RequestState.loading));
    final result = await _fetchRankingCpUC(
      const TopParameter(sendOrReceiver: '1', isHome: '0', date: '2'),
    );
    result.fold(
          (failure) => emit(
        state.copyWith(
          cpFriendsWError: failure,
          cpFriendsWState: handleErrorResponse(failure),
        ),
      ),
          (success) => emit(
        state.copyWith(
          usersRankFriendsCpW: success.data,
          cpFriendsWState: handleLoadedResponse(success.data),
        ),
      ),
    );
  }

  Future<void> _fetchFriendsCpMonthlyEvent(
      FetchFriendsCpMonthlyEvent event,
      Emitter<CpStates> emit,
      ) async {
    emit(state.copyWith(cpFriendsMState: RequestState.loading));
    final result = await _fetchRankingCpUC(
      const TopParameter(sendOrReceiver: '1', isHome: '0', date: '3'),
    );
    result.fold(
          (failure) => emit(
        state.copyWith(
          cpFriendsMError: failure,
          cpFriendsMState: handleErrorResponse(failure),
        ),
      ),
          (success) => emit(
        state.copyWith(
          usersRankFriendsCpM: success.data,
          cpFriendsMState: handleLoadedResponse(success.data),
        ),
      ),
    );
  }

  Future<void> _fetchBroCpDayEvent(
      FetchBroCpDayEvent event,
      Emitter<CpStates> emit,
      ) async {
    emit(state.copyWith(cpBroDState: RequestState.loading));
    final result = await _fetchRankingCpUC(
      const TopParameter(sendOrReceiver: '2', isHome: '0', date: '1'),
    );
    result.fold(
          (failure) => emit(
        state.copyWith(
          cpBroDError: failure,
          cpBroDState: handleErrorResponse(failure),
        ),
      ),
          (success) => emit(
        state.copyWith(
          usersRankBroCpD: success.data,
          cpBroDState: handleLoadedResponse(success.data),
        ),
      ),
    );
  }

  Future<void> _fetchBroCpWeeklyEvent(
      FetchBroCpWeeklyEvent event,
      Emitter<CpStates> emit,
      ) async {
    emit(state.copyWith(cpBroWState: RequestState.loading));
    final result = await _fetchRankingCpUC(
      const TopParameter(sendOrReceiver: '2', isHome: '0', date: '2'),
    );
    result.fold(
          (failure) => emit(
        state.copyWith(
          cpBroWError: failure,
          cpBroWState: handleErrorResponse(failure),
        ),
      ),
          (success) => emit(
        state.copyWith(
          usersRankBroCpW: success.data,
          cpBroWState: handleLoadedResponse(success.data),
        ),
      ),
    );
  }

  Future<void> _fetchBroCpMonthlyEvent(
      FetchBroCpMonthlyEvent event,
      Emitter<CpStates> emit,
      ) async {
    emit(state.copyWith(cpBroMState: RequestState.loading));
    final result = await _fetchRankingCpUC(
      const TopParameter(sendOrReceiver: '2', isHome: '0', date: '3'),
    );
    result.fold(
          (failure) => emit(
        state.copyWith(
          cpBroMError: failure,
          cpBroMState: handleErrorResponse(failure),
        ),
      ),
          (success) => emit(
        state.copyWith(
          usersRankBroCpM: success.data,
          cpBroMState: handleLoadedResponse(success.data),
        ),
      ),
    );
  }

  Future<void> _fetchLoveCpDayEvent(
      FetchLoveCpDayEvent event,
      Emitter<CpStates> emit,
      ) async {
    emit(state.copyWith(cpLoveDState: RequestState.loading));
    final result = await _fetchRankingCpUC(
      const TopParameter(sendOrReceiver: 'lovely', isHome: '0', date: '1'),
    );
    result.fold(
          (failure) => emit(
        state.copyWith(
          cpLoveDError: failure,
          cpLoveDState: handleErrorResponse(failure),
        ),
      ),
          (success) => emit(
        state.copyWith(
          usersRankLoveCpD: success.data,
          cpLoveDState: handleLoadedResponse(success.data),
        ),
      ),
    );
  }

  Future<void> _fetchLoveCpWeeklyEvent(
      FetchLoveCpWeeklyEvent event,
      Emitter<CpStates> emit,
      ) async {
    emit(state.copyWith(cpLoveWState: RequestState.loading));
    final result = await _fetchRankingCpUC(
      const TopParameter(sendOrReceiver: 'lovely', isHome: '0', date: '2'),
    );
    result.fold(
          (failure) => emit(
        state.copyWith(
          cpLoveWError: failure,
          cpLoveWState: handleErrorResponse(failure),
        ),
      ),
          (success) => emit(
        state.copyWith(
          usersRankLoveCpW: success.data,
          cpLoveWState: handleLoadedResponse(success.data),
        ),
      ),
    );
  }

  Future<void> _fetchLoveCpMonthlyEvent(
      FetchLoveCpMonthlyEvent event,
      Emitter<CpStates> emit,
      ) async {
    emit(state.copyWith(cpLoveMState: RequestState.loading));
    final result = await _fetchRankingCpUC(
      const TopParameter(sendOrReceiver: 'lovely', isHome: '0', date: '3'),
    );
    result.fold(
          (failure) => emit(
        state.copyWith(
          cpLoveMError: failure,
          cpLoveMState: handleErrorResponse(failure),
        ),
      ),
          (success) => emit(
        state.copyWith(
          usersRankLoveCpM: success.data,
          cpLoveMState: handleLoadedResponse(success.data),
        ),
      ),
    );
  }
}
