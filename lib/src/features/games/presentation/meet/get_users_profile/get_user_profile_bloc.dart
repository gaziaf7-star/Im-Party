import 'package:general/src/features/games/data/model/profile_user_model.dart';
import 'package:general/src/features/games/domain/use_cases/fetch_users_uc.dart';

import '../../../../../core/index.dart';

part 'get_user_profile_event.dart';
part 'get_user_profile_states.dart';

class GetUserProfilesBloc
    extends Bloc<BaseGetUserProfileEvent, GetUserProfilesState> {
  final FetchUsersUC getAllProfileUsersUseCase;

  GetUserProfilesBloc({required this.getAllProfileUsersUseCase})
      : super( GetUserProfilesState(
    scrollController: ScrollController(),
  )) {
    on<GetUserProfileEvent>(_getUserProfileEvent);
    on<AddListenerUsersProfileEvent>(_addListenerEvent);
    on<RemoveListenerUsersProfileEvent>(_removeListenerEvent);

  }

  Future<void> _getUserProfileEvent(
      GetUserProfileEvent event,
      Emitter<GetUserProfilesState> emit,
      ) async {
    if (event.isFirstLoading == true) {
      emit(state.copyWith(reqState: RequestState.loading));
    }
    if(event.page == '1'){
      emit(state.copyWith(currentPage: 1));
    }
    final result = await getAllProfileUsersUseCase.call(state.currentPage);
    result.fold(
          (l) => emit(
        state.copyWith(
            reqState: RequestState.error,
            message: NetworkExceptions.getErrorMessage(l)),
      ),
          (r) {
        emit(state.copyWith(
          lastPage: r.paginates?.lastPage,
          reqState: handleLoadedResponse<List<UserProfileModel>>(r.data),
          userProfileModel: handlePaginationResponse<UserProfileModel>(
            result: r.data,
            currentList: state.userProfileModel,
            currentPage: state.currentPage,
          ),
        ));
      },
    );
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
          const GetUserProfileEvent(
            isFirstLoading: false,
          ),
        );
      },
    );
  }



  void _addListenerEvent(
      AddListenerUsersProfileEvent event,
      Emitter<GetUserProfilesState> emit,
      ) {
    final scrollController = state.scrollController
      ..addListener(() => _listener());
    emit(state.copyWith(scrollController: scrollController));
  }

  void _removeListenerEvent(
      RemoveListenerUsersProfileEvent event,
      Emitter<GetUserProfilesState> emit,
      ) {
    final scrollController = state.scrollController
      ..removeListener(() => _listener());
    emit(state.copyWith(scrollController: scrollController));
  }
}
