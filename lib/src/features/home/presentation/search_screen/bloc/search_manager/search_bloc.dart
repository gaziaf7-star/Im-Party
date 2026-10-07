import 'dart:async';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/home/data/model/search_model.dart';
import 'package:general/src/features/home/domain/entities/room_entity.dart';
import 'package:general/src/features/home/domain/entities/search_entity.dart';
import 'package:general/src/features/home/domain/home_use_case/search_use_case.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_events.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_states.dart';

class SearchBloc extends Bloc<SearchEvents, SearchStates> {
  final SearchUseCase searchUseCase;

  // Latest query per cursor so a stale paginated response can't append to a
  // newer keyword's results.
  String _latestSearchQuery = '';
  String _latestFriendsQuery = '';

  SearchBloc({
    required this.searchUseCase,
  }) : super(SearchStates(searchController: TextEditingController())) {
    on<SearchEvent>(search);
    on<UserSelectedEvent>(userSelect);
    on<SearchFriendsEvent>(friendsSearch);
    on<SearchAddListenerEvent>(_addListeners);
    on<SearchRemoveListenerEvent>(_removeListeners);
    on<FriendsSearchAddListenerEvent>(_addFriendsListener);
    on<FriendsSearchRemoveListenerEvent>(_removeFriendsListener);
    on<ChangeCurrentIndexEvent>(_changeCurrentIndexEvent);
  }

  FutureOr<void> search(SearchEvent event, Emitter<SearchStates> emit) async {
    if (event.keyWord == '') {
      _latestSearchQuery = '';
      emit(state.copyWith(
          data: SearchModel(
              users: const [],
              rooms: const [],
              numberOfFriends: state.data?.numberOfFriends ?? 0),
          searchCurrentPage: 1,
          searchLastPage: -1,
          isPaginatingSearch: false,
          reqState: RequestState.idle));
      return;
    }

    final bool isFirstPage = !event.isLoadMore;
    if (isFirstPage) {
      _latestSearchQuery = event.keyWord;
    }
    final String query = isFirstPage ? event.keyWord : _latestSearchQuery;

    if (isFirstPage) {
      if (event.loading ?? true) {
        emit(state.copyWith(reqState: RequestState.loading));
      }
      emit(state.copyWith(searchCurrentPage: 1, isPaginatingSearch: false));
    } else {
      if (state.isPaginatingSearch) return;
      emit(state.copyWith(
        isPaginatingSearch: true,
        searchCurrentPage: state.searchCurrentPage + 1,
      ));
    }

    final int currentPage = state.searchCurrentPage;
    final result = await searchUseCase(SearchParameter(
        keyWord: query, isFriend: event.isFriend, page: '$currentPage'));

    if (_latestSearchQuery != query) return;

    result.fold(
      (l) => emit(state.copyWith(
          errorMsg: NetworkExceptions.getErrorMessage(l),
          isPaginatingSearch: false,
          reqState: RequestState.error)),
      (r) {
        final merged = SearchModel(
          users: handlePaginationResponse<UserEntity>(
            result: r.data?.users,
            currentList: state.data?.users ?? const [],
            currentPage: currentPage,
          ),
          rooms: handlePaginationResponse<RoomEntity>(
            result: r.data?.rooms,
            currentList: state.data?.rooms ?? const [],
            currentPage: currentPage,
          ),
          numberOfFriends:
              r.data?.numberOfFriends ?? state.data?.numberOfFriends ?? 0,
        );
        emit(state.copyWith(
          data: merged,
          searchLastPage: r.paginates?.lastPage ?? state.searchLastPage,
          isPaginatingSearch: false,
          reqState: handleLoadedResponse<List<UserEntity>>(merged.users),
        ));
      },
    );
  }

  void _changeCurrentIndexEvent(
    ChangeCurrentIndexEvent event,
    Emitter<SearchStates> emit,
  ) =>
      emit(state.copyWith(currentIndex: event.currentIndex));

