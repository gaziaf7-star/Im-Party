import 'package:general/src/core/index.dart';
import 'package:general/src/features/payment/data/model/coins_model.dart';
import 'package:general/src/features/payment/domain/use_case/get_coins_use_case.dart';
import 'package:general/src/features/payment/presentation/bloc/fetch_coins/fetch_coins_event.dart';
import 'package:general/src/features/payment/presentation/bloc/fetch_coins/fetch_coins_state.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';

class FetchCoinsBloc extends Bloc<BaseCoinsEvent, FetchCoinsState> {
  final GetCoinsUseCase getCoinsUseCase;

  FetchCoinsBloc({
    required this.getCoinsUseCase,
  }) : super(const FetchCoinsState()) {

    on<FetchCoinsEvent>((event, emit) async {
      if (event.type == 'shipping') {
        emit(state.copyWith(shippingReqState: RequestState.loading));
        final result = await getCoinsUseCase(event.type);
        result.fold(
              (left) => emit(
            state.copyWith(
              shippingError: NetworkExceptions.getErrorMessage(left),
              shippingReqState: handleErrorResponse(left),
            ),
          ),
              (right) {
            emit(
              state.copyWith(
                shippingData: right.data,
                shippingReqState: handleLoadedResponse<List<PaymentGatewayModel>>(right.data),
              ),
            );
            di<MyStoreBloc>().add(const GetMyStoreEvent());
          },
        );
      } else {
        // Normal coins case
        emit(state.copyWith(reqState: RequestState.loading));
        final result = await getCoinsUseCase(event.type);
        result.fold(
              (left) => emit(
            state.copyWith(
              error: NetworkExceptions.getErrorMessage(left),
              reqState: handleErrorResponse(left),
            ),
          ),
              (right) {
            emit(
              state.copyWith(
                data: right.data,
                reqState: handleLoadedResponse<List<PaymentGatewayModel>>(right.data),
              ),
            );
            di<MyStoreBloc>().add(const GetMyStoreEvent());
          },
        );
      }
    });

    on<CheckBoxEvent>((event, emit) async {
      emit(state.copyWith(isChecked: event.isChecked));

    });

  }
}
