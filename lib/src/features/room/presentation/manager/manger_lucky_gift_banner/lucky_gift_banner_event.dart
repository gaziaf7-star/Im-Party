abstract class BaseLuckyGiftBannerEvent {
  const BaseLuckyGiftBannerEvent();
}

class SendLuckyGiftEvent extends BaseLuckyGiftBannerEvent {
  final String roomId;
  final String id;
  final String toUid;
  final String num;
  final String count;
  final String? nonce;

  SendLuckyGiftEvent(
      {required this.count,
      required this.roomId,
      required this.id,
      required this.toUid,
      required this.num,
      this.nonce,});
}

class EndBannerEvent extends BaseLuckyGiftBannerEvent {}
