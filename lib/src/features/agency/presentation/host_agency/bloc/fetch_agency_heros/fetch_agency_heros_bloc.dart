import 'package:general/src/core/index.dart';

import '../../../../domain/entity/agency_more_info_entity.dart';
import '../../../../domain/use_case/fetch_more_info_agency.dart';

part 'fetch_agency_heros_event.dart';

part 'fetch_agency_heros_state.dart';

class FetchAgencyHerosBloc
    extends Bloc<FetchAgencyHerosEvent, FetchAgencyHerosState> {
  FetchAgencyHerosUC useCase;

  FetchAgencyHerosBloc(this.useCase) : super(const FetchAgencyHerosState()) {
    on<FetchHerosForMonthEvent>((event, emit) async {
      emit(state.copyWith(
        requestState: RequestState.loading,
      ));
      final result = await useCase(AgencyHistoryParam(
          month: event.month,
          year: event.year,
          agencyId: event.agencyId,
          page: event.page));
      result.fold((l) {
        emit(state.copyWith(
            requestState: RequestState.error,
            message: NetworkExceptions.getErrorMessage(l)));
      }, (r) {
        emit(state.copyWith(
            requestState: handleLoadedResponse(r.data), heros: r.data));
      });
    });
  }
}
