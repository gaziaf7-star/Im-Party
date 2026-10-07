import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/fetch_more_info_agency/fetch_more_info_agency_bloc.dart';

part 'kick_out_agency_event.dart';

part 'kick_out_agency_state.dart';

class KickOutAgencyBloc
    extends Bloc<KickOutAgencyBaseEvent, KickOutAgencyState> {
  final KickOutAgencyUC kickOutAgencyUC;

  KickOutAgencyBloc({required this.kickOutAgencyUC})
      : super(const KickOutAgencyState()) {
    on<KickOutAgencyEvent>((event, emit) async {
      // Emit loading state
      emit(state.copyWith(state: RequestState.loading));

      // Perform use case operation
      final result = await kickOutAgencyUC(event.userId);

      // Handle result with success or error states
      result.fold((left) {
        emit(
          state.copyWith(
            state: RequestState.error,
            error: NetworkExceptions.getErrorMessage(left),
          ),
        );
        Methods.showToast(event.context,
            message: state.error ?? '', isError: true);
      }, (right) {
        emit(
          state.copyWith(
            state: RequestState.loaded,
            message: right.message,
          ),
        );
        // di<AgencyTimeBloc>().add(
        //     AgencyHistoryEditListLocallyEvent(userId: event.userId, type: '-'));
        // di<InformationAgencyBloc>()
        //     .add(const EditAgencyInformationLocallyEvent(type: '-'));
        secondTabAgencyTimeFilter.value =
            "${DateTime.now().year} / ${DateTime.now().month}";
        di<FetchMoreInfoAgencyBloc>().add(
          FetchMoreInfoForMonthEvent(
              agencyId:
                  (MyDataModel.getInstance().myAgencyModel?.id ?? 0).toString(),
              month: secondTabAgencyTimeFilter.value.split('/')[1],
              year: secondTabAgencyTimeFilter.value.split('/')[0],
              page: (di<FetchMoreInfoAgencyBloc>().state.userTargetCurrentPage)
                  .toString()),
        );
        di<AgencyMemberBloc>().add(const AgnecyMemberEvent(page: '1'));
      });
    });
  }
}
