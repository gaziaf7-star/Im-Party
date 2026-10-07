import 'package:general/src/core/index.dart';
import 'package:general/src/features/cp/cp.dart';

part 'cp_relations_event.dart';
part 'cp_relations_state.dart';

class GetCpRelationsBloc extends Bloc<CpRelationsEvents, CpRelationsStates> {
  final GetCpRelationsUseCase _getCpRelationsUseCase;
  final CpRequestRespondUseCase _cpRequestRespondUseCase;

  GetCpRelationsBloc(this._getCpRelationsUseCase, this._cpRequestRespondUseCase)
      : super(const CpRelationsStates()) {
    on<GetCpRelationsEvents>((event, emit) async {
      emit(state.copyWith(userStates: RequestState.loading));
      final result = await _getCpRelationsUseCase.call();

      result.fold(
          (failure) => emit(state.copyWith(
              errorMessage: NetworkExceptions.getErrorMessage(failure),
              data: null,
              userStates: RequestState.error)), (success) {
        emit(
          state.copyWith(
            data: success.data!,
            message: success.message,
            userStates: RequestState.loaded,
          ),
        );
      });
    });

    on<CpRelationRespondEvents>((event, emit) async {
      emit(state.copyWith(
        cpRelationRespondState: RequestState.loading,
        loadingMessageId: event.messageId,
        loadingStatus: event.status,
      ));
      final result = await _cpRequestRespondUseCase.call(
        CpRequestRespondParam(
            cpId: event.cpId, messageId: event.messageId, status: event.status),
      );
      result.fold(
        (l) => emit(
          state.copyWith(
            cpRelationRespondMessage: NetworkExceptions.getErrorMessage(l),
            cpRelationRespondState: RequestState.error,
            loadingMessageId: null,
            loadingStatus: null,
          ),
        ),
        (r) {
          final updatedMap =
              Map<String, String>.from(state.updatedMessageStatuses);
          updatedMap[event.messageId] = event.status;
          emit(
            state.copyWith(
              cpRelationRespondState: RequestState.loaded,
              cpRelationRespondMessage: r.data,
              loadingStatus: null,
              loadingMessageId: null,
              updatedMessageStatuses: updatedMap,
            ),
          );
        },
      );
    });
  }
}
