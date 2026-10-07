part of 'lucky_box_bloc.dart';

class LuckyBoxState extends Equatable {
  final RequestState? getLuckyBoxReqState;
  final String? getLuckyBoxMessage;
  final LuckyBoxEntity? boxData;

  final RequestState? sendLuckyBoxReqState;
  final String? message;
  final SendLuckyBoxEntity? sendLuckyBoxEntity;

  final RequestState? pickUpLuckyBoxReqState;
  final String? pickUpLuckyBoxMessage;
  final PickUpLuckyBoxEntity? pickUpLuckyBoxEntity;

  final String? luckyBoxItem;
  final List<String>? luckyBoxList;
  final String? luckyBoxQuantity;
  final String? superBoxCoins;
  final int? indexItemSelectedNormal;
  final int? indexItemSelectedSuper;

  final bool? isLuckyBoxTap;

  const LuckyBoxState({
    this.getLuckyBoxReqState = RequestState.idle,
    this.getLuckyBoxMessage,
    this.boxData,
    this.sendLuckyBoxReqState = RequestState.idle,
    this.message,
    this.sendLuckyBoxEntity,
    this.pickUpLuckyBoxReqState = RequestState.idle,
    this.pickUpLuckyBoxMessage,
    this.pickUpLuckyBoxEntity,
    this.luckyBoxItem = '',
    this.luckyBoxQuantity = '',
    this.superBoxCoins = '',
    this.luckyBoxList = const [],
    this.isLuckyBoxTap = true,
    this.indexItemSelectedNormal = 0,
    this.indexItemSelectedSuper = 0,
  });

  LuckyBoxState copyWith({
    RequestState? getLuckyBoxReqState,
    String? getLuckyBoxMessage,
    LuckyBoxEntity? boxData,
    RequestState? sendLuckyBoxReqState,
    String? sendLuckyBoxMessage,
    SendLuckyBoxEntity? sendLuckyBoxEntity,
    RequestState? pickUpLuckyBoxReqState,
    String? pickUpLuckyBoxMessage,
    PickUpLuckyBoxEntity? pickUpLuckyBoxEntity,
    String? luckyBoxItem,
    List<String>? luckyBoxList,
    String? luckyBoxQuantity,
    String? superBoxCoins,
    bool? isLuckyBoxTap,
    int? indexItemSelectedNormal,
    int? indexItemSelectedSuper,
  }) {
    return LuckyBoxState(
      getLuckyBoxReqState: getLuckyBoxReqState ?? this.getLuckyBoxReqState,
      getLuckyBoxMessage: getLuckyBoxMessage ?? this.getLuckyBoxMessage,
      boxData: boxData ?? this.boxData,
      sendLuckyBoxReqState: sendLuckyBoxReqState ?? this.sendLuckyBoxReqState,
      message: sendLuckyBoxMessage ?? message,
      sendLuckyBoxEntity: sendLuckyBoxEntity ?? this.sendLuckyBoxEntity,
      pickUpLuckyBoxReqState:
          pickUpLuckyBoxReqState ?? this.pickUpLuckyBoxReqState,
      pickUpLuckyBoxMessage:
          pickUpLuckyBoxMessage ?? this.pickUpLuckyBoxMessage,
      pickUpLuckyBoxEntity: pickUpLuckyBoxEntity ?? this.pickUpLuckyBoxEntity,
      luckyBoxItem: luckyBoxItem ?? this.luckyBoxItem,
      luckyBoxQuantity: luckyBoxQuantity ?? this.luckyBoxQuantity,
      superBoxCoins: superBoxCoins ?? this.superBoxCoins,
      isLuckyBoxTap: isLuckyBoxTap ?? this.isLuckyBoxTap,
      luckyBoxList: luckyBoxList ?? this.luckyBoxList,
      indexItemSelectedNormal:
          indexItemSelectedNormal ?? this.indexItemSelectedNormal,
      indexItemSelectedSuper:
          indexItemSelectedSuper ?? this.indexItemSelectedSuper,
    );
  }

  @override
  List<Object?> get props => [
        getLuckyBoxReqState,
        getLuckyBoxMessage,
        boxData,
        sendLuckyBoxReqState,
        message,
        sendLuckyBoxEntity,
        pickUpLuckyBoxReqState,
        pickUpLuckyBoxMessage,
        pickUpLuckyBoxEntity,
        luckyBoxItem,
        luckyBoxQuantity,
        superBoxCoins,
        isLuckyBoxTap,
        luckyBoxList,
        indexItemSelectedNormal,
        indexItemSelectedSuper
      ];
}
