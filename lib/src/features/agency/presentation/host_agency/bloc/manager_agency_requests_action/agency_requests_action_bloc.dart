import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/fetch_more_info_agency/fetch_more_info_agency_bloc.dart';

part 'agency_requests_action_event.dart';

part 'agency_requests_action_state.dart';

class AgencyRequestsActionBloc
    extends Bloc<AgencyRequestsActionEvent, AgencyRequestsActionState> {
  final AgencyRequestsActionUC agencyRequestsActionUC;

  AgencyRequestsActionBloc({required this.agencyRequestsActionUC})
      : super(const AgencyRequestsActionState()) {
    on<AgencyRequestsActionEvent>(
      (event, emit) async {
        // Set state to loading
        emit(state.copyWith(state: RequestState.loading));

        // Execute the use case
        final result = await agencyRequestsActionUC(
          AgencyRequestsActionParam(
            id: event.userId,
            action: event.accept,
          ),
        );

        // Handle the result
        result.fold(
            (left) => emit(
                  state.copyWith(
                    state: RequestState.error,
                    error: NetworkExceptions.getErrorMessage(left),
                  ),
                ), (right) {
          if (event.accept) {
            di<AgencyRequestsBloc>()
                .add(const AgencyRequestsEvent(type: 'record'));

            secondTabAgencyTimeFilter.value =
                "${DateTime.now().year} / ${DateTime.now().month}";
            di<FetchMoreInfoAgencyBloc>().add(
              FetchMoreInfoForMonthEvent(
                  agencyId: (MyDataModel.getInstance().myAgencyModel?.id ?? 0)
                      .toString(),
                  month: secondTabAgencyTimeFilter.value.split('/')[1],
                  year: secondTabAgencyTimeFilter.value.split('/')[0],
                  page: (di<FetchMoreInfoAgencyBloc>()
                          .state
                          .userTargetCurrentPage)
                      .toString()),
            );
          } else {
            di<AgencyRequestsBloc>()
                .add(const AgencyRequestsEvent(type: 'record'));
          }
          emit(
            state.copyWith(
              state: RequestState.loaded,
              message: right.message,
            ),
          );
        });
      },
    );
  }
}
