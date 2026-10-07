import 'package:general/src/core/index.dart';

import 'package:general/src/features/agency/agency.dart';
part 'host_requests_event.dart';
part 'host_requests_state.dart';
class HostRequestsBloc extends Bloc<HostRequestsEvent, HostRequestsState> {
  final GetHostRequestsUC getHostRequestsUseCase;
  final HostRequestActionUC hostRequestActionUseCase;

  HostRequestsBloc(
      {required this.getHostRequestsUseCase,
      required this.hostRequestActionUseCase})
      : super(const HostRequestsState()) {
    on<GetHostRequestsEvent>((event, emit) async {
      final result = await getHostRequestsUseCase(event.type);
      result.fold(
        (l) => emit(state.copyWith(
            getListStatus: handleErrorResponse(l),
            error: NetworkExceptions.getErrorMessage(l))),
        (r) => emit(state.copyWith(
            getListStatus: handleLoadedResponse(right),
            hostRequestsModel: r.data ?? [])),
      );
    });

    on<HostRequestActionEvent>((event, emit) async {
      final result = await hostRequestActionUseCase(
          AgencyRequestsActionParam(id: event.id, answer: event.answer));
      result.fold(
        (l) => emit(state.copyWith(
            makeActionStatus: RequestState.error,
            error: NetworkExceptions.getErrorMessage(l))),
        (r) => emit(
            state.copyWith(makeActionStatus: RequestState.loaded, message: r.message)),
      );
    });
    on<HostRequestDialogViewEvent>((event, emit) async {

      emit(state.copyWith(dialogsYouHave: event.newValue));


    });
  }
}
