part of'charge_to_bloc.dart';





class ChargeToState extends Equatable {
  final RequestState requestState;
  final ChargeModel? chargeToModel;
  final String? error;

  const ChargeToState({
    this.requestState = RequestState.idle,
    this.chargeToModel,
    this.error,
  });

  ChargeToState copyWith({
    RequestState? state,
    ChargeModel? chargeToModel,
    String? error,
  }) {
    return ChargeToState(
      requestState: state ?? requestState,
      chargeToModel: chargeToModel ?? this.chargeToModel,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [requestState, chargeToModel, error];
}

