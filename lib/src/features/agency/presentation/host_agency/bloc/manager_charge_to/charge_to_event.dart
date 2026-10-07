part of'charge_to_bloc.dart';

abstract class ChargeToEvents extends Equatable {
  const ChargeToEvents();
  @override
  List<Object?> get props => [];
}

class SendCharge extends ChargeToEvents {
  final String uId;
  final String usd;
  final String type;
  final BuildContext context;
  const SendCharge({
    required this.uId,
    required this.type,
    required this.context,
    required this.usd});

  @override
  List<Object?> get props => [uId, usd,type];
}
