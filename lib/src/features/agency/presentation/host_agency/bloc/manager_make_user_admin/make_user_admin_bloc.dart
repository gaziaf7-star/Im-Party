import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';

part 'make_user_admin_event.dart';

part 'make_user_admin_state.dart';

class MakeUserAdminBloc
    extends Bloc<BaseMakeUserAdminEvent, MakeUserAdminState> {
  final MakeUserAdminUC makeUserAdminUseCase;

  MakeUserAdminBloc({required this.makeUserAdminUseCase})
      : super(const MakeUserAdminState()) {
    on<MakeUserAdminEvent>(
      (event, emit) async {
        if (event.isFirstLoading == true) {
          emit(state.copyWith(requestState: RequestState.loading));
        }
        final result = await makeUserAdminUseCase(AgencyRequestsActionParam(
            id: event.id.toString(), answer: event.type));
        result.fold(
          (left) => emit(
            state.copyWith(
              requestState: handleErrorResponse(left),
              error: NetworkExceptions.getErrorMessage(left),
            ),
          ),
          (right) {
            di<AgencyMemberBloc>().add(const AgnecyMemberEvent(page: '1'));

            emit(state.copyWith(
              requestState: RequestState.loaded, message: right.message));
          },
        );
      },
    );
  }
}
