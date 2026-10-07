part of 'diamond_bloc.dart';

class DiamondState extends Equatable {
  final ReplaceWithGoldModel? diamondData;
  final RequestState reqStateDiamond;
  final RequestState reqStateExchange;
  final String? messageDiamond;
  final String? messageExchange;
  final String? itemId;
  final int coins;
  final int diamonds;

  const DiamondState({
    this.diamondData,
    this.reqStateDiamond = RequestState.idle,
    this.reqStateExchange = RequestState.idle,
    this.messageDiamond = '',
    this.messageExchange = '',
    this.itemId = '',
    this.coins = 0,
    this.diamonds = 0,
  });

  DiamondState copyWith(
      {ReplaceWithGoldModel? diamondData,
      RequestState? reqStateDiamond,
      RequestState? reqStateExchange,
      String? messageDiamond,
      String? messageExchange,
      String? itemId,
      int? coins,
      int? diamonds}) {
    return DiamondState(
      diamondData: diamondData ?? this.diamondData,
      reqStateDiamond: reqStateDiamond ?? this.reqStateDiamond,
      reqStateExchange: reqStateExchange ?? this.reqStateExchange,
      messageDiamond: messageDiamond ?? this.messageDiamond,
      messageExchange: messageExchange ?? this.messageExchange,
      itemId: itemId ?? this.itemId,
      coins: coins ?? this.coins,
      diamonds: diamonds ?? this.diamonds,
    );
  }

  @override
  List<Object?> get props =>
      [
        diamondData,
        reqStateDiamond,
        reqStateExchange,
        messageDiamond,
        messageExchange,
        itemId,
        diamonds,
        coins
      ];
}
