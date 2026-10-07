part of'mall_buy_bloc.dart';

abstract class MallBuyEvent extends Equatable {
  const MallBuyEvent();

  @override
  List<Object> get props => [];
}

class BuyItemEvent extends MallBuyEvent {
  final String idItem;

  const BuyItemEvent({
    required this.idItem,
  });
}

class BuyItemSpecialIdEvent extends MallBuyEvent {
  final int idItem;

  const BuyItemSpecialIdEvent({
    required this.idItem,
  });
}
