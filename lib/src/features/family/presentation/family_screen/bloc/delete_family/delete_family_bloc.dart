import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';

part 'delete_family_event.dart';
part 'delete_family_state.dart';
class DeleteFamilyBloc extends Bloc<DeleteFamilyEvent, DeleteFamilyState> {
  final DeleteFamilyUC deleteFamilyUseCse;

  DeleteFamilyBloc({required this.deleteFamilyUseCse})
      : super(const DeleteFamilyState()) {
    on<DeleteFamilyEvent>(
      (event, emit) async {
        emit(state.copyWith(reqState: RequestState.loading));
        final result = await deleteFamilyUseCse(event.id);
        result.fold(
          (left) => emit(
            state.copyWith(
              errorMsg: NetworkExceptions.getErrorMessage(left),
              reqState: handleErrorResponse(left),
            ),
          ),
          (right)

          {

                  emit(state.copyWith(
                      message: right,
                      reqState: handleLoadedResponse<String>(right)));
                });
      },
    );
  }
}
