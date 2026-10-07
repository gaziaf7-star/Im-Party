import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/domain/entity/agency_more_info_entity.dart';
import 'package:general/src/features/agency/domain/use_case/fetch_more_info_agency.dart';

part 'fetch_agency_admins_event.dart';
part 'fetch_agency_admins_state.dart';

class FetchAgencyAdminsBloc
    extends Bloc<FetchAgencyAdminsEvent, FetchAgencyAdminsState> {
  final FetchAgencyAdminsUC useCase;

  FetchAgencyAdminsBloc(this.useCase) : super(const FetchAgencyAdminsState()) {
    on<FetchAdminsForMonthEvent>((event, emit) async {
      // Backend rejects /agencies/admins/0 with 400 (the network error then
      // surfaces as a noisy non-fatal crash). Skip the request for invalid ids.
      if ((int.tryParse(event.agencyId) ?? 0) <= 0) {
        emit(state.copyWith(
          admins: const <UserStarEntity>[],
          requestState: RequestState.empty,
        ));
        return;
      }
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
            : [...(state.admins ?? <UserStarEntity>[]), ...newItems];
        emit(state.copyWith(
            requestState: handleLoadedResponse(merged), admins: merged));
      });
    });
  }
}
