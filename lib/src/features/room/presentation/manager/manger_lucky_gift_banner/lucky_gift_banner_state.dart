import 'package:general/src/features/room/data/model/lucky_gift_model.dart';

abstract class LuckyGiftBannerState {
  const LuckyGiftBannerState();
}

class LuckyGiftBannerInitial extends LuckyGiftBannerState {}

class SendLuckyGiftSucssesState extends LuckyGiftBannerState {
  final int giftNum;
  final LuckyGiftModel data;
  final int isFirst;
  final int totalWin;

  const SendLuckyGiftSucssesState(
      {required this.isFirst,
      required this.data,
      required this.giftNum,
      required this.totalWin});
}

class SendLuckyGiftErrorStateState extends LuckyGiftBannerState {
  final String error;

  const SendLuckyGiftErrorStateState({required this.error});
}

class CloseLuckyGiftBanner extends LuckyGiftBannerState {}

class SendLuckyGiftLoadingState extends LuckyGiftBannerState {
  int? giftNum;
  LuckyGiftModel? data;
  int? isFirst;
  int? totalWin;
  SendLuckyGiftLoadingState(
      {this.isFirst, this.data, this.giftNum, this.totalWin});
}
