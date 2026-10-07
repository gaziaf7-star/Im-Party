import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/core/index.dart';

part 'send_confirmation_request_event.dart';

part 'send_confirmation_request_state.dart';

class SendConfirmationRequestBloc
    extends Bloc<SendConfirmationRequestEvent, SendConfirmationRequestState> {
  final SendTransferConfirmationRequestUC useCase;

  SendConfirmationRequestBloc({required this.useCase})
      : super(const SendConfirmationRequestState()) {
    on<SendConfirmationRequestEvent>(
      (event, emit) async {
        // Emit Loading State
        emit(state.copyWith(requestState: RequestState.loading));

        // Call the UseCase
        final result = await useCase(event.param);

        // Handle result
        result.fold(
            // On failure, emit Error State with error message
            (left) {
          emit(
            state.copyWith(
              requestState: RequestState.error,
              error: NetworkExceptions.getErrorMessage(left),
            ),
          );

          Methods.showToast(event.context,
              message: state.error ?? '', isError: true);
        },
            // On success, emit Success State with message
            (right) {
              di<GetShippingAgentsRequestsBloc>()
                  .add(const UnPickConfirmationImageEvent());
              di<GetShippingAgentsRequestsBloc>()
                  .add( const HandleConfirmationBodyEvent());
              di<GetShippingAgentsRequestsBloc>().add(
                  ConfirmRequestLocalEvent(id: event.param.requestId));
              event.controller.animateTo(2);
          emit(
            state.copyWith(
              requestState: RequestState.loaded,
              message: right.message,
            ),
          );
          Methods.showToast(event.context, message: state.message ?? '');
        });
      },
    );
  }
}
