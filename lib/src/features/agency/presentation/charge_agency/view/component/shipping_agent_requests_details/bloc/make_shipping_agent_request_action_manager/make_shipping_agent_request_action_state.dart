part of 'make_shipping_agent_request_action_bloc.dart';



class MakeShippingAgentRequestActionState extends Equatable {
  final RequestState requestState;
  final String? successMessage;
  final String? errorMessage;

  const MakeShippingAgentRequestActionState({
    this.requestState = RequestState.idle,
    this.successMessage,
    this.errorMessage,
  });

  MakeShippingAgentRequestActionState copyWith({
    RequestState? requestState,
    String? successMessage,
    String? errorMessage,
  }) {
    return MakeShippingAgentRequestActionState(
      requestState: requestState ?? this.requestState,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [requestState, successMessage, errorMessage];
}
