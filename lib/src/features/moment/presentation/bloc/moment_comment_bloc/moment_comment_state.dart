import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/moment.dart';

class MomentCommentStates extends Equatable {
  final List<MomentCommentsEntity> momentsComment;
  final RequestState reqState;
  final String message;
  final String currentMomentId;

  final RequestState addCommentReqState;
  final String addCommentMessage;

  final RequestState deleteCommentReqState;
  final String deleteCommentMessage;
  final ScrollController scrollControllerComments;
  final int currentPage, lastPage;

  const MomentCommentStates({
    this.momentsComment = const [],
    this.reqState = RequestState.idle,
    this.message = '',
    this.currentMomentId = '',
    this.addCommentReqState = RequestState.loading,
    this.addCommentMessage = '',
    this.deleteCommentReqState = RequestState.loading,
    this.deleteCommentMessage = '',
       required this.scrollControllerComments,
    this.currentPage = 1,
    this.lastPage = -1,
  });

  MomentCommentStates copyWith({
    List<MomentCommentsEntity>? momentsComment,
    RequestState? reqState,
    String? message,
    String? currentMomentId,
    RequestState? addCommentReqState,
    String? addCommentMessage,
    RequestState? deleteCommentReqState,
    String? deleteCommentMessage,
     int? currentPage,
    int? lastPage,
    ScrollController? scrollControllerComments,
  }) {
    return MomentCommentStates(
      momentsComment: momentsComment ?? this.momentsComment,
      reqState: reqState ?? this.reqState,
      message: message ?? this.message,
      currentMomentId: currentMomentId ?? this.currentMomentId,
      addCommentReqState: addCommentReqState ?? this.addCommentReqState,
      addCommentMessage: addCommentMessage ?? this.addCommentMessage,
      deleteCommentReqState: deleteCommentReqState ?? this.deleteCommentReqState,
      deleteCommentMessage: deleteCommentMessage ?? this.deleteCommentMessage,
      lastPage: lastPage ?? this.lastPage,
      currentPage: currentPage ?? this.currentPage,
      scrollControllerComments:
          scrollControllerComments ?? this.scrollControllerComments,
    );
  }

  @override
  List<Object?> get props => [
    message,
    reqState,
    currentMomentId,
    momentsComment,
    addCommentReqState,
    addCommentMessage,
    deleteCommentReqState,
    deleteCommentMessage,
      lastPage,
        currentPage,
        scrollControllerComments,
  ];
}
