
import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';


part 'family_request_event.dart';

part 'family_request_state.dart';

class FamilyRequestBloc
    extends Bloc<BaseFamilyRequestEvent, FamilyRequestState> {
  final GetFamilyRequestsRoomsUC getFamilyRequestsRoomsUC;

  FamilyRequestBloc({required this.getFamilyRequestsRoomsUC})
      : super(const FamilyRequestState()) {
    on<GetFamilyRequestEvent>(
      (event, emit) async {
        if (event.isLoading == true) {
          emit(state.copyWith(reqState: RequestState.loading));
        }

        final result = await getFamilyRequestsRoomsUC();

        result.fold(
          (left) => emit(
            state.copyWith(
                errorMsg: NetworkExceptions.getErrorMessage(left),
                reqState: handleErrorResponse(left)),
          ),
          (right) => emit(state.copyWith(
              data: right.data ?? [],
              reqState:
                  handleLoadedResponse<List<FamilyRequestEntity>>(right.data))),
        );
      },
    );

    on<LocalEditRequestEvent>((event, emit) async {


      final FamilyRequestEntity userRequest = (state.data ?? []).firstWhere(
        (element) => element.user.id.toString() == event.userId,
        // orElse: () => FamilyRequestEntity(
        //     user: UserEntity(name: 'alllllllllli'), id: 152, time: 'llllll'),
      );

      final List<FamilyRequestEntity> updatedList = List.from(state.data ?? [])
        ..remove(userRequest);

      emit(state.copyWith(
        data: updatedList,
      ));
    });
  }
}
