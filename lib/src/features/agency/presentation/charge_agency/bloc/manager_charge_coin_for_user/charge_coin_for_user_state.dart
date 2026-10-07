part of 'charge_coin_for_user_bloc.dart';








// State class using RequestState enum
class ChargeCoinForUserState extends Equatable {
  final RequestState requestState; // Current state of the request
  final String? data; // ChargeModel data on success
  final String? error; // Error message on failure

  const ChargeCoinForUserState({
    this.requestState = RequestState.idle, // Default state is initial
    this.data = '',
    this.error,
  });

  // CopyWith method to allow state updates
  ChargeCoinForUserState copyWith({
    RequestState? requestState,
    String? data,
    String? error,
  }) {
    return ChargeCoinForUserState(
      requestState: requestState ?? this.requestState,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [requestState, data, error];
}










