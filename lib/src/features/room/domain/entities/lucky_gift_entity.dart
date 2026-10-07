import 'package:equatable/equatable.dart';

class LuckyGiftEntity extends Equatable {
  final String? giftImage;
  final String? giftName;
  final String? receiverName;
  final int? senderId;
  final int? giftNum;
  final int? giftPriceT;
  final String? senderName;
  final String? senderImg;
  final List<int>? position;
  final List<String>? receiversId;
  final List<ComboEntity>? combo;
  final String? giftPrice;
  final String? userCoins;
  final int? winTimes;
  final int? totalWin;
  final int? totalPk;

  const LuckyGiftEntity({
    this.giftImage,
    this.giftName,
    this.receiverName,
    this.senderId,
    this.senderName,
    this.senderImg,
    this.position,
    this.receiversId,
    this.combo,
    this.giftPrice,
    this.userCoins,
    this.giftNum,
    this.giftPriceT,
    this.winTimes,
    this.totalWin,
    this.totalPk,
  });

  @override
  List<Object?> get props => [
    giftImage,
    giftName,
    receiverName,
    senderId,
    senderName,
    senderImg,
    position,
    receiversId,
    combo,
    giftPrice,
    userCoins,
    giftNum,
    giftPriceT,
    winTimes,
    totalWin,
    totalPk,
  ];
}

class ComboEntity extends Equatable {
  final int? status;
  final WinDataEntity? data;
  final String? errorMessage;

  const ComboEntity({
    this.status,
    this.data,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, data, errorMessage];
}


class WinDataEntity extends Equatable {
  final int? winCoins;
  final bool? isWin;
  final int? winMultiplier;
  final bool? isPopular;
  final String? commentMessage;
  final String? winnerMessage;

  const WinDataEntity({
    this.winCoins,
    this.isWin,
    this.winMultiplier,
    this.isPopular,
    this.commentMessage,
    this.winnerMessage,
  });

  @override
  List<Object?> get props =>
      [winCoins, isWin, winMultiplier, isPopular, commentMessage, winnerMessage];
}


