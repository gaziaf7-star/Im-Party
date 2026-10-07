import 'package:general/src/features/games/games.dart';

part 'action_event.dart';
part 'action_state.dart';

class ActionBloc extends Bloc<ActionEvent, ActionState> {
  final IgnoreUserUC _ignoreUC;
  final LikeUserUC _likeUserUC;

  ActionBloc(
    this._ignoreUC,
    this._likeUserUC,
  ) : super(const ActionState()) {
    on<IgnoreUserEvent>(_ignoreEvent);
    on<LikeUserEvent>(_likeEvent);
  }

  Future<void> _ignoreEvent(
    IgnoreUserEvent event,
    Emitter<ActionState> emit,
  ) async {
    emit(state.copyWith(reqStateIgnore: RequestState.loading));
    final result = await _ignoreUC(event.userId);
    result.fold(
      (left) => emit(
        state.copyWith(reqStateIgnore: RequestState.error),
      ),
      (right) => emit(
        state.copyWith(reqStateIgnore: RequestState.loaded),
      ),
    );
  }

  Future<void> _likeEvent(
    LikeUserEvent event,
    Emitter<ActionState> emit,
  ) async {
    emit(state.copyWith(reqStateLike: RequestState.loading));
    final result = await _likeUserUC(event.userId);
    result.fold(
      (left) => emit(
        state.copyWith(reqStateLike: RequestState.error),
      ),
      (right) {
        final List<UserProfileEntity> users =
            List<UserProfileEntity>.from(di<ExploreBloc>().state.users);
        final int index = users
            .indexWhere((element) => element.id == int.parse(event.userId));
        users[index] = users[index].copyWith(isLiked: true);
        di<ExploreBloc>().add(UpdateUsersEvent(users: users));
        emit(state.copyWith(reqStateLike: RequestState.loaded));
      },
    );
  }
}
