part of 'get_comments_bloc.dart';

class GetCommentsState extends Equatable {
  final List<ReelCommentEntity> commentsList;
  final String errorMessage;
  final RequestState requestState;
  final String? reelId;
  final ScrollController scrollControllerComments;
  final int currentPage, lastPage;

  const GetCommentsState({
    this.commentsList = const [],
    this.errorMessage = '',
    this.reelId = '',
    this.requestState = RequestState.idle,
    required this.scrollControllerComments,
    this.currentPage = 1,
    this.lastPage = -1,
  });

  GetCommentsState copyWith(
      {List<ReelCommentEntity>? commentsList,
      String? errorMessage,
      RequestState? requestState,
      int? currentPage,
      int? lastPage,
      ScrollController? scrollControllerComments,
      String? reelId}) {
    return GetCommentsState(
      commentsList: commentsList ?? this.commentsList,
      errorMessage: errorMessage ?? this.errorMessage,
      requestState: requestState ?? this.requestState,
      reelId: reelId ?? this.reelId,
      lastPage: lastPage ?? this.lastPage,
      currentPage: currentPage ?? this.currentPage,
      scrollControllerComments:
          scrollControllerComments ?? this.scrollControllerComments,
    );
  }

  @override
  List<Object?> get props => [
        commentsList,
        errorMessage,
        requestState,
        reelId,
        lastPage,
        currentPage,
        scrollControllerComments,
      ];
}
