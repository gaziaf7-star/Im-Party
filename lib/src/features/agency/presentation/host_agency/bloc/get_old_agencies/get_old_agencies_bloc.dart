import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/domain/entity/old_agency_entity.dart';
import 'package:general/src/features/agency/domain/use_case/get_old_agencies.dart';

part 'get_old_agencies_event.dart';

part 'get_old_agencies_state.dart';

class GetOldAgenciesBloc
    extends Bloc<GetOldAgenciesEvent, GetOldAgenciesState> {
  final GetOldAgenciesUC useCase;

  GetOldAgenciesBloc(this.useCase) : super(const GetOldAgenciesState()) {
    on<GetOldAgenciesEvent>((event, emit) async {
      emit(state.copyWith(state: RequestState.loading));

      final result = await useCase();
      result.fold(
        (l) {
          emit(state.copyWith(
              message: NetworkExceptions.getErrorMessage(l),
              state: handleErrorResponse(l)));
        },
        (r) {
          emit(state.copyWith(
              data: r.data, state: handleLoadedResponse(r.data)));
        },
      );
    });
  }
}
