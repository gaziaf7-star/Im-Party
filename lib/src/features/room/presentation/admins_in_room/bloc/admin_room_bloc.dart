import 'dart:async';
import 'package:general/src/features/auth/data/model/user_model.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';
import 'package:general/src/features/room/room.dart';
import 'package:general/src/core/index.dart';

part 'admin_room_events.dart';
part 'admin_room_states.dart';

/// LISTS a room's admins from the APP BACKEND (`rooms/admins`, backed by the
/// dual-written room_administrators / rooms.room_admin) — the durable source
/// of truth that survives broadcast restarts and matches the admin panel.
///
/// The engine's `list-by-role` is session-scoped, and inside a LIVE room the
/// audio `utdController` is null, which rendered the live admins list
/// permanently empty (owner report 2026-06-12). Promote/demote still go
/// through [changeUserRole] in `utd_role_helper.dart` (backend persist +
/// engine session grant); realtime membership stays in `adminsInRoom`.
class AdminRoomBloc extends Bloc<AdminRoomEvents, AdminRoomStates> {
  AdminRoomBloc() : super(const AdminRoomStates()) {
    on<GetAdminsEvent>(_getAdmins);
    on<RemoveAdminsLocallyEvent>(_removeAdminsLocally);
  }

  Future<void> _getAdmins(
    GetAdminsEvent event,
    Emitter<AdminRoomStates> emit,
  ) async {
    if (event.isLoading == true) {
      emit(state.copyWith(adminsReqState: RequestState.loading));
    }

    try {
      final List<UserModel> admins = await RoomRemoteDataSourceImp(di())
          .adminsRoom(ownerId: event.ownerId, roomId: event.roomId);
      emit(state.copyWith(
        admins: admins,
        adminsReqState: handleLoadedResponse<List<UserEntity>>(admins),
        fetchAdminsMessage: StringManager.success.tr(),
      ));
    } catch (e) {
      emit(state.copyWith(
        adminsReqState: RequestState.error,
        fetchAdminsMessage: StringManager.someThingWentWrong.tr(),
      ));
    }
  }

  Future<void> _removeAdminsLocally(
    RemoveAdminsLocallyEvent event,
    Emitter<AdminRoomStates> emit,
  ) async {
    final admins = List<UserEntity>.from(state.admins)
      ..removeWhere((element) => element.id.toString() == event.userId);
    emit(state.copyWith(admins: admins));
  }
}
