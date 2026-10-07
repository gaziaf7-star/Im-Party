part of 'admin_room_bloc.dart';

abstract class AdminRoomEvents extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetAdminsEvent extends AdminRoomEvents {
  final String ownerId;
  final String roomId;
  final bool isLoading;

  GetAdminsEvent(
      {required this.ownerId, required this.roomId, this.isLoading = true});
  @override
  List<Object?> get props => [ownerId, roomId, isLoading];
}

class RemoveAdminsLocallyEvent extends AdminRoomEvents {
  final String userId;

  RemoveAdminsLocallyEvent({required this.userId});
  @override
  List<Object?> get props => [userId];
}
