part of 'get_coins_history_bloc.dart';






class GetGoogleCoinsHistoryState extends Equatable {
  final List<UserGoogleCoinsHistoryModel>? coinsHistoryList;
  final String? error;
  final RequestState requestState;

  const GetGoogleCoinsHistoryState({
    this.coinsHistoryList,
    this.error,
    this.requestState = RequestState.idle,
  });

  GetGoogleCoinsHistoryState copyWith({
    List<UserGoogleCoinsHistoryModel>? coinsHistoryList,
    String? error,
    RequestState? state,
  }) {
    return GetGoogleCoinsHistoryState(
      coinsHistoryList: coinsHistoryList ?? this.coinsHistoryList,
      error: error ?? this.error,
      requestState: state ?? requestState,
    );
  }

  @override
  List<Object?> get props => [coinsHistoryList ?? [], error ?? '', requestState];
}













