part of 'make_sha_to_admin_request_bloc.dart';



class MakeShippingAgentToAdminWithdrawalRequestState extends Equatable {
  final RequestState requestState;
  final String? message;
  final String? error;
  final bool isCoins;
  final bool isDollars;
final TextEditingController controller;
  const MakeShippingAgentToAdminWithdrawalRequestState({
    this.requestState = RequestState.idle,
    this.message,
    this.error,
    this.isCoins=false,
    this.isDollars=false,
  required  this.controller,
  });

  MakeShippingAgentToAdminWithdrawalRequestState copyWith({
    RequestState? requestState,
    String? message,
    String? error,
    bool? isCoins,
    bool? isDollars,
  }) {
    return MakeShippingAgentToAdminWithdrawalRequestState(
      requestState: requestState ?? this.requestState,
      message: message ?? this.message,
      error: error ?? this.error,
      isCoins: isCoins ?? this.isCoins,
      isDollars: isDollars ?? this.isDollars,
      controller: controller
    );
  }

  @override
  List<Object?> get props => [requestState, message, error,isCoins,isDollars,controller];
}















