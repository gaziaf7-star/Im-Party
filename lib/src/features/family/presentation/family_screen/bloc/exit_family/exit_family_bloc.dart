import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';

part 'exit_family_event.dart';

part 'exit_family_state.dart';

class ExitFamilyBloc extends Bloc<BaseExitFamilyEvent, ExitFamilyState> {
  ExitFamilyUC exitFamilyUseCase;

  ExitFamilyBloc({required this.exitFamilyUseCase})
      : super(const ExitFamilyState()) {
    on<ExitFamilyEvent>((event, emit) async {
      final result = await exitFamilyUseCase();
      result.fold(
          (l) => emit(
              state.copyWith(errorMsg: NetworkExceptions.getErrorMessage(l),reqState: handleErrorResponse(l))),
          (r) => emit(state.copyWith(message: r,reqState: handleLoadedResponse<String>(r))));
    });
  }
}
