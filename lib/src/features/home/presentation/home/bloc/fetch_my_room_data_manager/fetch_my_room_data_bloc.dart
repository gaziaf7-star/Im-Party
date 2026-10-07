import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/domain/use_cases/fetch_my_room_data_uc.dart';
import 'package:general/src/features/home/presentation/home/bloc/fetch_my_room_data_manager/fetch_my_room_data_event.dart';
import 'package:general/src/features/home/presentation/home/bloc/fetch_my_room_data_manager/fetch_my_room_data_state.dart';

class FetchMyRoomDataBloc
    extends Bloc<BaseFetchMyRoomDataEvent, FetchMyRoomDataState> {
  final FetchMyRoomDataUc fetchMyRoomDataUc;

  FetchMyRoomDataBloc({required this.fetchMyRoomDataUc})
      : super(const FetchMyRoomDataState()) {
    on<FetchMyRoomDataEvent>((event, emit) async {
      final resault = await fetchMyRoomDataUc();
      resault.fold(
        (l) => emit(
          state.copyWith(
            requestState: handleErrorResponse(l),
          ),
        ),
        (r) {
          emit(
            state.copyWith(
              requestState: handleLoadedResponse(r),
              rooms: r.data,
            ),
          );
        },
      );
    });
  }
}
