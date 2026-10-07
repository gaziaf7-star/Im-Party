import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/data/model/get_badges_model.dart';
import 'package:general/src/features/profile/data/model/badges_model.dart';
import 'package:general/src/features/profile/domain/entities/get_user_badges_entity.dart';
import 'package:general/src/features/profile/domain/profile_use_case/get_badges_use_case.dart';
import 'package:general/src/features/profile/domain/profile_use_case/get_my_all_badge.dart';

part 'badges_event.dart';
part 'badges_state.dart';

class GetBadgesBloc extends Bloc<BadgesEvent, GetBadgesStates> {
  final GetBadgesUC getBadgesUseCase;
  final GetMyAllBadgeUC getMyAllBadgeUC;
  GetBadgesBloc({required this.getBadgesUseCase, required this.getMyAllBadgeUC})
      : super(const GetBadgesStates()) {
    on<RechargeEvent>(_rechargeEvent);
    on<RoomEvent>(_getRoomsEvent);
    on<GiftEvent>(_getGiftsEvent);
    on<ActivityEvent>(_activityEvent);
    on<GetMyAllBadges>(_getMyAllBadge);
    on<ChangeAppBarUIMedalsEvent>(changeAppBarUI);
    on<ChangeMyMedalsAppBarUIEvent>(changeMyMedalsAppBarUI);
    on<SelectedAcheivementEvent>(selectedAcheivement);
  }
  Future<void> _getMyAllBadge(
    GetMyAllBadges event,
    Emitter<GetBadgesStates> emit,
  ) async {
    final requestedUserId = event.id.toString();
    final sameUser = state.lastLoadedBadgeUserId == requestedUserId;
    final alreadyLoadedOrLoading = state.myAllBadgeState == RequestState.loaded ||
        state.myAllBadgeState == RequestState.loading;
    if (!event.force && sameUser && alreadyLoadedOrLoading) {
      return;
    }

    emit(state.copyWith(
      myAllBadgeState: RequestState.loading,
      lastLoadedBadgeUserId: requestedUserId,
    ));

    final result = await getMyAllBadgeUC.call(requestedUserId);
    result.fold(
      (left) => emit(
        state.copyWith(
          errorMyAllBadge: NetworkExceptions.getErrorMessage(left),
          myAllBadgeState: RequestState.error,
        ),
      ),
      (right) => emit(
        state.copyWith(
          myAllBadge: right.data,
          myAllBadgeState: handleLoadedResponse<List<ImageData>>(right.data),
        ),
      ),
    );
  }

  /// `right.data?[0]` throws a RangeError when the backend returns an empty
  /// (but non-null) `data: []` array — `?[]` only guards a null receiver, not
  /// an out-of-range index. Confirmed from a live crash on every one of these
  /// four badge categories when their API response had no rows.
  List<AchievementLevelEntity> _firstLevels(List<GetBadgesModel>? data) {
    if (data == null || data.isEmpty) return [];
    return data[0].levels;
  }

  Future<void> _activityEvent(
    ActivityEvent event,
    Emitter<GetBadgesStates> emit,
  ) async {
    if (event.isLoading == false) {
      emit(state.copyWith(activityBadgeRequest: RequestState.loading));
    }

    final result = await getBadgesUseCase.call('4');
    result.fold(
      (left) => emit(
        state.copyWith(
          activityBadgeRequest: handleErrorResponse(left),
          activityBadgeMessage: NetworkExceptions.getErrorMessage(left),
        ),
      ),
      (right) => emit(
        state.copyWith(
          activityBadge: _firstLevels(right.data),
          activityBadgeRequest:
              handleLoadedResponse<List<GetBadgesModel>>(right.data),
        ),
      ),
    );
  }

  Future<void> _rechargeEvent(
    RechargeEvent event,
    Emitter<GetBadgesStates> emit,
  ) async {
    if (event.isLoading != false) {
      emit(state.copyWith(rechargeBadgeRequest: RequestState.loading));
    }

    final result = await getBadgesUseCase.call('1');
    result.fold(
      (left) => emit(
        state.copyWith(
          rechargeBadgeRequest: handleErrorResponse(left),
          rechargeBadgeMessage: NetworkExceptions.getErrorMessage(left),
        ),
      ),
      (right) => emit(
        state.copyWith(
          rechargeBadge: _firstLevels(right.data),
          rechargeBadgeRequest:
              handleLoadedResponse<List<GetBadgesModel>>(right.data),
        ),
      ),
    );
  }

  Future<void> _getRoomsEvent(
    RoomEvent event,
    Emitter<GetBadgesStates> emit,
  ) async {
    if (event.isLoading == false) {
      emit(state.copyWith(roomBadgeRequest: RequestState.loading));
    }

    final result = await getBadgesUseCase.call('2');
    result.fold(
      (left) => emit(
        state.copyWith(
          roomBadgeRequest: RequestState.error,
          roomBadgeMessage: NetworkExceptions.getErrorMessage(left),
        ),
      ),
      (right) => emit(
        state.copyWith(
          roomBadge: _firstLevels(right.data),
          roomBadgeRequest: RequestState.loaded,
        ),
      ),
    );
  }

  Future<void> _getGiftsEvent(
    GiftEvent event,
    Emitter<GetBadgesStates> emit,
  ) async {
    if (event.isLoading == false) {
      emit(state.copyWith(giftBadgeRequest: RequestState.loading));
    }

    final result = await getBadgesUseCase.call('3');
    result.fold(
      (left) => emit(
        state.copyWith(
          giftBadgeRequest: handleErrorResponse(left),
          giftBadgeMessage: NetworkExceptions.getErrorMessage(left),
        ),
      ),
      (right) => emit(
        state.copyWith(
          giftBadge: _firstLevels(right.data),
          giftBadgeRequest: handleLoadedResponse<List<AchievementLevelEntity>>(
              _firstLevels(right.data)),
        ),
      ),
    );
  }

  Future<void> changeAppBarUI(
      ChangeAppBarUIMedalsEvent event, Emitter<GetBadgesStates> emit) async {
    emit(state.copyWith(tabBarIndex: event.index));
  }

  Future<void> changeMyMedalsAppBarUI(
      ChangeMyMedalsAppBarUIEvent event, Emitter<GetBadgesStates> emit) async {
    emit(state.copyWith(myMedalsTabBarIndex: event.index));
  }

  Future<void> selectedAcheivement(
      SelectedAcheivementEvent event, Emitter<GetBadgesStates> emit) async {
    if (event.type == 'Room') {
      emit(state.copyWith(selectedBadgeRoom: event.index));
    } else if (event.type == 'Activity') {
      emit(state.copyWith(selectedBadgeActivity: event.index));
    } else {
      emit(state.copyWith(selectedBadgeAchieve: event.index));
    }
  }
}
