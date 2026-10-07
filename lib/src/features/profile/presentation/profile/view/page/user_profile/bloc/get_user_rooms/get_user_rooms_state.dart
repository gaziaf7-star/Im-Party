import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/data/model/user_room_model.dart';

class GetUserRoomsState extends Equatable {
  final UserRoomsModel? userRoomsModel;
  final NetworkExceptions? errorMessage;
  final RequestState requestState;


  const GetUserRoomsState({
    this.userRoomsModel,
    this.errorMessage,
    this.requestState=RequestState.idle,
  });

  GetUserRoomsState copyWith({
    UserRoomsModel? userRoomsModel ,
    NetworkExceptions? errorMessage,
    RequestState? requestState,
  }) {
    return GetUserRoomsState(
      userRoomsModel: userRoomsModel ?? this.userRoomsModel,
      requestState: requestState ?? this.requestState,
      errorMessage: errorMessage ?? this.errorMessage,

    );
  }

  @override
  List<Object?> get props => [
    userRoomsModel,
    requestState,
    errorMessage,
  ];
}
