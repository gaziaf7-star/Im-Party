import 'package:general/src/core/index.dart';
import 'package:general/src/features/cp/cp.dart';

part 'cp_request_event.dart';
part 'cp_request_state.dart';

class CpRequestBloc extends Bloc<CpRequestEvents, CpRequestStates> {
  final CpRequestUseCase cpRequestUseCase;

  CpRequestBloc({required this.cpRequestUseCase})
      : super(const CpRequestStates()) {
    on<CpRequestEvents>((event, emit) async {
      emit(
        state.copyWith(
          userStates: RequestState.loading,
          loadingUserId: event.userId,
        ),
      );
      final result = await cpRequestUseCase.call(CpRequestParam(
        relationId: event.relationId,
        userId: event.userId,
      ));
      result.fold((failure) {
        emit(
          state.copyWith(
            errorMessage: NetworkExceptions.getErrorMessage(failure),
            userStates: RequestState.error,
            loadingUserId: "",
          ),
        );

        Methods.safeShowToast(
          message: NetworkExceptions.getErrorMessage(failure),
          isError: true,
        );
      }, (success) {
        emit(
          state.copyWith(
            message: success,
            userStates: RequestState.loaded,
            loadingUserId: "",
          ),
        );

        Methods.safeShowToast(
          message: success,
        );
      });
    });
  }
}
