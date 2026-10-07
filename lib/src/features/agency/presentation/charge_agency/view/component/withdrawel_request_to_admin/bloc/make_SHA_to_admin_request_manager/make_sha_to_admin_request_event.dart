part of 'make_sha_to_admin_request_bloc.dart';

abstract class MakeShippingAgentToAdminWithdrawalRequestEvent
    extends Equatable {
  const MakeShippingAgentToAdminWithdrawalRequestEvent();

  @override
  List<Object?> get props => [];
}

class MakeShippingAgentToAdminWithdrawalRequest
    extends MakeShippingAgentToAdminWithdrawalRequestEvent {
  final MakeShippingAgentToAdminWithdrawelRequestParam param;
  final BuildContext context;

  const MakeShippingAgentToAdminWithdrawalRequest({
    required this.param,
    required this.context,
  });

  @override
  List<Object?> get props => [param, context];
}

class EditCoinsSwitchValue
    extends MakeShippingAgentToAdminWithdrawalRequestEvent {
  final bool value;

  const EditCoinsSwitchValue({
    required this.value,
  });

  @override
  List<Object?> get props => [
        value,
      ];
}

class EditDollarsSwitchValue
    extends MakeShippingAgentToAdminWithdrawalRequestEvent {
  final bool value;

  const EditDollarsSwitchValue({
    required this.value,
  });

  @override
  List<Object?> get props => [
        value,
      ];
}
