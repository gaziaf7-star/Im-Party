part of 'get_room_activity_data_bloc.dart';

class GetRoomActivityDataState extends Equatable {
  final RoomRewardModel? dataModel;
  final String message;
  final RequestState requestState;
  final String webViewLink;

  const GetRoomActivityDataState({
    this.dataModel,
    this.message = '',
    this.webViewLink = '',
    this.requestState = RequestState.idle,
  });

  GetRoomActivityDataState copyWith({
    RoomRewardModel? dataModel,
    String? message,
    String? webViewLink,
    RequestState? requestState,
  }) {
    return GetRoomActivityDataState(
      dataModel: dataModel ?? this.dataModel,
      message: message ?? this.message,
      webViewLink: webViewLink ?? this.webViewLink,
      requestState: requestState ?? this.requestState,
    );
  }

  @override
  List<Object?> get props => [dataModel, message, requestState, webViewLink];
}
