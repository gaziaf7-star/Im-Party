part of 'gold_coin_bloc.dart';

class GoldCoinState extends Equatable {
  final List<GoldCoinsEntity> data;
  final RequestState reqState;
  final String error;

  final String itemId;

  const GoldCoinState({
    this.data = const [],
    this.reqState = RequestState.loading,
    this.error = "",
    this.itemId = "",
  });

  GoldCoinState copyWith({
    List<GoldCoinsEntity>? data,
    RequestState? reqState,
    String? error,
    String? itemId,
  }) {
    return GoldCoinState(
      data: data ?? this.data,
      reqState: reqState ?? this.reqState,
      error: error ?? this.error,
      itemId: itemId ?? this.itemId,
    );
  }

  @override
  List<Object?> get props => [data, reqState, error, itemId];
}
