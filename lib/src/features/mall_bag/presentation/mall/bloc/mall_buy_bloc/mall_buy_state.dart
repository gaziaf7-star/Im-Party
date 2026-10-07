part of'mall_buy_bloc.dart';

abstract class MallBuyState extends Equatable {
  const MallBuyState();

  @override
  List<Object> get props => [];
}

class BuyInitial extends MallBuyState {}

class BuyLoadingState extends MallBuyState {}

class BuySuccessState extends MallBuyState {
  final String massage;
  const BuySuccessState({required this.massage});
}

class BuyErrorState extends MallBuyState {
  final String massage;
  const BuyErrorState({required this.massage});
}
