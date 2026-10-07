import 'package:general/src/features/games/domain/entities/online_user_entity.dart';
import 'package:general/src/features/games/domain/use_cases/fetch_online_users_uc.dart';

import '../../../../../../core/index.dart';

part 'online_users_event.dart';
part 'online_users_states.dart';

class OnlineUsersBloc extends Bloc<BaseOnlineUsersEvent, OnlineUsersStates> {
  final FetchOnlineUsersUc _fetchOnlineUsersUc;

  OnlineUsersBloc(this._fetchOnlineUsersUc)
      : super(OnlineUsersStates(
          scrollController: ScrollController(),
        )) {
    on<GetUsersOnlineEvent>(_getUsersOnlineEvent);
    on<ChangeUserOnlineLocally>(_changeUserOnlineLocally);
    on<AddListenerOnlineUsersEvent>(_addListenerEvent);
    on<RemoveListenerOnlineUsersEvent>(_removeListenerEvent);
    // on<GetUsersOnlineEvent>(
    //   (event, emit) async {
    //     if (event.isFirstLoading == true) {
    //       emit(state.copyWith(reqState: RequestState.loading));
    //     }
    //     final result = await _fetchOnlineUsersUc.call(state.currentPage.toString());
    //     result.fold(
    //       (left) => emit(
    //         state.copyWith(
    //           reqState: handleErrorResponse(left),
    //           message: NetworkExceptions.getErrorMessage(left),
    //         ),
    //       ),
    //       (success) => emit(
    //         state.copyWith(
    //           users: success.data,
    //           reqState:
    //               handleLoadedResponse<List<UsersOnlineEntity>>(success.data),
    //         ),
    //       ),
    //     );
    //   },
    // );
  }

  Future<void> _getUsersOnlineEvent(
    GetUsersOnlineEvent event,
    Emitter<OnlineUsersStates> emit,
  ) async {
    if (event.isFirstLoading == true) {
      emit(state.copyWith(reqState: RequestState.loading));
    }
    final result = await _fetchOnlineUsersUc.call(state.currentPage.toString());
    result.fold(
      (l) => emit(
        state.copyWith(
            reqState: RequestState.error,
            message: NetworkExceptions.getErrorMessage(l)),
      ),
      (r) {
        emit(state.copyWith(
          lastPage: r.paginates?.lastPage,
          reqState: handleLoadedResponse<List<UsersOnlineEntity>>(r.data),
          users: handlePaginationResponse<UsersOnlineEntity>(
            result: r.data,
            currentList: state.users,
            currentPage: state.currentPage,
          ),
        ));
      },
    );
  }

  Future<void> _changeUserOnlineLocally(
    ChangeUserOnlineLocally event,
    Emitter<OnlineUsersStates> emit,
  ) async {
  final updatedUsers = List<UsersOnlineEntity>.from(state.users);

  updatedUsers[event.index] = updatedUsers[event.index].copyWith(
    isFollow: !(updatedUsers[event.index].isFollow ?? false),
  );

  emit(state.copyWith(users: updatedUsers)); 
  }

  void _listener() {
    handleScrollListener(
      controller: state.scrollController,
      currentPage: state.currentPage,
      lastPage: state.lastPage,
      fun: () {
        final int currentPage = state.currentPage + 1;
        emit(state.copyWith(currentPage: currentPage));
        add(
          const GetUsersOnlineEvent(
            isFirstLoading: false,
          ),
        );
      },
    );
  }

  void _addListenerEvent(
    AddListenerOnlineUsersEvent event,
    Emitter<OnlineUsersStates> emit,
  ) {
    final scrollController = state.scrollController
      ..addListener(() => _listener());
    emit(state.copyWith(scrollController: scrollController));
  }

  void _removeListenerEvent(
    RemoveListenerOnlineUsersEvent event,
    Emitter<OnlineUsersStates> emit,
  ) {
    final scrollController = state.scrollController
      ..removeListener(() => _listener());
    emit(state.copyWith(scrollController: scrollController));
  }
}
