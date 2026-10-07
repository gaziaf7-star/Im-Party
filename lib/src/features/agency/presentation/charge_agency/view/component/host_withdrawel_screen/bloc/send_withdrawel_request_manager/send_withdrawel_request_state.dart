part of 'send_withdrawel_request_bloc.dart';

class SendWithdrawalRequestState extends Equatable {
  final RequestState requestState;
  final String? message;
  final TextEditingController amountController;
  final TextEditingController notesController;
  final PaymentsGetwaysEntity? payment;
  final CountryEntity? country;
  final bool? isNullCountry, isNullPayment;

  const SendWithdrawalRequestState({
    this.requestState = RequestState.idle,
    this.payment,
    this.message,
    this.country,
    required this.amountController,
    required this.notesController,
    this.isNullCountry = false,
    this.isNullPayment = false,
  });

  SendWithdrawalRequestState copyWith({
    RequestState? requestState,
    String? message,
    PaymentsGetwaysEntity? payment,
    CountryEntity? country,
    bool isNullCountry = false,
    bool isNullPayment = false,
  }) {
    return SendWithdrawalRequestState(
      requestState: requestState ?? this.requestState,
      message: message ?? this.message,
      payment: isNullPayment ? null : payment ?? this.payment,
      country: isNullCountry ? null : country ?? this.country,
      amountController: amountController,
      notesController: notesController,
    );
  }

  @override
  List<Object?> get props =>
      [
        requestState,
        message,
        amountController,
        notesController,
        payment,
        country,
        isNullPayment,
        isNullCountry
      ];
}
