import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/domain/entities/host_level_entity.dart';
import 'package:general/src/features/home/domain/use_cases/fetch_host_levels_uc.dart';
import 'package:general/src/features/home/domain/use_cases/fetch_live_rooms_uc.dart';
import 'package:general/src/features/home/domain/use_cases/pick_box_uc.dart';
import 'package:general/src/features/home/home.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FetchRoomsUC _fetchRoomsUC;
  final FetchLiveRoomsUC _fetchLiveRoomsUC;
  final FetchHostLevelsUc _fetchHostLevelsUc;
  final PickBoxUC _pickBoxUC;

  HomeBloc(
    this._fetchRoomsUC,
    this._fetchLiveRoomsUC,
    this._fetchHostLevelsUc,
    this._pickBoxUC,
  ) : super(
          HomeState(
            popularScrollCtrl: ScrollController(),
            globalScrollCtrl: ScrollController(),
            followScrollCtrl: ScrollController(),
            friendsScrollCtrl: ScrollController(),
            filterScrollCtrl: ScrollController(),
            lastCreateScrollCtrl: ScrollController(),
            streamScrollCtrl: ScrollController(),
          ),
        ) {
    on<ChangeCurrentIndexEvent>(_changeCurrentIndexEvent);
    // [Hot]
    on<FetchPopularRoomsEvent>(_fetchPopularRoomsEvent);
    on<FilterPopularRoomsEvent>(_filterPopularRoomsEvent);
    on<FetchGlobalRoomsEvent>(_fetchGlobalRoomsEvent);
    on<FetchFollowRoomsEvent>(_fetchFollowRoomsEvent);
    on<FetchFriendsRoomsEvent>(_fetchFriendsRoomsEvent);
    on<FetchLastCreateRoomsEvent>(_fetchLastCreateRoomsEvent);
    on<FetchLiveRoomsEvent>(_fetchLiveRoomsEvent);

    on<PopularAddListenerEvent>(_popularAddListenerEvent);
    on<GlobalAddListenerEvent>(_globalAddListenerEvent);
    on<FollowAddListenerEvent>(_followAddListenerEvent);
    on<FriendsAddListenerEvent>(_friendsAddListenerEvent);
    on<FilterAddListenerEvent>(_filterAddListenerEvent);
    on<LastCreateLAddListenerEvent>(_lastCreateAddListenerEvent);
    on<LiveAddListenerEvent>(_liveAddListenerEvent);

    on<PopularRemoveListenerEvent>(_popularRemoveListenerEvent);
    on<GlobalRemoveListenerEvent>(_globalRemoveListenerEvent);
    on<FollowRemoveListenerEvent>(_followRemoveListenerEvent);
    on<FriendsRemoveListenerEvent>(_friendsRemoveListenerEvent);
    on<FilterRemoveListenerEvent>(_filterRemoveListenerEvent);
    on<LastCreateRemoveListenerEvent>(_lastCreateRemoveListenerEvent);
    on<LiveRemoveListenerEvent>(_liveRemoveListenerEvent);
    on<FetchHostLevelsEvent>(_fetchHostLevelsEvent);
    on<PickBoxEvent>(_pickBoxEvent);
  }

  void _changeCurrentIndexEvent(
    ChangeCurrentIndexEvent event,
    Emitter<HomeState> emit,
  ) =>
      emit(state.copyWith(currentIndex: event.currentIndex));

  // [Live]
  Future<void> _fetchLiveRoomsEvent(
    FetchLiveRoomsEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (event.isLiveLoading == true) {
      emit(state.copyWith(reqStateLive: RequestState.loading));
    } else if (state.stream.isNotEmpty) {
      if (state.isPaginatingLive) return;
      emit(state.copyWith(
        isPaginatingLive: true,
        liveCurrentPage: state.liveCurrentPage + 1,
      ));
    }

    if (event.isFirstPage == true) {
      emit(state.copyWith(liveCurrentPage: 1, isPaginatingLive: false));
    }

    final result = await _fetchLiveRoomsUC(
      RoomsParameterUC(
        currentPage: state.liveCurrentPage,
      ),
    );

    result.fold(
      (left) => emit(
        state.copyWith(
          reqStateLive: handleErrorResponse(left),
          isPaginatingLive: false,
        ),
      ),
      (right) async {
        emit(
          state.copyWith(
            reqStateLive: handleLoadedResponse<List<RoomEntity>>(right.data),
            streamLastPage: right.paginates?.lastPage,
            isPaginatingLive: false,
            stream: handlePaginationResponse<RoomEntity>(
              result: right.data,
              currentList: state.stream,
              currentPage: state.liveCurrentPage,
            ),
          ),
        );
      },
    );
  }

  // [Popular]
  Future<void> _fetchPopularRoomsEvent(
    FetchPopularRoomsEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (event.isPopularLoading == true) {
      emit(state.copyWith(reqStatePopular: RequestState.loading));
    } else if (state.popular.isNotEmpty) {
      if (state.isPaginatingPopular) return;
      emit(state.copyWith(
        isPaginatingPopular: true,
        popularCurrentPage: state.popularCurrentPage + 1,
      ));
    }

    if (event.isFirstPage == true) {
      emit(state.copyWith(popularCurrentPage: 1, isPaginatingPopular: false));
    }
    final result = await _fetchRoomsUC(
      RoomsParameterUC(
        type: TypeGetRooms.popular,
        countryId: event.countryId,
        currentPage: state.popularCurrentPage,
      ),
    );
    result.fold(
      (left) => emit(state.copyWith(
        reqStatePopular: handleErrorResponse(left),
        isPaginatingPopular: false,
      )),
      (right) {
        final newPopular = handlePaginationResponse<RoomEntity>(
          result: right.data,
          currentList: state.popular,
          currentPage: state.popularCurrentPage,
        );
        emit(
          state.copyWith(
            reqStatePopular: handleLoadedResponse<List<RoomEntity>>(right.data),
            popularLastPage: right.paginates?.lastPage,
            isPaginatingPopular: false,
            popular: newPopular,
            popularPK: newPopular.where((room) => room.isPK == true).toList(),
          ),
        );
      },
    );
  }

  Future<void> _filterPopularRoomsEvent(
    FilterPopularRoomsEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (event.isLoading != false) {
      emit(state.copyWith(reqStateFilter: RequestState.loading));
    } else if (state.filteredRooms.isNotEmpty) {
      if (state.isPaginatingFilter) return;
      emit(state.copyWith(
        isPaginatingFilter: true,
        filterCurrentPage: state.filterCurrentPage + 1,
      ));
    }
    if (event.isFirstPage == true) {
      emit(state.copyWith(filterCurrentPage: 1, isPaginatingFilter: false));
    }
    // 0 is the "all countries"/recommended sentinel (real country ids start at
    // 101), so a null countryId clears the filter back to recommended.
    emit(state.copyWith(filterCountryId: event.countryId ?? 0));

    final result = await _fetchRoomsUC(
      RoomsParameterUC(
        type: TypeGetRooms.popular,
        countryId: event.countryId,
        currentPage: state.filterCurrentPage,
      ),
    );
    result.fold(
      (left) => emit(state.copyWith(
        reqStateFilter: handleErrorResponse(left),
        isPaginatingFilter: false,
      )),
      (right) {
        emit(
          state.copyWith(
            reqStateFilter: handleLoadedResponse<List<RoomEntity>>(right.data),
            filterLastPage: right.paginates?.lastPage,
            isPaginatingFilter: false,
            filteredRooms: handlePaginationResponse<RoomEntity>(
              result: right.data,
              currentList: state.filteredRooms,
              currentPage: state.filterCurrentPage,
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchGlobalRoomsEvent(
    FetchGlobalRoomsEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (event.isGlobalLoading == true) {
      emit(state.copyWith(reqStateGlobal: RequestState.loading));
    } else if (state.global.isNotEmpty) {
      if (state.isPaginatingGlobal) return;
      emit(state.copyWith(
        isPaginatingGlobal: true,
        globalCurrentPage: state.globalCurrentPage + 1,
      ));
    }

    if (event.isFirstPage == true) {
      emit(state.copyWith(globalCurrentPage: 1, isPaginatingGlobal: false));
    }
    final result = await _fetchRoomsUC(
      RoomsParameterUC(
        type: TypeGetRooms.global,
        countryId: event.globalCountryId,
        currentPage: state.globalCurrentPage,
      ),
    );
    result.fold(
      (left) => emit(state.copyWith(
        reqStateGlobal: handleErrorResponse(left),
        countryId: event.globalCountryId,
        isPaginatingGlobal: false,
      )),
      (right) {
        emit(
          state.copyWith(
            reqStateGlobal: handleLoadedResponse<List<RoomEntity>>(right.data),
            globalLastPage: right.paginates?.lastPage,
            countryId: event.globalCountryId,
            isPaginatingGlobal: false,
            global: handlePaginationResponse<RoomEntity>(
              result: right.data,
              currentList: state.global,
              currentPage: state.globalCurrentPage,
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchFollowRoomsEvent(
    FetchFollowRoomsEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (event.isFollowLoading == true) {
      emit(state.copyWith(reqStateFollow: RequestState.loading));
    } else if (state.follow.isNotEmpty) {
      if (state.isPaginatingFollow) return;
      emit(state.copyWith(
        isPaginatingFollow: true,
        followCurrentPage: state.followCurrentPage + 1,
      ));
    }
    if (event.isFirstPage == true) {
      emit(state.copyWith(followCurrentPage: 1, isPaginatingFollow: false));
    }
    final result = await _fetchRoomsUC(
      RoomsParameterUC(
        type: TypeGetRooms.following,
        currentPage: state.followCurrentPage,
      ),
    );
    result.fold(
      (left) => emit(state.copyWith(
        reqStateFollow: handleErrorResponse(left),
        isPaginatingFollow: false,
      )),
      (right) => emit(
        state.copyWith(
          reqStateFollow: handleLoadedResponse<List<RoomEntity>>(right.data),
          followLastPage: right.paginates?.lastPage,
          isPaginatingFollow: false,
          follow: handlePaginationResponse<RoomEntity>(
            result: right.data,
            currentList: state.follow,
            currentPage: state.followCurrentPage,
          ),
        ),
      ),
    );
  }

  Future<void> _fetchLastCreateRoomsEvent(
    FetchLastCreateRoomsEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (event.isLastCreateLoading == true) {
      emit(state.copyWith(reqStateLastCreate: RequestState.loading));
    } else if (state.lastCreate.isNotEmpty) {
      if (state.isPaginatingLastCreate) return;
      emit(state.copyWith(
        isPaginatingLastCreate: true,
        lastCreateCurrentPage: state.lastCreateCurrentPage + 1,
      ));
    }
    final result = await _fetchRoomsUC(
      RoomsParameterUC(
        type: TypeGetRooms.lastCreate,
        currentPage: state.lastCreateCurrentPage,
      ),
    );
    result.fold(
      (left) => emit(state.copyWith(
        reqStateLastCreate: handleErrorResponse(left),
        isPaginatingLastCreate: false,
      )),
      (right) => emit(
        state.copyWith(
          reqStateLastCreate:
              handleLoadedResponse<List<RoomEntity>>(right.data),
          lastCreateLastPage: right.paginates?.lastPage,
          isPaginatingLastCreate: false,
          lastCreate: handlePaginationResponse<RoomEntity>(
            result: right.data,
            currentList: state.lastCreate,
            currentPage: state.lastCreateCurrentPage,
          ),
        ),
      ),
    );
  }

  // [Friends]
  Future<void> _fetchFriendsRoomsEvent(
    FetchFriendsRoomsEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (event.isFriendsLoading == true) {
      emit(state.copyWith(reqStateFriends: RequestState.loading));
    } else if (state.friends.isNotEmpty) {
      if (state.isPaginatingFriends) return;
      emit(state.copyWith(
        isPaginatingFriends: true,
        friendsCurrentPage: state.friendsCurrentPage + 1,
      ));
    }
    if (event.isFirstPage == true) {
      emit(state.copyWith(friendsCurrentPage: 1, isPaginatingFriends: false));
    }
    final result = await _fetchRoomsUC(
      RoomsParameterUC(
        type: TypeGetRooms.friends,
        currentPage: state.friendsCurrentPage,
      ),
    );
    result.fold(
      (left) => emit(state.copyWith(
        reqStateFriends: handleErrorResponse(left),
        isPaginatingFriends: false,
      )),
      (right) {
        emit(
          state.copyWith(
            reqStateFriends: handleLoadedResponse<List<RoomEntity>>(right.data),
            friendsLastPage: right.paginates?.lastPage,
            isPaginatingFriends: false,
            friends: handlePaginationResponse<RoomEntity>(
              result: right.data,
              currentList: state.friends,
              currentPage: state.friendsCurrentPage,
            ),
          ),
        );
      },
    );
  }

  void _listenerPopularRooms() {
    handleScrollListener(
      controller: state.popularScrollCtrl,
      currentPage: state.popularCurrentPage,
      lastPage: state.popularLastPage,
      fun: () {
        add(const FetchPopularRoomsEvent(isPopularLoading: false));
      },
    );
  }

  void _listenerFriendsRooms() {
    handleScrollListener(
      controller: state.friendsScrollCtrl,
      currentPage: state.friendsCurrentPage,
      lastPage: state.friendsLastPage,
      fun: () {
        add(const FetchFriendsRoomsEvent(isFriendsLoading: false));
      },
    );
  }

  void _listenerFilterRooms() {
    handleScrollListener(
      controller: state.filterScrollCtrl,
      currentPage: state.filterCurrentPage,
      lastPage: state.filterLastPage,
      fun: () {
        add(FilterPopularRoomsEvent(
          // 0 sentinel -> null so pagination keeps the all-countries filter.
          countryId: state.filterCountryId == 0 ? null : state.filterCountryId,
          isLoading: false,
        ));
      },
    );
  }

  void _listenerLastCreateRooms() {
    handleScrollListener(
      controller: state.lastCreateScrollCtrl,
      currentPage: state.lastCreateCurrentPage,
      lastPage: state.lastCreateLastPage,
      fun: () {
        add(const FetchLastCreateRoomsEvent());
      },
    );
  }

  void _listenerGlobalRooms() {
    handleScrollListener(
      controller: state.globalScrollCtrl,
      currentPage: state.globalCurrentPage,
      lastPage: state.globalLastPage,
      fun: () {
        add(const FetchGlobalRoomsEvent(isGlobalLoading: false));
      },
    );
  }

  void _listenerFollowRooms() {
    handleScrollListener(
      controller: state.followScrollCtrl,
      currentPage: state.followCurrentPage,
      lastPage: state.followLastPage,
      fun: () {
        add(const FetchFollowRoomsEvent(isFollowLoading: false));
      },
    );
  }

  void _followAddListenerEvent(
    FollowAddListenerEvent event,
    Emitter<HomeState> emit,
  ) {
    final followScrollCtrl = state.followScrollCtrl
      ..addListener(_listenerFollowRooms);
    emit(state.copyWith(followScrollCtrl: followScrollCtrl));
  }

  void _friendsAddListenerEvent(
    FriendsAddListenerEvent event,
    Emitter<HomeState> emit,
  ) {
    final friendsScrollCtrl = state.friendsScrollCtrl
      ..addListener(_listenerFriendsRooms);
    emit(state.copyWith(friendsScrollCtrl: friendsScrollCtrl));
  }

  void _filterAddListenerEvent(
    FilterAddListenerEvent event,
    Emitter<HomeState> emit,
  ) {
    final filterScrollCtrl = state.filterScrollCtrl
      ..addListener(_listenerFilterRooms);
    emit(state.copyWith(filterScrollCtrl: filterScrollCtrl));
  }

  void _lastCreateAddListenerEvent(
    LastCreateLAddListenerEvent event,
    Emitter<HomeState> emit,
  ) {
    final lastCreateScrollCtrl = state.lastCreateScrollCtrl
      ..addListener(_listenerLastCreateRooms);
    emit(state.copyWith(lastCreateScrollCtrl: lastCreateScrollCtrl));
  }

  void _popularAddListenerEvent(
    PopularAddListenerEvent event,
    Emitter<HomeState> emit,
  ) {
    final hotScrollCtrl = state.popularScrollCtrl
      ..addListener(_listenerPopularRooms);
    emit(state.copyWith(popularScrollCtrl: hotScrollCtrl));
  }

  void _globalAddListenerEvent(
    GlobalAddListenerEvent event,
    Emitter<HomeState> emit,
  ) {
    final pkScrollCtrl = state.globalScrollCtrl
      ..addListener(_listenerGlobalRooms);
    emit(state.copyWith(globalScrollCtrl: pkScrollCtrl));
  }

  void _globalRemoveListenerEvent(
    GlobalRemoveListenerEvent event,
    Emitter<HomeState> emit,
  ) {
    final hotScrollCtrl = state.globalScrollCtrl
      ..removeListener(_listenerGlobalRooms);
    emit(state.copyWith(globalScrollCtrl: hotScrollCtrl));
  }

  void _friendsRemoveListenerEvent(
    FriendsRemoveListenerEvent event,
    Emitter<HomeState> emit,
  ) {
    final friendsScrollCtrl = state.friendsScrollCtrl
      ..removeListener(_listenerFriendsRooms);
    emit(state.copyWith(friendsScrollCtrl: friendsScrollCtrl));
  }

  void _filterRemoveListenerEvent(
    FilterRemoveListenerEvent event,
    Emitter<HomeState> emit,
  ) {
    final filterScrollCtrl = state.filterScrollCtrl
      ..removeListener(_listenerFilterRooms);
    emit(
      state.copyWith(
        filterScrollCtrl: filterScrollCtrl,
        filterCountryId: 0,
        filterCurrentPage: 1,
        filteredRooms: [],
        filterLastPage: -1,
      ),
    );
  }

  void _lastCreateRemoveListenerEvent(
    LastCreateRemoveListenerEvent event,
    Emitter<HomeState> emit,
  ) {
    final lastCreateScrollCtrl = state.lastCreateScrollCtrl
      ..removeListener(_listenerLastCreateRooms);
    emit(state.copyWith(lastCreateScrollCtrl: lastCreateScrollCtrl));
  }

  void _popularRemoveListenerEvent(
    PopularRemoveListenerEvent event,
    Emitter<HomeState> emit,
  ) {
    final pkScrollCtrl = state.popularScrollCtrl
      ..removeListener(_listenerPopularRooms);
    emit(state.copyWith(popularScrollCtrl: pkScrollCtrl));
  }

  void _followRemoveListenerEvent(
    FollowRemoveListenerEvent event,
    Emitter<HomeState> emit,
  ) {
    final followScrollCtrl = state.followScrollCtrl
      ..removeListener(_listenerFollowRooms);
    emit(state.copyWith(followScrollCtrl: followScrollCtrl));
  }

  void _listenerLiveRooms() {
    handleScrollListener(
      controller: state.streamScrollCtrl,
      currentPage: state.liveCurrentPage,
      lastPage: state.streamLastPage,
      fun: () {
        add(const FetchLiveRoomsEvent(isLiveLoading: false));
      },
    );
  }

  void _liveAddListenerEvent(
    LiveAddListenerEvent event,
    Emitter<HomeState> emit,
  ) {
    final liveScrollCtrl = state.streamScrollCtrl
      ..addListener(_listenerLiveRooms);
    emit(state.copyWith(streamScrollCtrl: liveScrollCtrl));
  }

  void _liveRemoveListenerEvent(
    LiveRemoveListenerEvent event,
    Emitter<HomeState> emit,
  ) {
    final liveScrollCtrl = state.streamScrollCtrl
      ..removeListener(_listenerLiveRooms);
    emit(state.copyWith(streamScrollCtrl: liveScrollCtrl));
  }

  Future<void> _fetchHostLevelsEvent(
    FetchHostLevelsEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (event.isHostLevelsLoading == true) {
      emit(state.copyWith(reqStateHostLevels: RequestState.loading));
    }

    final result = await _fetchHostLevelsUc();
    result.fold(
      (left) => emit(
        state.copyWith(reqStateHostLevels: handleErrorResponse(left)),
      ),
      (right) {
        emit(
          state.copyWith(
            reqStateHostLevels:
                handleLoadedResponse<HostLevelsEntity>(right.data),
            hostLevelsEntity: right.data,
          ),
        );
        Methods.printLog(
            "Levels current stage ======> ${state.hostLevelsEntity?.user?.currentStage}");
        Methods.printLog(
            "Levels last stage ======> ${state.hostLevelsEntity?.user?.lastStage}");
        Methods.printLog(
            "Levels next stage ======> ${state.hostLevelsEntity?.user?.nextStage}");
      },
    );
  }

  Future<void> _pickBoxEvent(
    PickBoxEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(reqStatePickBox: RequestState.loading));
    final result = await _pickBoxUC(event.stageId);
    result.fold(
      (left) {
        emit(
          state.copyWith(
            reqStatePickBox: RequestState.error,
            pickBoxMsg: NetworkExceptions.getErrorMessage(left),
          ),
        );
      },
      (right) {
        add(const FetchHostLevelsEvent(isHostLevelsLoading: false));
        emit(
          state.copyWith(
            reqStatePickBox: RequestState.loaded,
            pickBoxMsg: right.message,
          ),
        );
        Methods.printLog("Pick Box ====> ${right.data}");
      },
    );
  }
}
