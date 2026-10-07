
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/data/model/my_store_model.dart';

import '../../../../../auth/domain/entities/my_store_entity.dart';
import '../../../../domain/profile_use_case/my_store_use_case.dart';

part 'my_store_event.dart';

part 'my_store_state.dart';

class MyStoreBloc extends Bloc<BaseMyStoreEvent, MyStoreState> {
  final MyStoreUseCase getMyStoreUseCase;

  MyStoreBloc({
    required this.getMyStoreUseCase,
  }) : super(const MyStoreState()) {
    on<GetMyStoreEvent>((event, emit) async {
      if(event.isLoading == true){
        emit(state.copyWith(reqState: RequestState.loading));
      }
      final result = await getMyStoreUseCase();
      result.fold(
          (left) => emit(
                state.copyWith(
                    message: NetworkExceptions.getErrorMessage(left),
                    reqState: handleErrorResponse(left)),
              ),
          (right) => emit(
                state.copyWith(
                    myStore: right,
                    reqState: handleLoadedResponse<MyStoreModel>(right)),
              ));
    });
    on<EditMyUserUsdLocally>((event, emit) async {

      final int newUserUsd = (((state.myStore?.userUsd) is String)
          ? int.parse(state.myStore?.userUsd ?? '0')
          : (state.myStore?.userUsd ?? 0)) - event.userUsd;

      final MyStoreEntity? myStore = state.myStore?.copyWith(userUsd: newUserUsd);
      emit(state.copyWith(myStore: myStore));

    });
    on<EditMyAgentUsdLocally>((event, emit) async {
      if (state.myStore == null) return;

      final int newAgentUsd =
          int.parse(state.myStore?.agentUsd.toString() ?? '0') - event.agentUsd;

      final MyStoreEntity? myStore =
          state.myStore?.copyWith(agentUsd: newAgentUsd);
      emit(state.copyWith(myStore: myStore));
    });
    on<EditMyCoinsAndDiamondsLocally>((event, emit) async {
      if (state.myStore == null) return;

      final int newCoins =
          int.parse(state.myStore?.coins.toString() ?? '0') + event.coins;
      final int newDiamonds =
          int.parse(state.myStore?.diamonds.toString() ?? '0') - event.diamonds;
      // The wallet's "Diamond" card reads earnedCoins, not diamonds
      // (golden_diamond_card.dart) -- diamonds/coins alone were being
      // updated here, so an exchange never moved the number actually on
      // screen until the next full /my-store refetch (e.g. leaving and
      // re-entering the page).
      final num newEarnedCoins =
          (state.myStore?.earnedCoins ?? 0) - event.diamonds;

      final MyStoreEntity? myStore = state.myStore?.copyWith(
        diamonds: newDiamonds,
        coins: newCoins,
        earnedCoins: newEarnedCoins,
      );
      emit(state.copyWith(myStore: myStore));
    });
  }
}
