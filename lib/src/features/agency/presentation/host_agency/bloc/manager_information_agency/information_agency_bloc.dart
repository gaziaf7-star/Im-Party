import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';

import '../../../../data/model/information_agency_model.dart';

part 'information_agency_event.dart';

part 'information_agency_state.dart';

class InformationAgencyBloc
    extends Bloc<BaseInformationAgencyEvent, InformationAgencyState> {
  final InformationAgencyUC informationAgencyUC;

  InformationAgencyBloc({required this.informationAgencyUC})
      : super(const InformationAgencyState()) {
    on<InformationAgencyEvent>(_informationAgency);
    // on<EditAgencyInformationLocallyEvent>(_editAgencyInformationLocallyEvent);
    // on<EditAgentSalaryInformationLocallyEvent>(
    //     _editAgentSalaryInformationLocally);
  }

  Future<void> _informationAgency(InformationAgencyEvent event,
      Emitter<InformationAgencyState> emit) async {
    if (event.isFirstLoading == true) {
      emit(state.copyWith(requestState: RequestState.loading));
    }
    final result = await informationAgencyUC(AgencyHistoryParam(
        month: event.month,
        year: event.year,
        agencyId: event.agencyId ??
            (MyDataModel.getInstance().myAgencyModel?.id ?? 1).toString()));
    result.fold(
      (failure) => emit(
        state.copyWith(
          requestState: handleErrorResponse(failure),
          error: NetworkExceptions.getErrorMessage(failure),
        ),
      ),
      (success) {
        int x = 0;
        if ((success.data?.img ?? '').isEmpty ||
            (success.data?.bio ?? '').isEmpty) {
          x = (state.rebuildForTheListner) + 1;
        }
        final isCurrentMonth = int.parse(event.month) == DateTime.now().month;
        final isCurrentYear = int.parse(event.year) == DateTime.now().year;
        final shouldUpdateNowStars = isCurrentMonth && isCurrentYear;

        emit(state.copyWith(
            month: event.month,
            year: event.year,
            requestState: RequestState.loaded,
            nowStars: shouldUpdateNowStars
                ? (success.data?.stars ?? [])
                : state.nowStars,
            nowAdmins: shouldUpdateNowStars
                ? (success.data?.admins ?? [])
                : state.nowAdmins,
            data: success.data ?? const InformationAgencyModel(),
            rebuildForTheListner: x));
      },
    );
  }

// void _editAgencyInformationLocallyEvent(
//     EditAgencyInformationLocallyEvent event,
//     Emitter<InformationAgencyState> emit,
//     ) {
//
//   final InformationAgencyEntity? updatedData;
//   final int currentHosts = state.data?.numOfHosts ?? 0;
//   if (event.type == '-') {
//
//
//     updatedData = state.data?.copyWith(numOfHosts: currentHosts - 1);
//
//   } else {
//
//
//     updatedData = state.data?.copyWith(numOfHosts: currentHosts + 1);
//
//   }
//
//   emit(state.copyWith(data: updatedData));
//
// }

// void _editAgentSalaryInformationLocally(
//   EditAgentSalaryInformationLocallyEvent event,
//   Emitter<InformationAgencyState> emit,
// ) {
//   log('_editAgentSalaryInformationLocally 1: ${event.agentUsd}');
//   final int updatedAgentUsd =
//       (state.data?.agentSalary ?? event.agentUsd) - event.agentUsd;
//   log('_editAgentSalaryInformationLocally 2: $updatedAgentUsd');
//
//   final InformationAgencyEntity? updatedData =
//       state.data?.copyWith(agentSalary: updatedAgentUsd);
//   log('_editAgentSalaryInformationLocally 2: ${updatedData?.agentSalary}');
//
//   emit(state.copyWith(data: updatedData));
// }
}
