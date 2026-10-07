abstract class BaseLuckyGiftBannerForReciverEvent {
  const BaseLuckyGiftBannerForReciverEvent();
}

class LuckyGiftBannerForReciverEvent
    extends BaseLuckyGiftBannerForReciverEvent {
  final String receiverName;
  final String giftImage;
  final String senderName;
  final String senderImg;
  final int giftNum;
  final int totalWin;
  LuckyGiftBannerForReciverEvent(
      {required this.giftImage,
      required this.receiverName,
      required this.senderImg,
      required this.giftNum,
      required this.totalWin,
      required this.senderName});
}

class EndLuckyGiftBannerForReciverEvent
    extends BaseLuckyGiftBannerForReciverEvent {
  const EndLuckyGiftBannerForReciverEvent();
}
