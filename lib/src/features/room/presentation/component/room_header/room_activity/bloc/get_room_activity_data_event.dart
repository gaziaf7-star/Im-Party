part of 'get_room_activity_data_bloc.dart';

abstract class GetRoomActivityDataEvent extends Equatable {
  const GetRoomActivityDataEvent();

  @override
  List<Object?> get props => [];
}

class FetchRoomActivityDataEvent extends GetRoomActivityDataEvent {
  final int roomId;

  const FetchRoomActivityDataEvent(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

class FetchRoomActivityWebViewLinkEvent extends GetRoomActivityDataEvent {
  final BuildContext context;

  const FetchRoomActivityWebViewLinkEvent(this.context);

  @override
  List<Object?> get props => [context];
}
