import 'package:general/src/features/room/presentation/gifts/view/component/lucky_gift/lucky_gift_animation.dart';

abstract class BaseLuckyGiftAnaimationManagerEvent {
  const BaseLuckyGiftAnaimationManagerEvent();
}

class LuckyGiftAnaimationManagerEvent
    extends BaseLuckyGiftAnaimationManagerEvent {
  final String image;
  final List<int> index;
  final List<String> ids;
  bool? fromRtm;
  final String reciverName;
  final String senderName;
  final String senderImage;
  final String? giftPrice;
  final int? giftPriceT;
  final int? giftNum;
  final int totalWin;
  final int totalPk;

  /// Optimistic local path: the sender's own seats are already laid out, so
  /// resolve them in a single pass and skip the 5×100ms render-box retry loop.
  /// The retry loop only matters for the RTM-received path where the recipient
  /// avatar may attach a frame later.
  final bool immediate;

  LuckyGiftAnaimationManagerEvent({
    this.giftPrice,
    required this.image,
    required this.index,
    required this.ids,
    this.fromRtm,
    required this.reciverName,
    required this.senderName,
    required this.giftNum,
    required this.giftPriceT,
    required this.totalWin,
    required this.senderImage,
    required this.totalPk,
    this.immediate = false,
  });
}

/// Re-broadcast the authoritative lucky-gift result to OTHER room members over
/// RTM WITHOUT animating the sender's own seats. The sender already animated
/// optimistically per-tap; the backend response only carries the win data
/// (giftNum / totalWin / totalPk) that other clients need, so this path just
/// forwards it and never feeds the sender's animation again.
class RebroadcastLuckyGiftEvent extends BaseLuckyGiftAnaimationManagerEvent {
  final String image;
  final List<int> index;
  final List<String> ids;
  final String reciverName;
  final String senderName;
  final String senderImage;
  final String? giftPrice;
  final int? giftPriceT;
  final int? giftNum;
  final int totalWin;
  final int totalPk;

  const RebroadcastLuckyGiftEvent({
    this.giftPrice,
    required this.image,
    required this.index,
    required this.ids,
    required this.reciverName,
    required this.senderName,
    required this.giftNum,
    required this.giftPriceT,
    required this.totalWin,
    required this.senderImage,
    required this.totalPk,
  });
}

class InitLuckyGiftAnaimationManagerEvent
    extends BaseLuckyGiftAnaimationManagerEvent {
  const InitLuckyGiftAnaimationManagerEvent();
}

class RemoveCompletedLuckyGiftAnimationEvent
    extends BaseLuckyGiftAnaimationManagerEvent {
  final LuckyGiftSeatAnimation animation;
  const RemoveCompletedLuckyGiftAnimationEvent(this.animation);
}
