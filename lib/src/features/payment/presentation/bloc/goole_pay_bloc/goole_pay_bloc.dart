import 'package:general/src/core/index.dart';
import 'package:general/src/features/payment/domain/use_case/google_pay_use_case.dart';
import 'package:general/src/features/payment/presentation/bloc/goole_pay_bloc/goole_pay_event.dart';
import 'package:general/src/features/payment/presentation/bloc/goole_pay_bloc/goole_pay_state.dart';
import 'package:general/src/features/payment/presentation/view/in_app_purchases.dart';

class GooglePayBloc extends Bloc<BaseGooglePayEvent, GooglePayState> {
  final GooglePayUseCase googlePayUseCase;

  GooglePayBloc({
    required this.googlePayUseCase,
  }) : super(const GooglePayState()) {
    on<GooglePayEvent>((event, emit) async {
      emit(state.copyWith(reqState: RequestState.loading));
      final result = await googlePayUseCase(GooglePayParam(
          purchaseToken: event.purchaseToken, productId: event.productId));

      result.fold(
        (left) {
          // Not credited: leave the purchase un-completed so Play re-delivers
          // it (restored) and we retry instead of losing the coins.
          di<PurchaseService>().markDone(event.purchaseToken);
          emit(
            state.copyWith(
                error: NetworkExceptions.getErrorMessage(left),
                reqState: handleErrorResponse(left)),
          );
        },
        (right) {
          if (right.success == true) {
            di<PurchaseService>().completeAfterCredit(event.purchase);
          }
          di<PurchaseService>().markDone(event.purchaseToken);
          emit(
            state.copyWith(
              data: right.data,
              reqState: handleLoadedResponse<String>(right.data),
            ),
          );
        },
      );
    });
  }
}
