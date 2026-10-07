abstract class LuckyGiftBannerForReciverState {}

class LuckyGiftBannerForReciverInitial extends LuckyGiftBannerForReciverState {}

class LuckyGiftBannerForReciverSucssesState
    extends LuckyGiftBannerForReciverState {
  final int giftNum;
  final String receiverName;
  final String giftImage;
  final int isFirst;
  final String senderName;
  final String senderImg;
  final int totalWin;

  LuckyGiftBannerForReciverSucssesState(
      {required this.giftNum,
      required this.giftImage,
      required this.receiverName,
      required this.isFirst,
      required this.senderName,
      required this.totalWin,
      required this.senderImg});
}
