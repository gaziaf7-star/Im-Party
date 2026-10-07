import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/data/model/badges_model.dart';
import 'package:general/src/features/profile/domain/profile_use_case/get_user_badge_uc.dart';

part 'user_badges_event.dart';
part 'user_badges_state.dart';

class UserBadgesBloc extends Bloc<UserBadgesEvent, UserBadgesState> {
  final GetUserBadgeUc getUserBadgeUc;

  UserBadgesBloc({required this.getUserBadgeUc})
      : super(const UserBadgesState()) {
    on<GetUserBadges>(
      (event, emit) async {
        // Idempotent per target user: if we already loaded badges for this exact
        // userId, skip the duplicate network fetch caused by rebuilds/listeners.
        // Always refetch when not loaded yet or when viewing a different user.
        if (state.userStates == RequestState.loaded &&
            state.lastUserId == event.id) {
          return;
        }
        // Backend rejects /badges/users/0 with 400 (the network error then
        // surfaces as a noisy non-fatal crash). Skip the request for invalid ids.
        if ((int.tryParse(event.id) ?? 0) <= 0) {
          emit(state.copyWith(
            userBadge: const [],
            userStates: RequestState.loaded,
            lastUserId: event.id,
          ));
          return;
        }
        final result = await getUserBadgeUc(event.id);
        result.fold(
          (failure) => emit(
            state.copyWith(
              userBadgeMessage: NetworkExceptions.getErrorMessage(failure),
              userStates: RequestState.error,
            ),
          ),
          (success) {
            emit(
              state.copyWith(
                userBadge: success.data ?? [],
                userStates: RequestState.loaded,
                lastUserId: event.id,
              ),
            );
          },
        );
      },
    );

    on<GetMyBadges>(
      (event, emit) async {
        final result = await getUserBadgeUc(
          MyDataModel.getInstance().id.toString(),
        );
        result.fold(
          (failure) => emit(
            state.copyWith(
              myBadgeMessage: NetworkExceptions.getErrorMessage(failure),
              myStates: RequestState.error,
            ),
          ),
          (success) {
            emit(
              state.copyWith(
                myBadge: success.data ?? [],
                myStates: RequestState.loaded,
              ),
            );
          },
        );
      },
    );

    on<InitialUserBadges>(
      (event, emit) async {
        emit(state.copyWith(userStates: RequestState.idle));
      },
    );
  }
}
