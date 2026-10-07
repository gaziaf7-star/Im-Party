import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';

part 'join_family_event.dart';

part 'join_family_state.dart';

class JoinFamilyBloc extends Bloc<BaseJoinFamilyEvent, BaseJoinFamilyState> {
  final JoinFamilyUC joinFamilyUseCase;

  JoinFamilyBloc({required this.joinFamilyUseCase})
      : super(const BaseJoinFamilyState()) {
    on<JoinFamilyEvent>((event, emit) async {
      emit(state.copyWith(reqState: RequestState.loading));
      final result = await joinFamilyUseCase(event.familyId);
      result.fold(
          (l) => emit(
              state.copyWith(errorMsg: NetworkExceptions.getErrorMessage(l),reqState: handleErrorResponse(l))),
          (r) => emit(state.copyWith(message: r,reqState: handleLoadedResponse<String>(r))));
    });

    on<ResetJoinFamilyEvent>((event, emit) async {
      emit(state.copyWith(reqState: RequestState.idle));
    });
  }

}
