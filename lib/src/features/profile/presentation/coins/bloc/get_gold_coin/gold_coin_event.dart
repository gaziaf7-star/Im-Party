part of'gold_coin_bloc.dart';

abstract class GoldCoinEvent extends Equatable {
  const GoldCoinEvent();

  @override
  List<Object?> get props => const [];
}
class GetGoldCoinDataEvent extends GoldCoinEvent{
  const GetGoldCoinDataEvent();
}
class SelectCoinDataEvent extends GoldCoinEvent{
  final String itemId;
  const SelectCoinDataEvent({required this.itemId});
}

// class RechargeCoinsEvent extends  GoldCoinEvent{
//   final String  packageCoinId ;
//   const RechargeCoinsEvent({required this.packageCoinId});

//    @override
//   List<Object?> get props =>  [packageCoinId];
// }