  FutureOr<void> friendsSearch(
      SearchFriendsEvent event, Emitter<SearchStates> emit) async {
    if (event.keyWord.isEmpty) {
      _latestFriendsQuery = '';
      emit(state.copyWith(
        friendsList: null,
        friendsCurrentPage: 1,
        friendsLastPage: -1,
        isPaginatingFriends: false,
        reqStateFriends: RequestState.empty,
      ));
      return;
    }

    final bool isFirstPage = !event.isLoadMore;
    if (isFirstPage) {
      _latestFriendsQuery = event.keyWord;
    }
    final String query = isFirstPage ? event.keyWord : _latestFriendsQuery;

    if (isFirstPage) {
      emit(state.copyWith(
        reqStateFriends: RequestState.loading,
        friendsCurrentPage: 1,
        isPaginatingFriends: false,
      ));
    } else {
      if (state.isPaginatingFriends) return;
      emit(state.copyWith(
        isPaginatingFriends: true,
        friendsCurrentPage: state.friendsCurrentPage + 1,
      ));
    }

    final int currentPage = state.friendsCurrentPage;
    final result = await searchUseCase(SearchParameter(
        keyWord: query, isFriend: true, page: '$currentPage'));

    if (_latestFriendsQuery != query) return;

    result.fold(
      (l) => emit(state.copyWith(
          errorMsgFriends: NetworkExceptions.getErrorMessage(l),
          isPaginatingFriends: false,
          reqStateFriends: RequestState.error)),
      (r) {
        final mergedUsers = handlePaginationResponse<UserEntity>(
          result: r.data?.users,
          currentList: state.friendsList?.users ?? const [],
          currentPage: currentPage,
        );
        final merged = SearchModel(
          users: mergedUsers,
          rooms: r.data?.rooms,
          numberOfFriends: r.data?.numberOfFriends ??
              state.friendsList?.numberOfFriends ??
              0,
        );
        emit(state.copyWith(
          friendsList: merged,
          friendsLastPage: r.paginates?.lastPage ?? state.friendsLastPage,
          isPaginatingFriends: false,
          reqStateFriends: handleLoadedResponse<List<UserEntity>>(mergedUsers),
        ));
      },
    );
  }

  // [Pagination] general search listeners (users + rooms share the cursor).
  void _addListeners(
    SearchAddListenerEvent event,
    Emitter<SearchStates> emit,
  ) {
    state.usersScrollCtrl.addListener(_listenerSearch);
    state.roomsScrollCtrl.addListener(_listenerSearch);
  }

  void _removeListeners(
    SearchRemoveListenerEvent event,
    Emitter<SearchStates> emit,
  ) {
    state.usersScrollCtrl.removeListener(_listenerSearch);
    state.roomsScrollCtrl.removeListener(_listenerSearch);
  }

  void _listenerSearch() {
    handleScrollListener(
      controller:
          state.currentIndex == 0 ? state.usersScrollCtrl : state.roomsScrollCtrl,
      currentPage: state.searchCurrentPage,
      lastPage: state.searchLastPage,
      fun: () {
        add(SearchEvent(
          keyWord: _latestSearchQuery,
          isLoadMore: true,
          loading: false,
        ));
      },
    );
  }

  // [Pagination] friends search listener.
  void _addFriendsListener(
    FriendsSearchAddListenerEvent event,
    Emitter<SearchStates> emit,
  ) {
    state.friendsScrollCtrl.addListener(_listenerFriendsSearch);
  }

  void _removeFriendsListener(
    FriendsSearchRemoveListenerEvent event,
    Emitter<SearchStates> emit,
  ) {
    state.friendsScrollCtrl.removeListener(_listenerFriendsSearch);
  }

  void _listenerFriendsSearch() {
    handleScrollListener(
      controller: state.friendsScrollCtrl,
      currentPage: state.friendsCurrentPage,
      lastPage: state.friendsLastPage,
      fun: () {
        add(SearchFriendsEvent(
          keyWord: _latestFriendsQuery,
          isLoadMore: true,
        ));
      },
    );
  }

  FutureOr<void> userSelect(
      UserSelectedEvent event, Emitter<SearchStates> emit) {
    emit(state.copyWith(selectedUserId: event.userId));
  }

  void clear() {
    state.searchController.clear();
    state.selectedUserId = '';
    state.data?.users.clear();
    state.searchController.text = '';
  }
}
