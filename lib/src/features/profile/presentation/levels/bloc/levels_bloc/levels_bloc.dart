import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/domain/entities/user_levels_entity.dart';
import 'package:general/src/features/profile/data/model/levels_badges_model.dart';
import 'package:general/src/features/profile/domain/entities/level_badges_entity.dart';
import 'package:general/src/features/profile/domain/profile_use_case/user_levels_uc.dart';
import 'package:general/src/features/profile/domain/profile_use_case/room_level_badges_uc.dart';
import '../../../../domain/profile_use_case/levels_badges_uc.dart';
import 'levels_event.dart';
import 'levels_state.dart';

class LevelBloc extends Bloc<LevelsEvent, AllLevelsState> {
  final LevelsBadgesUc levelsBadgesUc;
  final UserLevelsUc userLevelUc;
  final RoomLevelBadgesUc roomLevelBadgesUc;

  LevelBloc({
    required this.levelsBadgesUc,
    required this.userLevelUc,
    required this.roomLevelBadgesUc,
  }) : super(const AllLevelsState()) {
    on<ChangeBackgroundEvent>(_changeBackgroundEvent);
    on<ChangeTabEvent>(_changeTabEvent);
    on<GetLevelsBadges>(_getLevelsBadges);
    on<GetUserLevels>(_getUserLevels);
    on<GetRoomLevelBadges>(_getRoomLevelBadges);
    on<ChangeValueEvent>(_changeValueEvent);
  }

  void _changeBackgroundEvent(
      ChangeBackgroundEvent event, Emitter<AllLevelsState> emit) {
    emit(
      state.copyWith(selectedBg: event.selectedIndex + 1),
    );
  }

  void _changeTabEvent(ChangeTabEvent event, Emitter<AllLevelsState> emit) {
    emit(state.copyWith(selectedTab: event.selectedIndex));
  }

  Future<void> _getLevelsBadges(
    GetLevelsBadges event,
    Emitter<AllLevelsState> emit,
  ) async {
    final result = await levelsBadgesUc(event.type);
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            levelsBadgesRequest: handleErrorResponse(failure),
          ),
        );
      },
      (success) {
        emit(
          state.copyWith(
            levelsBadges: success.data,
            levelsBadgesRequest:
                handleLoadedResponse<BadgesEntity>(success.data),
          ),
        );
      },
    );
  }

  Future<void> _getUserLevels(
    GetUserLevels event,
    Emitter<AllLevelsState> emit,
  ) async {
    final result = await userLevelUc();
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            userLevelsRequest: handleErrorResponse(failure),
          ),
        );
      },
      (success) {
        emit(
          state.copyWith(
            userLevels: success.data,
            userLevelsRequest:
                handleLoadedResponse<UserLevelsEntity>(success.data),
          ),
        );
      },
    );
  }

  Future<void> _getRoomLevelBadges(
    GetRoomLevelBadges event,
    Emitter<AllLevelsState> emit,
  ) async {
    Methods.printLog('_getRoomLevelBadges called');
    emit(state.copyWith(roomLevelBadgesRequest: RequestState.loading));
    final result = await roomLevelBadgesUc();
    Methods.printLog('_getRoomLevelBadges result: $result');
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            roomLevelBadgesRequest: handleErrorResponse(failure),
          ),
        );
      },
      (success) {
        emit(
          state.copyWith(
            roomLevelBadges: success.data?.roomLevel ?? [],
            roomLevelBadgesRequest:
                handleLoadedResponse<RoomLevelBadgesModel>(success.data),
          ),
        );
      },
    );
  }

  void _changeValueEvent(ChangeValueEvent event, Emitter<AllLevelsState> emit) {
    emit(state.copyWith(changeImage: event.changeImage));
  }
}
