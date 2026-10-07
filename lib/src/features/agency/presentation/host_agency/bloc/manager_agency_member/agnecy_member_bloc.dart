import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/core/index.dart';

part 'agnecy_member_event.dart';
part 'agnecy_member_state.dart';

class AgencyMemberBloc extends Bloc<BaseAgnecyMemberEvent, AgencyMemberState> {
  final AgencyMemberUC agencyMemberUC;

  AgencyMemberBloc({required this.agencyMemberUC})
      : super(const AgencyMemberState()) {
    on<AgnecyMemberEvent>(
      (event, emit) async {
        if (event.isFirsLoading == true) {
          emit(state.copyWith(requestState: RequestState.loading));
        }
        final result = await agencyMemberUC(event.page);
        result.fold(
          (left) => emit(
            state.copyWith(
              requestState: handleErrorResponse(left),
              error: NetworkExceptions.getErrorMessage(left),
            ),
          ),
          (right) => emit(state.copyWith(
              requestState:
                  handleLoadedResponse<List<AgencyMemberModel>?>(right.data),
              data: right.data)),
        );
      },
    );

    on<LoadMoreAgnecyMemberEvent>(
      (event, emit) async {
        final result = await agencyMemberUC(event.page);
        result.fold(
          (left) {
            emit(
              state.copyWith(
                error: NetworkExceptions.getErrorMessage(left),
              ),
            );
          },
          (right) {
            if (right.data != []) {
              emit(state.copyWith(
                  requestState: RequestState.loaded,
                  data: [...state.data!, ...?right.data]));
            }
          },
        );
      },
    );
  }
}
