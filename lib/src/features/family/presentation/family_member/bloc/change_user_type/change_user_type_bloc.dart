import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';

part 'change_user_type_event.dart';

part 'change_user_type_state.dart';

class ChangeUserTypeBloc
    extends Bloc<BaseChangeUserTypeEvent, ChangeUserTypeState> {
  ChangeFamilyUserTypeUC changeFamilyUserTypeUC;

  ChangeUserTypeBloc({required this.changeFamilyUserTypeUC})
      : super(const ChangeUserTypeState()) {
    on<ChangeUserTypeEvent>((event, emit) async {
      emit(state.copyWith(reqState: RequestState.loading));
      final result = await changeFamilyUserTypeUC(
        ChangeFamilyUserTypeParameter(
          userId: event.userId,
          familyId: event.familyId,
          type: event.type,
        ),
      );

      result.fold(
        (left) => emit(
          state.copyWith(
            message: NetworkExceptions.getErrorMessage(left),
            reqState: handleErrorResponse(left),
          ),
        ),
        (right) {
          di<FamilyMemberBloc>().add(LocalChangeUserTypeUserEvent(
              type: event.type, userId: event.userId));
          di<ShowFamilyBloc>().add(EditFamilyLocallyChangeUserTypeLocallyEvent(
              type: event.type, userId: event.userId));

          emit(
            state.copyWith(
              message: right,
              reqState: handleLoadedResponse<String>(right),
            ),
          );
        },
      );
    });
  }
}
