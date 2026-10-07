part of 'admin_room_bloc.dart';

class AdminRoomStates extends Equatable {
  final List<UserEntity> admins;
  final RequestState adminsReqState;
  final String fetchAdminsMessage;

  const AdminRoomStates({
    this.admins = const [],
    this.fetchAdminsMessage = '',
    this.adminsReqState = RequestState.idle,
  });

  AdminRoomStates copyWith({
    List<UserEntity>? admins,
    String? fetchAdminsMessage,
    RequestState? adminsReqState,
  }) {
    return AdminRoomStates(
      admins: admins ?? this.admins,
      fetchAdminsMessage: fetchAdminsMessage ?? this.fetchAdminsMessage,
      adminsReqState: adminsReqState ?? this.adminsReqState,
    );
  }

  @override
  List<Object?> get props => [
        admins,
        fetchAdminsMessage,
        adminsReqState,
      ];
}
