

part of 'get_payments_getways_bloc.dart';

abstract class PaymentGetwaysDataEvent extends Equatable {
  const PaymentGetwaysDataEvent();

  @override
  List<Object?> get props => const [];
}
class GetPaymentGetwaysData extends PaymentGetwaysDataEvent{
  const GetPaymentGetwaysData();
}
