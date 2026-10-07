part of 'make_shipping_agent_request_action_bloc.dart';


abstract class BaseShippingAgentRequestActionEvent extends Equatable {
  const BaseShippingAgentRequestActionEvent();

  @override
  List<Object?> get props => [];
}

class ShippingAgentRequestActionEvent
    extends BaseShippingAgentRequestActionEvent {
  final BuildContext context;
  final ShippingAgentRequestActionParam param;
  final TabController controller;
  const ShippingAgentRequestActionEvent({
    required this.param,
    required this.context,
    required this.controller,
  });

  @override
  List<Object?> get props => [param,context,controller];
}
