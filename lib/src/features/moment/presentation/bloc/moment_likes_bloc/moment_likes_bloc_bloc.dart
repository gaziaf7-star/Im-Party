import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/domain/entities/moment_likes_entity.dart';

import '../../../domain/usecases/get_moment_likes_uc.dart';
import 'get_moment_likes_event.dart';
import 'moment_likes_bloc_state.dart';

import 'dart:async';

class GetMomentLikesBloc
    extends Bloc<BaseGetMomentLikesEvent, GetMomentLikesState> {
  final GetMomentLikeUseCase getMomentLikeUseCase;

  GetMomentLikesBloc({
    required this.getMomentLikeUseCase,
  }) : super(GetMomentLikesState(
          scrollControllerLikes: ScrollController(),
        )) {
    on<GetMomentLikesEvent>(getMomentLkes);
    on<AddListenerLikeEvent>(_addEventListenerLike);
    on<RemoveListenerLikeEvent>(_removeEventListenerLike);
  }

  FutureOr<void> getMomentLkes(
      GetMomentLikesEvent event, Emitter<GetMomentLikesState> emit) async {
    final int eventPage = int.tryParse(event.page) ?? 1;
    if (event.isLoading != false && event.momentId != state.currentMomentId) {
      emit(state.copyWith(reqState: RequestState.loading));
    }
    final result = await getMomentLikeUseCase.call(
        GetMomentLikePrameter(page: event.page, momentId: event.momentId));
    result.fold(
      (l) => emit(
        state.copyWith(
            reqState: handleErrorResponse(l),
            message: NetworkExceptions.getErrorMessage(l)),
      ),
      (r) {
        emit(state.copyWith(
          lastPage: r.paginates?.lastPage,
          currentPage: eventPage,
          momentLikes: handlePaginationResponse<MomentLikesEntity>(
            result: r.data,
            currentList: state.momentLikes,
            currentPage: eventPage,
          ),
          reqState:
              handleLoadedResponse<List<MomentLikesEntity>>(r.data),
        ));
        if (event.momentId != state.currentMomentId) {
          emit(state.copyWith(currentMomentId: event.momentId));
        }
      },
    );
  }

  void _addEventListenerLike(
    AddListenerLikeEvent event,
    Emitter<GetMomentLikesState> emit,
  ) {
    final scroll = state.scrollControllerLikes
      ..addListener(() {
        _listenerMoment(event.momentId);
      });
    emit(state.copyWith(scrollControllerLikes: scroll));
  }

  void _removeEventListenerLike(
    RemoveListenerLikeEvent event,
    Emitter<GetMomentLikesState> emit,
  ) {
    final scroll = state.scrollControllerLikes
      ..removeListener(() {
        _listenerMoment(event.momentId);
      });
    emit(
      state.copyWith(
        scrollControllerLikes: scroll,
        currentPage: 1,
        // currentMomentId: "",
      ),
    );
  }

  void _listenerMoment(String momentId) {
    handleScrollListener(
      controller: state.scrollControllerLikes,
      currentPage: state.currentPage,
      lastPage: state.lastPage,
      fun: () {
        final int currentPage = state.currentPage + 1;
        emit(state.copyWith(currentPage: currentPage));
        add(GetMomentLikesEvent(
          page: currentPage.toString(),
          momentId: state.currentMomentId, // momentId,
          isLoading: false,
        ));
      },
    );
  }
}

/*
class GetMomentLikesBloc
    extends Bloc<BaseGetMomentLikesEvent, GetMomentLikesState> {
  final GetMomentLikeUseCase getMomentLikeUseCase;
  int _currentPage = 1;
  GetMomentLikesBloc({required this.getMomentLikeUseCase})
      : super(const GetMomentLikeInitial()) {
    on<GetMomentLikesEvent>((event, emit) async {
      _currentPage = 1;
      emit(GetMomentLikeLoadingState(data: state.data));
      final result = await getMomentLikeUseCase.call(
        GetMomentLikePrameter(
          momentId: event.momentId,
          page: _currentPage.toString(),
        ),
      );
      result.fold(
        (left) => emit(GetMomentLikeSucssesState(data: left)),
        (right) => emit(
          GetMomentLikeErrorState(
            error: DioHelper().getTypeOfFailure(right),
          ),
        ),
      );
    });

    on<GetMoreMomentLikesEvent>(
      (event, emit) async {
        _currentPage++;
        final result = await getMomentLikeUseCase.call(
          GetMomentLikePrameter(
            momentId: event.momentId,
            page: _currentPage.toString(),
          ),
        );
        result.fold(
          (left) {
            if (left != []) {
              emit(GetMomentLikeSucssesState(data: [...state.data, ...left]));
            }
          },
          (right) => emit(
            GetMomentLikeErrorState(
              error: "error",
            ),
          ),
        );
      },
    );
  }
}
*/
