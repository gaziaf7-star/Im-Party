part of 'lucky_box_bloc.dart';

abstract class LuckyBoxesEvents extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetLuckyBoxesEvent extends LuckyBoxesEvents {}

class SendLuckyBoxEvent extends LuckyBoxesEvents {
  final String boxId;
  final String roomId;
  final String quantity;

  SendLuckyBoxEvent({
    required this.boxId,
    required this.roomId,
    required this.quantity,
  });
}

class PickupLuckyBoxEvent extends LuckyBoxesEvents {
  final String boxId;

  PickupLuckyBoxEvent({required this.boxId});
}

class ResetPickupLuckyBoxEvent extends LuckyBoxesEvents {

  ResetPickupLuckyBoxEvent();
}

class SelectLuckyBoxCoins extends LuckyBoxesEvents {
  final int index;

  SelectLuckyBoxCoins({required this.index});
}

class SelectLuckyBoxQuantity extends LuckyBoxesEvents {
  final int index;

  SelectLuckyBoxQuantity({required this.index});
}

class SelectSuperBoxCoins extends LuckyBoxesEvents {
  final int index;

  SelectSuperBoxCoins({required this.index});
}

class ChangeTabBarState extends LuckyBoxesEvents {
  final bool isLuckyBox;

  ChangeTabBarState({required this.isLuckyBox});
}