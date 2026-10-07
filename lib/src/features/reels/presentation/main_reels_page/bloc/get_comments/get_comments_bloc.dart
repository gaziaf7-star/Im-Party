import 'package:general/src/features/reels/domain/entities/reel_comment_entity.dart';
import 'package:general/src/features/reels/domain/use_case/get_comments_use_case.dart';
import '../../../../../../core/index.dart';

part 'get_comments_event.dart';
part 'get_comments_state.dart';

class GetCommentsBloc extends Bloc<BaseGetCommentsEvent, GetCommentsState> {
  final GetCommentsUseCase getCommentsUseCase;
  VoidCallback? _scrollListener;

  GetCommentsBloc(this.getCommentsUseCase)
      : super(GetCommentsState(
          scrollControllerComments: ScrollController(),
        )) {
    on<GetCommentsEvent>((event, emit) async {
      final isNewReel = event.param.reelId != state.reelId;
      if (isNewReel) {
        emit(state.copyWith(
          reelId: event.param.reelId,
          commentsList: const [],
          currentPage: 1,
          requestState: RequestState.loading,
        ));
      } else if (event.isLoading) {
        emit(state.copyWith(
          requestState: RequestState.loading,
        ));
      }

      final result = await getCommentsUseCase(event.param);

      result.fold(
        (left) => emit(state.copyWith(
          requestState: handleErrorResponse(left),
          errorMessage: NetworkExceptions.getErrorMessage(left),
        )),
        (right) {
          final page = event.param.page ?? 1;
          emit(state.copyWith(
            lastPage: right.paginates?.lastPage ?? 1,
            currentPage: page,
            requestState:
                handleLoadedResponse<List<ReelCommentEntity>>(right.data),
            commentsList: handlePaginationResponse<ReelCommentEntity>(
              result: right.data,
              currentList: isNewReel ? [] : state.commentsList,
              currentPage: page,
            ),
          ));
        },
      );
    });
    on<LocalAddCommentsEvent>((event, emit) async {
      final ReelCommentEntity newComment = ReelCommentEntity(
        comment: event.param.comment,
        commentTime: DateTime.now().toString(),
        userName: MyDataModel.getInstance().name,
        userProfilePic: MyDataModel.getInstance().profile?.image ?? '',
      );
      final comments = List.of(state.commentsList);
      comments.insert(0, newComment);
      emit(state.copyWith(
          commentsList: comments, requestState: RequestState.loaded));
    });

    on<AddListenerCommentEvent>(_addEventListenerComment);
    on<RemoveListenerCommentEvent>(_removeEventListenerComment);
  }

  void _addEventListenerComment(
    AddListenerCommentEvent event,
    Emitter<GetCommentsState> emit,
  ) {
    if (_scrollListener != null) {
      state.scrollControllerComments.removeListener(_scrollListener!);
    }
    _scrollListener = () => _listenerComments(event.reelId);
    final scroll = state.scrollControllerComments
      ..addListener(_scrollListener!);
    emit(state.copyWith(scrollControllerComments: scroll));
  }

  void _removeEventListenerComment(
    RemoveListenerCommentEvent event,
    Emitter<GetCommentsState> emit,
  ) {
    if (_scrollListener != null) {
      state.scrollControllerComments.removeListener(_scrollListener!);
      _scrollListener = null;
    }
    emit(state.copyWith(
      scrollControllerComments: state.scrollControllerComments,
      currentPage: 1,
    ));
  }

  void _listenerComments(String reelId) {
    handleScrollListener(
      controller: state.scrollControllerComments,
      currentPage: state.currentPage,
      lastPage: state.lastPage,
      fun: () {
        add(
          GetCommentsEvent(
            param: ReelParam(
              reelId: state.reelId,
              page: state.currentPage + 1,
            ),
            isLoading: false,
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    if (_scrollListener != null) {
      state.scrollControllerComments.removeListener(_scrollListener!);
    }
    state.scrollControllerComments.dispose();
    return super.close();
  }
}
