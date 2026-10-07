import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';

part 'agency_host_report_event.dart';

part 'agency_host_report_state.dart';

class AgencyHostReportBloc
    extends Bloc<BaseAgencyHostReportEvent, AgencyHostReportState> {
  final AgencyHostReportUC useCase;

  AgencyHostReportBloc({required this.useCase})
      : super(const AgencyHostReportState()) {
    on<AgencyHostReportEvent>((event, emit) async {
      if (event.isFirsLoading == true) {
        emit(state.copyWith(requestState: RequestState.loading));
      }
      final result = await useCase(AgencyHistoryParam(
          month: event.mounth,
          year: event.year,
          agencyId: MyDataModel.getInstance().id.toString()));
      result.fold(
          (left) => emit(
                state.copyWith(
                  requestState: handleErrorResponse(left),
                  error: NetworkExceptions.getErrorMessage(left),
                ),
              ), (right) {
        emit(state.copyWith(
            month: event.mounth,
            year: event.year,
            requestState: RequestState.loaded,
            data: right.data ?? const AgencyHostReportModel()));
      });
    });

    on<EditCutOutLocallyEvent>(_editCutOutLocally);
  }

  void _editCutOutLocally(
      EditCutOutLocallyEvent event, Emitter<AgencyHostReportState> emit) {
    // Correctly add the event.usd value to the current cutAmount
    final int usdUpdated = (state.data?.userSalary?.cutAmount ?? 0) + event.usd;

    // Create a new AgencyHostReportEntity with the updated cutAmount
    final AgencyHostReportEntity? dataUpdated = state.data?.copyWith(
      userSalary: state.data?.userSalary?.copyWith(cutAmount: usdUpdated),
    );

    // Emit a new state with the updated data
    emit(state.copyWith(data: dataUpdated));
  }
}

