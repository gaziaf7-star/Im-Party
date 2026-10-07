part of 'get_charge_agency_bloc.dart';

class GetChargeAgencyStates extends Equatable {
  final RequestState requestState;
  final String message;
  final ChargeAgencyInfoEntity? data;
  final ChargeAgencyInfoEntity? myChargeAgencyData;

  const GetChargeAgencyStates({
    this.requestState = RequestState.idle,
    this.message = '',
    this.data,
    this.myChargeAgencyData,
  });

  GetChargeAgencyStates copyWith({
    RequestState? requestState,
    String? message,
    ChargeAgencyInfoEntity? data,
    ChargeAgencyInfoEntity? myChargeAgencyData,
  }) {
    return GetChargeAgencyStates(
      requestState: requestState ?? this.requestState,
      message: message ?? this.message,
      data: data ?? this.data,
      myChargeAgencyData: myChargeAgencyData ?? this.myChargeAgencyData,
    );
  }

  @override
  List<Object?> get props => [requestState, message, data, myChargeAgencyData];
}
