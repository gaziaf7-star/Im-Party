import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/domain/profile_use_case/user_badges_use_case.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_user_badges/get_user_badges_event.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_user_badges/get_user_badges_state.dart';

class GetUserBadgesBloc extends Bloc<GetUserBadgesEvent, GetUserBadgesState> {
  final UserBadgeUc userBadgeUc;

  GetUserBadgesBloc({required this.userBadgeUc})
      : super(const GetUserBadgesState()) {
    on<GetUserBadgesData>(
      (event, emit) async {
        if (state.userStates == RequestState.loaded &&
            state.lastUserId == event.id) {
          return;
        }
        final result = await userBadgeUc(event.id);
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
                userBadge: success.data,
                userStates: RequestState.loaded,
                lastUserId: event.id,
              ),
            );
          },
        );
      },
    );
  }
}
