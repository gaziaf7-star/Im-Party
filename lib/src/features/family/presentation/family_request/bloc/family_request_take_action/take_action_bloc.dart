import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';

part 'take_action_event.dart';
part 'take_action_state.dart';

class TakeActionBloc extends Bloc<BaseTakeActionEvent, TakeActionState> {
  final FamilyTakeActionUC familyTakeActionUC;

  TakeActionBloc({required this.familyTakeActionUC})
      : super(const TakeActionState()) {
    on<FamilyTakeActionEvent>(
      (event, emit) async {
        emit(state.copyWith(reqState: RequestState.loading));
        final result = await familyTakeActionUC(FamilyTakeActionReq(
          status: event.status,
          reqId: event.reqId,
userId: event.userId
        ));

        result.fold(
            (left) => emit(
                  state.copyWith(
                      message: NetworkExceptions.getErrorMessage(left),
                      reqState: handleErrorResponse(left)),
                ), (right) {
          if (event.status == '1') {
            di<FamilyRoomBloc>()
                .add(GetFamilyRoomEvent(familyId: event.familyId));
            di<ShowFamilyBloc>().add(
                EditFamilyLocallyAcceptRequestLocallyEvent(userMember: right.data));
            di<FamilyMemberBloc>()
                .add(LocalAddFamilyUserEvent(user: right.data!));
          }

          di<FamilyRequestBloc>()
              .add(LocalEditRequestEvent(userId: event.userId));
          emit(state.copyWith(
              userMember: right.data,
              message: right.message,
              reqState: handleLoadedResponse<String>(right.message)));
        });
      },
    );
  }
}
