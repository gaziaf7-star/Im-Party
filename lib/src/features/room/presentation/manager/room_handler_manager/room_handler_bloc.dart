import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class RoomHandlerBloc extends Bloc<RoomHandlerEvents, RoomHandlerStates> {
  final EnterRoomUC enterRoomUC;

  RoomHandlerBloc({required this.enterRoomUC})
      : super(InitialHandlerRoomStates()) {
    on<EnterRoomEvent>(
      (event, emit) async {
        emit(EnterRoomLaoding());
        final result = await enterRoomUC(
          EnterRoomParameter(
            roomId: event.roomId,
            roomPassword: event.roomPassword,
            isVip: event.isVip,
          ),
        );
        result.fold(
          (left) {
            emit(
              EnterRoomErrorMessageState(
                errorMessage: NetworkExceptions.getErrorMessage(left),
              ),
            );
          },
          (right) {
            // BaseResponse.data is nullable (data:null bodies). Force-unwrapping
            // here throws on the success branch and the room entry silently hangs
            // (no success, no error). Route a null body to the error state.
            final room = right.data;
            if (room == null) {
              emit(
                EnterRoomErrorMessageState(
                  errorMessage: StringManager.someThingWentWrong.tr(),
                ),
              );
              return;
            }
            emit(EnterRoomSuccesMessageState(room: room));
          },
        );
      },
    );

    on<EmitCachedRoomDataEvent>(
      (event, emit) {
        emit(EnterRoomSuccesMessageState(room: event.room));
      },
    );

    on<ResetRoomHandlerEvent>(
      (event, emit) {
        emit(InitialHandlerRoomStates());
      },
    );
  }
}
