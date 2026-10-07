import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';

part 'send_withdrawel_request_event.dart';
part 'send_withdrawel_request_state.dart';

class SendWithdrawalRequestBloc
    extends Bloc<BaseSendWithdrawalRequestEvents, SendWithdrawalRequestState> {
  final SendWithdrawalRequestUC sendWithdrawalRequestUseCase;

  SendWithdrawalRequestBloc({required this.sendWithdrawalRequestUseCase})
      : super(SendWithdrawalRequestState(
          amountController: TextEditingController(),
          notesController: TextEditingController(),
        )) {
    on<PaymentSelectEvent>(_paymentSelect);
    on<CountrySelectEvent>(_countrySelect);
    on<ClearTheSelection>(_clearSelection);
    // on<DisposeControllerEvent>(_disposeController);
    on<SendWithdrawalRequestEvent>(_sendWithdrawalRequestEvent);
  }

  Future<void>  _sendWithdrawalRequestEvent(SendWithdrawalRequestEvent event,
      Emitter<SendWithdrawalRequestState> emit) async {
    final result = await sendWithdrawalRequestUseCase.call(SendWithdrawalRequestParam(

      agentId: event.agentId,
      usd: state.amountController.text,
      countryId: state.country?.id.toString(),
      paymentId: state.payment?.id.toString(),
      note: state.notesController.text


    ));

    result.fold(
      (failure) {
        emit(state.copyWith(
          requestState: RequestState.error,
          country: null,
          payment: null,
          message: NetworkExceptions.getErrorMessage(failure),
        ));


        Methods.showToast(event.context,
            message: state.message ?? '', isError: true);

        state.amountController.clear();
        state.notesController.clear();
        add(const ClearTheSelection());

      },
      (success) {
        di<MyStoreBloc>().add(EditMyUserUsdLocally(
          userUsd: int.parse(state.amountController.text),
        ));
        emit(state.copyWith(
          requestState: RequestState.loaded,
          country: null,
          payment: null,
          message: success.message,
        ));
        state.amountController.clear();
        state.notesController.clear();
        add(const ClearTheSelection());
      },
    );
  }

  void _paymentSelect(
      PaymentSelectEvent event, Emitter<SendWithdrawalRequestState> emit) {
    emit(state.copyWith(payment: event.payment));
  }

  void _countrySelect(
      CountrySelectEvent event, Emitter<SendWithdrawalRequestState> emit) {
    emit(state.copyWith(country: event.country));
  }

  void _clearSelection(
      ClearTheSelection event, Emitter<SendWithdrawalRequestState> emit) {
    emit(state.copyWith(
      isNullPayment: true,
      isNullCountry: true,
    ));
  }

//  void _disposeController(DisposeControllerEvent event,
//       Emitter<SendWithdrawalRequestState> emit)  {
// state.notesController.dispose();
// state.amountController.dispose();
//   }

  @override
  Future<void> close() {
    state.amountController.dispose();
    state.notesController.dispose();
    return super.close();
  }
}
