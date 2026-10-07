import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';



part 'get_charge_coins_history_event.dart';

part 'get_charge_coins_history_state.dart';




class GetChargeCoinsHistoryBloc
    extends Bloc<BaseGetChargeCoinsHistoryEvent, GetChargeCoinsHistoryState> {
  final GetChargeCoinsHistoryUC getChargeCoinsHistoryUseCase;

  GetChargeCoinsHistoryBloc({required this.getChargeCoinsHistoryUseCase})
      : super(const GetChargeCoinsHistoryState()) {
    on<GetChargeCoinsHistoryEvent>((event, emit) async {
      emit(state.copyWith(
          state: RequestState.loading
      )); // Emit loading state
      final result = await getChargeCoinsHistoryUseCase(); // Call the use case

      result.fold(
            (left) =>
            emit(state.copyWith(
              state: handleErrorResponse(left),
              error: NetworkExceptions.getErrorMessage(
                  left), // Emit error state
            )),
            (right) =>
            emit(state.copyWith(
              state: handleLoadedResponse<List<UerChargeCoinsHistoryModel>?>(right.data),
              dataList: right.data ?? [], // Emit success state with data
            )),
      );
    });
  }
}


