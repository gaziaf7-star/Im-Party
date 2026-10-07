part of 'get_family_room_bloc.dart';



class FamilyRoomState extends Equatable {
  final List<RoomEntity>? data;
  final String? errorMsg;
  final RequestState reqState;

  const FamilyRoomState({
    this.data ,
    this.errorMsg ,
    this.reqState = RequestState.loading,
  });

  FamilyRoomState copyWith({
    List<RoomEntity>? data,
    String? errorMsg,
    RequestState? reqState,
  }) {
    return FamilyRoomState(
      data: data ?? this.data,
      errorMsg: errorMsg ?? this.errorMsg,
      reqState: reqState ?? this.reqState,
    );
  }

  @override
  List<Object?> get props => [
    data,
    errorMsg,
    reqState,
  ];
}