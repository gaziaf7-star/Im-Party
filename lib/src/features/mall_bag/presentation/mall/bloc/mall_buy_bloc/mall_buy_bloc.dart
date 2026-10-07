import 'dart:async';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/mall_bag/mall_bag.dart';
part 'mall_buy_event.dart';
part 'mall_buy_state.dart';

class MallBuyBloc extends Bloc<MallBuyEvent, MallBuyState> {
  final BuyFromMallUseCase buyUseCase;
  final BuyMallSpecialIdUC buyMallSpecialIdUC;
  MallBuyBloc({required this.buyUseCase, required this.buyMallSpecialIdUC})
      : super(BuyInitial()) {
    on<BuyItemEvent>(buy);
    on<BuyItemSpecialIdEvent>(buySpecialID);
  }

  FutureOr<void> buy(BuyItemEvent event, Emitter<MallBuyState> emit) async {
    emit(BuyLoadingState());
    final result = await buyUseCase(
      event.idItem,
    );

    result.fold(
      (left) {
        emit(BuyErrorState(massage: NetworkExceptions.getErrorMessage(left)));
      },
      (right) => emit(BuySuccessState(massage: right.message)),
    );
  }

  FutureOr<void> buySpecialID(
      BuyItemSpecialIdEvent event, Emitter<MallBuyState> emit) async {
    emit(BuyLoadingState());
    final result = await buyMallSpecialIdUC(event.idItem);

    result.fold(
      (left) => emit(BuyErrorState(massage: NetworkExceptions.getErrorMessage(left))),
      (right) {
        emit(BuySuccessState(massage: right.message));
        // The purchase spends coins and adds the item to the user's bag
        // server-side, but nothing refreshed local state after -- the
        // coin balance and "My Bag" list stayed stale until the user
        // manually reopened the bag or restarted the app. Same refresh
        // pattern the equip/unequip flow already uses.
        di<FetchUserDataBloc>().add(const FetchMyDataEvent());
        di<MyBagBloc>().add(const GetSpecialIdMyBagEvent());
      },
    );
  }
}