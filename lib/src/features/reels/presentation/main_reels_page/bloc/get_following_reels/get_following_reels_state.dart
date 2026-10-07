part of 'get_following_reels_bloc.dart';


class GetFollowingReelsState extends Equatable {
  final List<ReelsEntity> commentsList;
  final String errorMessage;
  final RequestState requestState;

  const GetFollowingReelsState({
    this.commentsList = const [],
    this.errorMessage = '',
    this.requestState = RequestState.idle,
  });

  GetFollowingReelsState copyWith({
    List<ReelsEntity>? commentsList,
    String? errorMessage,
    RequestState? requestState,
  }) {
    return GetFollowingReelsState(
      commentsList: commentsList ?? this.commentsList,
      errorMessage: errorMessage ?? this.errorMessage,
      requestState: requestState ?? this.requestState,
    );
  }

  @override
  List<Object?> get props => [commentsList, errorMessage, requestState];
}

