import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/data/model/search_user_agency_model.dart';
import 'package:general/src/features/agency/domain/use_case/search_user_agency_uc.dart';

part 'search_user_agency_events.dart';

part 'search_user_agency_states.dart';

class SearchUserAgencyBloc
    extends Bloc<SearchUserAgencyEvents, SearchUserAgencyStates> {
  final SearchUserAgencyUc _searchUseCase;

  SearchUserAgencyBloc(
    this._searchUseCase,
  ) : super(SearchUserAgencyStates(searchController: TextEditingController())) {
    on<SearchUserEvent>(search);
    on<SearchAgencyEvent>(searchAgency);
    on<UserSelectedEvent>(userSelect);
  }

  FutureOr<void> search(
      SearchUserEvent event, Emitter<SearchUserAgencyStates> emit) async {
    emit(state.copyWith(
      usersRequestState: RequestState.loading,
    ));
    if (event.id.isEmpty) {
      emit(state.copyWith(users: null, usersRequestState: RequestState.empty));
    } else {
      final result = await _searchUseCase(
          SearchUserAgencyParam(id: event.id, type: 'user'));
      result.fold(
        (l) => emit(
          state.copyWith(
            usersErrorMsg: NetworkExceptions.getErrorMessage(l),
            usersRequestState: RequestState.error,
          ),
        ),
        (r) {
          emit(state.copyWith(
            users: null,
          ));
          emit(state.copyWith(
              users: r.data?.user ?? [],
              usersRequestState: handleLoadedResponse(r.data?.user ?? [])));
        },
      );
    }
  }

  FutureOr<void> searchAgency(
      SearchAgencyEvent event, Emitter<SearchUserAgencyStates> emit) async {
    emit(state.copyWith(agenciesRequestState: RequestState.loading));
    if (event.id.isEmpty) {
      emit(state.copyWith(
          agencies: null, agenciesRequestState: RequestState.empty));
    } else {
      final result = await _searchUseCase(
          SearchUserAgencyParam(id: event.id, type: 'agency'));
      result.fold(
        (l) => emit(
          state.copyWith(
            agenciesErrorMsg: NetworkExceptions.getErrorMessage(l),
            agenciesRequestState: RequestState.error,
          ),
        ),
        (r) {
          emit(state.copyWith(
            agencies: null,
          ));
          emit(state.copyWith(
              agencies: r.data?.agency ?? [],
              agenciesRequestState:
                  handleLoadedResponse(r.data?.agency ?? [])));
        },
      );
    }
  }

  FutureOr<void> userSelect(
      UserSelectedEvent event, Emitter<SearchUserAgencyStates> emit) {
    emit(state.copyWith(param: event.param, amount: event.amount));
  }

  void clear() {
    state.searchController.clear();
    state.param = null;
    state.searchController.text = '';
  }
}
