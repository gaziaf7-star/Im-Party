import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/data/model/my_rooms_model.dart';

class FetchMyRoomDataState extends Equatable {
  final MyRoomsModel? rooms;
  final RequestState requestState;

  const FetchMyRoomDataState({
    this.rooms,
    this.requestState = RequestState.idle,
  });

  @override
  List<Object?> get props => [rooms, requestState];

  FetchMyRoomDataState copyWith({
    MyRoomsModel? rooms,
    RequestState? requestState,
  }) {
    return FetchMyRoomDataState(
      rooms: rooms ?? this.rooms,
      requestState: requestState ?? this.requestState,
    );
  }
}
