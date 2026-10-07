import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';
import 'package:general/src/features/home/domain/entities/room_entity.dart';



part 'get_family_room_event.dart';
part 'get_family_room_state.dart';

class FamilyRoomBloc extends Bloc<FamilyRoomEvent, FamilyRoomState> {
  final GetFamilyRoomsUC getFamilyRoomsUseCase;

  FamilyRoomBloc({required this.getFamilyRoomsUseCase})
      : super(const FamilyRoomState()) {
    on<GetFamilyRoomEvent>(
      (event, emit) async {
        if(event.isFirstLoading==true) {
          emit(state.copyWith(reqState: RequestState.loading));
        }
        final result = await getFamilyRoomsUseCase(event.familyId);

        result.fold(
          (left) => emit(
            state.copyWith(
                errorMsg: NetworkExceptions.getErrorMessage(left),reqState: handleErrorResponse(left)),
          ),
          (right) => emit(state.copyWith(data: right.data ?? [],reqState: handleLoadedResponse<List<RoomEntity>>(right.data))),
        );
      },
    );
  }
}
