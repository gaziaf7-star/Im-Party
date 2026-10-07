part of 'charge_dollars_for_user_bloc.dart';



class ChargeDollarsForUserState extends Equatable {
  final RequestState requestState;
  final ChargeModel? data;
  final String? error;

  const ChargeDollarsForUserState({
    this.requestState = RequestState.idle,
    this.data,
    this.error,
  });

  ChargeDollarsForUserState copyWith({
    RequestState? state,
    ChargeModel? data,
    String? error,
  }) {
    return ChargeDollarsForUserState(
      requestState: state ?? requestState,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [requestState, data, error];
}
