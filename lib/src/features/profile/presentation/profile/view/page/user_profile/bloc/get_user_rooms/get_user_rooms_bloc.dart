import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/data/model/user_room_model.dart';
import 'package:general/src/features/profile/domain/profile_use_case/get_user_rooms_uc.dart';
import 'get_user_rooms_event.dart';
import 'get_user_rooms_state.dart';

class GetUserRoomsBloc extends Bloc<GetUserRoomsEvent, GetUserRoomsState> {
  GetUserRoomsUseCase getUserRoomsUseCase;
  GetUserRoomsBloc({required this.getUserRoomsUseCase})
      : super(const GetUserRoomsState()) {
        
    on<GetUserRooms>(
      (event, emit) async {
        emit(state.copyWith(requestState: RequestState.loading));
        final result = await getUserRoomsUseCase.call(event.id);

        result.fold(
          (l) => emit(state.copyWith(
            requestState: RequestState.error,
            errorMessage: l,
          )),
          (r) => emit(
            state.copyWith(
              userRoomsModel: r.data,
              requestState: handleLoadedResponse<UserRoomsModel>(r.data),
            ),
          ),
        );
      },
    );
  }
}
