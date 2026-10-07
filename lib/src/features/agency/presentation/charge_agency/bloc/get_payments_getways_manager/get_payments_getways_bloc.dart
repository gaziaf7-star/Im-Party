import 'package:general/src/features/agency/agency.dart';import 'package:general/src/core/index.dart';

part 'get_payments_getways_event.dart';
part 'get_payments_getways_state.dart';


class GetPaymentsGetwaysDataBloc
    extends Bloc<PaymentGetwaysDataEvent, GetPaymentsGetwaysDataState> {
  GetPaymentGetwaysUC getPaymentGetwaysUseCase;

  GetPaymentsGetwaysDataBloc({required this.getPaymentGetwaysUseCase})
      : super(const GetPaymentsGetwaysDataState()) {
    on<GetPaymentGetwaysData>(
      (event, emit) async {
        emit(state.copyWith(requestState: RequestState.loading));
        final result = await getPaymentGetwaysUseCase();

        result.fold(
          (left) => emit(
            state.copyWith(
              requestState: handleErrorResponse(left),
              message: NetworkExceptions.getErrorMessage(left),
            ),
          ),
          (right) => emit(state.copyWith(
              requestState: handleLoadedResponse(right.data),
              data: right.data ?? [])),
        );
      },
    );
  }
}
