import 'package:general/src/core/index.dart';
import 'package:general/src/features/cp/cp.dart';
part 'cp_profile_event.dart';
part 'cp_profile_state.dart';

class CpProfileBloc extends Bloc<CpProfileEvents, CpProfileStates> {
  final CpProfileUseCase cpProfileUseCase;
  final CpBuySeatsUseCase cpBuySeatsUseCase;

  CpProfileBloc({
    required this.cpProfileUseCase,
    required this.cpBuySeatsUseCase,
  }) : super(const CpProfileStates()) {
    on<GetCpProfileEvents>((event, emit) async {
      if (!event.forceRefresh &&
          state.reqStates == RequestState.loaded &&
          state.loadedUserId == event.userId) {
        return;
      }
      emit(state.copyWith(reqStates: RequestState.loading));
      final result = await cpProfileUseCase.call(event.userId);
      result.fold(
          (failure) => emit(
                state.copyWith(
                  errorMessage: NetworkExceptions.getErrorMessage(failure),
                  data: null,
                  reqStates: RequestState.error,
                ),
              ), (success) {
        emit(
          state.copyWith(
            data: success.data!,
            message: success.message,
            loadedUserId: event.userId,
            reqStates: RequestState.loaded,
          ),
        );
      });
    });

    on<BuyCpSeatsEvents>((event, emit) async {
      emit(state.copyWith(buyCpReqStates: RequestState.loading));
      final result = await cpBuySeatsUseCase.call(event.wareId);
      result.fold((failure) {
        emit(
          state.copyWith(
            buyCpErrorMessage: NetworkExceptions.getErrorMessage(failure),
            data: null,
            buyCpReqStates: RequestState.error,
          ),
        );
        emit(
          state.copyWith(
            buyCpErrorMessage: "",
            data: null,
            buyCpReqStates: RequestState.idle,
          ),
        );
      }, (success) {
        emit(
          state.copyWith(
            buyCpMessage: success,
            buyCpReqStates: RequestState.loaded,
          ),
        );
        emit(
          state.copyWith(
            buyCpMessage: "",
            buyCpReqStates: RequestState.idle,
          ),
        );
      });
    });
  }
}
