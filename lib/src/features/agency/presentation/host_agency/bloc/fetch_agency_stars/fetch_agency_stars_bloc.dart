import 'package:general/src/features/agency/domain/use_case/fetch_more_info_agency.dart';

import '../../../../../../core/index.dart';
import '../../../../domain/entity/agency_more_info_entity.dart';

part 'fetch_agency_stars_event.dart';

part 'fetch_agency_stars_state.dart';

class FetchAgencyStarsBloc
    extends Bloc<FetchAgencyStarsEvent, FetchAgencyStarsState> {
  FetchAgencyStarsUC useCase;

  FetchAgencyStarsBloc(this.useCase) : super(const FetchAgencyStarsState()) {
    on<FetchStarsForMonthEvent>((event, emit) async {
      final isFirstPage = event.page == null || event.page == '1';
      if (isFirstPage) {
        emit(state.copyWith(requestState: RequestState.loading));
      }
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
        final newItems = r.data ?? <UserStarEntity>[];
        final merged = isFirstPage
            ? newItems
            : [...(state.stars ?? <UserStarEntity>[]), ...newItems];
        emit(state.copyWith(
            requestState: handleLoadedResponse(merged), stars: merged));
      });
    });
  }
}
