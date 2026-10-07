import 'dart:async';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/moment.dart';

class MomentCommentBloc extends Bloc<MomentCommentEvent, MomentCommentStates> {
  final FetchMomentCommentUseCase fetchMomentCommentUseCase;
  final AddMomentCommentUseCase addMomentCommentUseCase;
  final DeleteMomentCommentUseCase deleteMomentCommentUseCase;

  MomentCommentBloc({
    required this.fetchMomentCommentUseCase,
    required this.addMomentCommentUseCase,
    required this.deleteMomentCommentUseCase,
  }) : super(MomentCommentStates(
          scrollControllerComments: ScrollController(),
        )) {
    on<FetchMomentComment>(fetchMomentComment);
    on<AddMomentComment>(addMomentComment);
    on<DeleteMomentComment>(deleteMomentComment);
    on<AddListenerCommentEvent>(_addEventListenerComment);
    on<RemoveListenerCommentEvent>(_removeEventListenerComment);
  }

  FutureOr<void> fetchMomentComment(
      FetchMomentComment event, Emitter<MomentCommentStates> emit) async {
    if (event.isLoading != false && event.momentId != state.currentMomentId) {
      emit(state.copyWith(reqState: RequestState.loading));
    }

    final result = await fetchMomentCommentUseCase.call(
        GetMomentCommentPrameter(page: event.page, momentId: event.momentId));
    result.fold(
      (l) => emit(
        state.copyWith(
            reqState: handleErrorResponse(l),
            message: NetworkExceptions.getErrorMessage(l)),
      ),
      (r) {
        // final newComments = r.data ?? [];
        // List<MomentCommentsEntity> updatedCommentsList = [];
        // if (event.momentId == state.currentMomentId) {
        //   updatedCommentsList = List.of(state.momentsComment)
        //     ..addAll(newComments);
        // } else {
        //   updatedCommentsList = List.from(newComments);
        // }

        final page = int.parse(event.page);
        emit(state.copyWith(
          lastPage: r.paginates?.lastPage,
          currentPage: page,
          momentsComment: handlePaginationResponse<MomentCommentsEntity>(
            result: r.data,
            currentList: state.momentsComment,
            currentPage: page,
          ),
          reqState: handleLoadedResponse<List<MomentCommentsEntity>>(r.data),
        ));
        if (event.momentId != state.currentMomentId) {
          emit(state.copyWith(currentMomentId: event.momentId));
        }
      },
    );
  }

  FutureOr<void> addMomentComment(
      AddMomentComment event, Emitter<MomentCommentStates> emit) async {
    final result = await addMomentCommentUseCase.call(AddMomentCommentPrameter(
        comment: event.comment, momentId: event.momentId));
    result.fold(
      (l) => emit(
        state.copyWith(
            addCommentReqState: RequestState.error,
            addCommentMessage: NetworkExceptions.getErrorMessage(l)),
      ),
      (r) {
        // emit(state.copyWith(
        //   addCommentMessage: r.data,
        //   addCommentReqState: RequestState.loaded,
        // ));
        List<MomentCommentsEntity> updatedMomentsComment =
            state.momentsComment.isNotEmpty ? state.momentsComment : [];
        updatedMomentsComment.add(
          MomentCommentsModel(
            commentId: -1,
            momentId: int.parse(event.momentId),
            comment: event.comment,
            commentTime: DateTime.now().toString(),
            userId: MyDataModel.getInstance().id,
            userName: MyDataModel.getInstance().name ?? '',
            userProfilePic: MyDataModel.getInstance().profile?.image ?? '',
            uuid: MyDataModel.getInstance().uuid,
          ),
        );
        emit(
          state.copyWith(
            addCommentReqState: RequestState.loaded,
            momentsComment: updatedMomentsComment,
            reqState: handleLoadedResponse<List<MomentCommentsEntity>>(
                updatedMomentsComment),
          ),
        );
        event.momentBloc.add(
          UpdateCommentEvent(
            momentId: int.parse(event.momentId),
            type: event.type,
            commentsNum: state.momentsComment.length,
          ),
        );
      },
    );
  }

  FutureOr<void> deleteMomentComment(
      DeleteMomentComment event, Emitter<MomentCommentStates> emit) async {
    final result = await deleteMomentCommentUseCase.call(
        DeleteMomentCommentPrameter(
            commentId: event.commentId, momentId: event.momentId));
    result.fold(
      (l) => emit(
        state.copyWith(
            deleteCommentReqState: RequestState.error,
            deleteCommentMessage: NetworkExceptions.getErrorMessage(l)),
      ),
      (r) {
        emit(state.copyWith(
          deleteCommentMessage: r.data,
          deleteCommentReqState: RequestState.loaded,
        ));
      },
    );
  }

  void _addEventListenerComment(
    AddListenerCommentEvent event,
    Emitter<MomentCommentStates> emit,
  ) {
    final scroll = state.scrollControllerComments
      ..addListener(() {
        _listenerMoment(event.momentId);
      });
    emit(state.copyWith(scrollControllerComments: scroll));
  }

  void _removeEventListenerComment(
    RemoveListenerCommentEvent event,
    Emitter<MomentCommentStates> emit,
  ) {
    final scroll = state.scrollControllerComments
      ..removeListener(() {
        _listenerMoment(event.momentId);
      });
    emit(state.copyWith(
      scrollControllerComments: scroll,
      currentPage: 1,
      // currentMomentId: "",
    ));
  }

  void _listenerMoment(String momentId) {
    handleScrollListener(
      controller: state.scrollControllerComments,
      currentPage: state.currentPage,
      lastPage: state.lastPage,
      fun: () {
        add(FetchMomentComment(
          isLoading: false,
          momentId: state.currentMomentId,
          page: '${state.currentPage + 1}',
        ));
      },
    );
  }
}
