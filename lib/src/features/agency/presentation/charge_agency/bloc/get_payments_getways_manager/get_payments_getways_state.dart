

part of 'get_payments_getways_bloc.dart';

class GetPaymentsGetwaysDataState extends Equatable {
  final RequestState requestState;
  final String message;
  final List<PaymentsGetwaysEntity>? data;
  final PaymentsGetwaysEntity? selectedPayment;

  const GetPaymentsGetwaysDataState({
    this.requestState = RequestState.idle,
    this.message = '',
    this.data,
    this.selectedPayment,
  });

  GetPaymentsGetwaysDataState copyWith({
      RequestState? requestState,
      String? message,
      List<PaymentsGetwaysEntity>? data,
      PaymentsGetwaysEntity? selectedPayment})
  {
    return GetPaymentsGetwaysDataState(
      requestState: requestState ?? this.requestState,
      message: message ?? this.message,
      data: data ?? this.data,
      selectedPayment: selectedPayment ?? this.selectedPayment,
    );
  }

  @override
  List<Object?> get props => [requestState, message, data];
}

