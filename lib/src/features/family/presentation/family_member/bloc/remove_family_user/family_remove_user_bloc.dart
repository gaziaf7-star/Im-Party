import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';

part 'family_remove_user_event.dart';

part 'family_remove_user_state.dart';

class FamilyRemoveUserBloc
    extends Bloc<BaseFamilyRemoveUserEvent, RemoveUserStates> {
  RemoveFamilyUserUC removeFamilyUserUC;

  FamilyRemoveUserBloc({required this.removeFamilyUserUC})
      : super(const RemoveUserStates()) {
    on<RemoverFamilyUser>((event, emit) async {
      emit(state.copyWith(reqState: RequestState.loading));
      final result = await removeFamilyUserUC(ChangeFamilyUserTypeParameter(
          userId: event.uId, familyId: event.familyId));

      result.fold(
          (l) => emit(state.copyWith(
              message: NetworkExceptions.getErrorMessage(l),
              reqState: RequestState.error)), (r) {
        di<FamilyMemberBloc>()
            .add(LocalRemoveFamilyUserEvent(userId: event.uId));
        di<ShowFamilyBloc>()
            .add( EditFamilyLocallyDeleteMemberCountLocallyEvent(userId:event.uId ));
        emit(state.copyWith(message: r, reqState: RequestState.loaded));
      });
    });
  }
}
