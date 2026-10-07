import 'package:general/src/features/agency/agency.dart';import 'package:general/src/core/index.dart';

part 'show_agency_event.dart';
part 'show_agency_state.dart';

class ShowAgencyBloc extends Bloc<BaseShowAgencyEvent, ShowAgencyState> {
  final ShowAgencyUC showAgencymUsecase;

  ShowAgencyBloc({required this.showAgencymUsecase})
      : super(const ShowAgencyState()) {
    on<ShowAgencyEvent>(
          (event, emit) async {
        if (event.isFirstLoading == true) {
          emit(state.copyWith(requestState: RequestState.loading));
        }
        final result = await showAgencymUsecase(event.agencyId);
        result.fold(
              (left) => emit(
            state.copyWith(
              requestState: RequestState.error,
              error: NetworkExceptions.getErrorMessage(left),
            ),
          ),
              (right) => emit(state.copyWith(
              requestState: RequestState.loaded,
              data: right.data ?? const ShowAgencyModel())),
        );
      },
    );
    on<JoinShowAgencyLocalEvent>((event, emit) {
      final agency = state.data?.copyWith(isJoinRequest: true);
      if (agency == null) return;

      emit(
        state.copyWith(
          data: agency,
        ),
      );
    });
  }
}
