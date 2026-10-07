part of 'get_charge_coins_history_bloc.dart';

class GetChargeCoinsHistoryState extends Equatable {
  final List<UerChargeCoinsHistoryModel>? dataList;
  final String? error;
  final RequestState requestState;

  const GetChargeCoinsHistoryState({
    this.dataList,
    this.error,
    this.requestState = RequestState.idle,
  });

  GetChargeCoinsHistoryState copyWith({
    List<UerChargeCoinsHistoryModel>? dataList,
    String? error,
    RequestState? state,
  }) {
    return GetChargeCoinsHistoryState(
      dataList: dataList ?? this.dataList,
      error: error ?? this.error,
      requestState: state ?? requestState,
    );
  }

  @override
  List<Object?> get props => [dataList ?? [], error ?? '', requestState];
}


