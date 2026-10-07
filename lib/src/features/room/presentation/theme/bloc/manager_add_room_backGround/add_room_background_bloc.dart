import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/use_case/add_room_background_uc.dart';
import 'package:general/src/features/room/presentation/theme/bloc/manager_add_room_backGround/add_room_background_event.dart';
import 'package:general/src/features/room/presentation/theme/bloc/manager_add_room_backGround/add_room_background_state.dart';

class AddRoomBackgroundBloc
    extends Bloc<BaseAddRoomBackgroundEvent, AddRoomBackgroundState> {
  AddRoomBackGroundUseCase addRoomBackgroundUseCase;

  AddRoomBackgroundBloc({required this.addRoomBackgroundUseCase})
      : super(AddRoomBackgroundInitial()) {
    on<AddRoomBackgroundEvent>((event, emit) async {
      emit(AddRoomBackgroundLoading());
      final result = await addRoomBackgroundUseCase.call(event.roomBackGround);

      result.fold(
        (l) {
          emit(AddRoomBackgroundError(
              error: NetworkExceptions.getErrorMessage(l)));
          Methods.safeShowToast(
              isError: true, message: NetworkExceptions.getErrorMessage(l));
        },
        (r) => emit(AddRoomBackgroundSuccess(massage: r)),
      );
    });
  }
}
