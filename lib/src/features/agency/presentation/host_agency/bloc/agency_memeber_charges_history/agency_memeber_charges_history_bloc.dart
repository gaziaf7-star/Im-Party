import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/data/model/agency_history_model.dart';
import 'package:general/src/features/agency/domain/use_case/agency_history_uc.dart';

part 'agency_memeber_charges_history_event.dart';

part 'agency_memeber_charges_history_state.dart';

class AgencyMemeberChargesHistoryBloc extends Bloc<
    BaseAgencyMemeberChargesHistoryEvent, AgencyMemeberChargesHistoryState> {
  final AgencyMemberChargesHistoryUC useCase;

  AgencyMemeberChargesHistoryBloc(this.useCase)
      : super(const AgencyMemeberChargesHistoryState()) {
    on<AgencyMemeberToUserChargesHistoryEvent>((event, emit) async {
      if (event.isFirstLoading) {
        emit(state.copyWith(userState: RequestState.loading));
      }

      final result = await useCase('user');
      result.fold(
        (l) => emit(state.copyWith(
          userState: RequestState.error,
          userMessage: NetworkExceptions.getErrorMessage(l),
        )),
        (r) => emit(state.copyWith(
          userState: handleLoadedResponse(r.data),
          userModel: r.data,
        )),
      );
    });

    on<AgencyMemeberToAgencyChargesHistoryEvent>((event, emit) async {
      if (event.isFirstLoading) {
        emit(state.copyWith(agencyState: RequestState.loading));
      }

      final result = await useCase('agency');
      result.fold(
        (l) => emit(state.copyWith(
          agencyState: RequestState.error,
          agencyMessage: NetworkExceptions.getErrorMessage(l),
        )),
        (r) => emit(state.copyWith(
          agencyState: handleLoadedResponse(r.data),
          agencyModel: r.data,
        )),
      );
    });
  }
}

// class AgencyMemeberChargesHistoryBloc extends Bloc<
//     AgencyMemeberToUserChargesHistoryEvent, AgencyMemeberChargesHistoryState> {
//   final AgencyMemberChargesHistoryUC useCase;
//
//   AgencyMemeberChargesHistoryBloc(this.useCase)
//       : super(const AgencyMemeberChargesHistoryState()) {
//     on<AgencyMemeberToUserChargesHistoryEvent>((event, emit) async {
//       if (event.isFirstLoading == true) {
//         emit(state.copyWith(state: RequestState.loading));
//       }
//       final result = await useCase(event.type);
//       result.fold((l) {
//         emit(state.copyWith(
//             state: RequestState.error,
//             message: NetworkExceptions.getErrorMessage(l)));
//       }, (r) {
//         emit(state.copyWith(state: RequestState.loaded, model: r.data));
//       });
//     });
//   }
// }
