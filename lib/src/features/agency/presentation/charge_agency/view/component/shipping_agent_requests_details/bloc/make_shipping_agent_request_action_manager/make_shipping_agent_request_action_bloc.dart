import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/core/index.dart';

part 'make_shipping_agent_request_action_event.dart';

part 'make_shipping_agent_request_action_state.dart';

class MakeShippingAgentRequestActionBloc extends Bloc<
    BaseShippingAgentRequestActionEvent,
    MakeShippingAgentRequestActionState> {
  final MakeShippingAgentRequestActionUC shippingAgentRequestActionUseCase;

  MakeShippingAgentRequestActionBloc(
      {required this.shippingAgentRequestActionUseCase})
      : super(const MakeShippingAgentRequestActionState()) {
    on<ShippingAgentRequestActionEvent>(
          (event, emit) async {
        // Emit Loading State with RequestState
        emit(state.copyWith(requestState: RequestState.loading));

        // Call the UseCase with the event parameter
        final result = await shippingAgentRequestActionUseCase.call(
          event.param,
        );

        result.fold((left) {
          emit(
            state.copyWith(
              requestState: RequestState.error,
              errorMessage: NetworkExceptions.getErrorMessage(left),
            ),
          );

          Methods.showToast(event.context,
              message: state.errorMessage ?? '', isError: true);
        }, (right) {
          if(event.param.actionType=='1') {
            di<GetShippingAgentsRequestsBloc>().add(
              AcceptRequestLocalEvent(id: event.param.requestId));
            event.controller.animateTo(1);
          }else{
            di<GetShippingAgentsRequestsBloc>().add(
                RejectRequestLocalEvent(id: event.param.requestId));
            event.controller.animateTo(4);

          }

          emit(
            state.copyWith(
              requestState: RequestState.loaded,
              successMessage: right.message,
            ),
          );

          Methods.showToast(event.context, message: state.successMessage ?? '');
        });
      },
    );
  }
}
