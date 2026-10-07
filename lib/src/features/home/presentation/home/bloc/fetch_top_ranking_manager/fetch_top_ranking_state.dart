part of 'fetch_top_ranking_bloc.dart';

class FetchTopRankingState extends Equatable {
  final TopRankImagesModel? rankingEntity;
  final RequestState requestState;

  const FetchTopRankingState({
    this.rankingEntity,
    this.requestState = RequestState.idle,
  });

  FetchTopRankingState copyWith({
    TopRankImagesModel? rankingEntity,
    RequestState? requestState,
  }) {
    return FetchTopRankingState(
      rankingEntity: rankingEntity ?? this.rankingEntity,
      requestState: requestState ?? this.requestState,
    );
  }

  @override
  List<Object?> get props => [rankingEntity, requestState];
}
