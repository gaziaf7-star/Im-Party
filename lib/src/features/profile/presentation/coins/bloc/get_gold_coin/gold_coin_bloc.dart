import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/data/model/gold_coin_model.dart';
import 'package:general/src/features/profile/domain/entities/gold_coins_entity.dart';
import '../../../../domain/profile_use_case/get_gold_coin_prices_use_case.dart';
part 'gold_coin_event.dart';
part 'gold_coin_state.dart';

class GoldCoinBloc extends Bloc<GoldCoinEvent, GoldCoinState> {
  final GetGoldCoinPricesUseCase getGoldCoinPricesUseCase;

  GoldCoinBloc({required this.getGoldCoinPricesUseCase})
      : super(const GoldCoinState()) {

    on<GetGoldCoinDataEvent>(
      (event, emit) async {
        emit(state.copyWith(reqState: RequestState.loading));
        final result = await getGoldCoinPricesUseCase();

        result.fold(
          (left) => emit(
            state.copyWith(
              error: NetworkExceptions.getErrorMessage(left),
              reqState: handleErrorResponse(left)
            ),
          ),
          (right) {
            emit(state.copyWith(data: right.data ?? [],
            reqState: handleLoadedResponse<List<GoldCoinsModel>>(right.data)
            ));
          },
        );
      },
    );

    on<SelectCoinDataEvent>(
      (event, emit) async {
        emit(state.copyWith(itemId: event.itemId));
      },
    );
  }
}
