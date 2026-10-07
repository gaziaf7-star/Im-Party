import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/domain/entities/moment_likes_entity.dart';

class GetMomentLikesState extends Equatable {
  final List<MomentLikesEntity> momentLikes;
  final RequestState reqState;
  final String message;
  final ScrollController scrollControllerLikes;
  final int currentPage, lastPage;
  final String currentMomentId;

  const GetMomentLikesState({
    this.momentLikes = const [],
    this.reqState = RequestState.idle,
    this.message = '',
    required this.scrollControllerLikes,
    this.currentPage = 1,
    this.lastPage = -1,
        this.currentMomentId = '',

  });

  GetMomentLikesState copyWith({
    List<MomentLikesEntity>? momentLikes,
    RequestState? reqState,
    String? message,
    int? currentPage,
    int? lastPage,
        String? currentMomentId,

    ScrollController? scrollControllerLikes,
  }) {
    return GetMomentLikesState(
      momentLikes: momentLikes ?? this.momentLikes,
      reqState: reqState ?? this.reqState,
      message: message ?? this.message,
            currentMomentId: currentMomentId ?? this.currentMomentId,

      lastPage: lastPage ?? this.lastPage,
      currentPage: currentPage ?? this.currentPage,
      scrollControllerLikes:
          scrollControllerLikes ?? this.scrollControllerLikes,
    );
  }

  @override
  List<Object?> get props => [
        message,
        reqState,
        momentLikes,
        lastPage,
        currentMomentId,
        currentPage,
        scrollControllerLikes,
      ];
}

/*
abstract class GetMomentLikesState extends Equatable {
  final List<MomentLikeModel> data;
  const GetMomentLikesState({this.data = const []});

  @override
  List<Object?> get props => [data];
}

class GetMomentLikeInitial extends GetMomentLikesState {
  const GetMomentLikeInitial({super.data});
  @override
  List<Object?> get props => [data];
}

class GetMomentLikeLoadingState extends GetMomentLikesState {
  const GetMomentLikeLoadingState({super.data});
  @override
  List<Object?> get props => [data];
}

class GetMomentLikeSucssesState extends GetMomentLikesState {
  const GetMomentLikeSucssesState({super.data});
  @override
  List<Object?> get props => [data];
}

class GetMomentLikeErrorState extends GetMomentLikesState {
  final String error;
  const GetMomentLikeErrorState({required this.error});
  @override
  List<Object?> get props => [error];
}
*/
