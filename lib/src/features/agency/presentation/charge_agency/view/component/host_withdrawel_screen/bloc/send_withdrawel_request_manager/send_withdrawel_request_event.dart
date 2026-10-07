part of 'send_withdrawel_request_bloc.dart';

abstract class BaseSendWithdrawalRequestEvents extends Equatable {
  const BaseSendWithdrawalRequestEvents();
}

class SendWithdrawalRequestEvent extends BaseSendWithdrawalRequestEvents {
  final String? agentId;
  final String? note;
  final String? paymentId;
  final String? countryId;
  final String? usd;
  final BuildContext context;

  const SendWithdrawalRequestEvent({
    this.agentId,
    this.note,
    this.paymentId,
    this.countryId,
    this.usd,
    required this.context,
  });

  @override
  List<Object?> get props =>
      [agentId, note, paymentId, countryId, usd, context];
}

class PaymentSelectEvent extends BaseSendWithdrawalRequestEvents {
  final PaymentsGetwaysEntity payment;

  const PaymentSelectEvent({
    required this.payment,
  });

  @override
  List<Object?> get props => [payment];
}

class CountrySelectEvent extends BaseSendWithdrawalRequestEvents {
  final CountryEntity country;

  const CountrySelectEvent({
    required this.country,
  });

  @override
  List<Object?> get props => [country];
}

class ClearTheSelection extends BaseSendWithdrawalRequestEvents {

  const ClearTheSelection();

  @override
  List<Object?> get props => [];
}


// class DisposeControllerEvent extends BaseSendWithdrawalRequestEvents {
//   const DisposeControllerEvent();
//
//   @override
//   List<Object?> get props => [];
// }
