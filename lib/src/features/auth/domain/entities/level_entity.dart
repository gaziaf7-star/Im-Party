import 'package:equatable/equatable.dart';

class LevelEntity extends Equatable {
  final int? senderNum;
  final int? senderLevel;
  final int? nextSenderNum;
  final int? nextSenderLevel;
  final double? senderPer;
  final double? senderRemining;
  final num? remSenderLevel;
  final int? reciverNum;
  final int? reciverLevel;
  final num? nextReciverNum;
  final num? nextReciverLevel;
  final double? reciverPer;
  final num? remReceiverLevel;
  final String? senderImage;
  final String? receiverImage;
  final String? expSender;
  final String? expReceiver;
  final int? currentReceiver;
  final int? currentSender;

  const LevelEntity({
    this.currentReceiver,
    this.currentSender,
    this.senderNum,
    this.senderLevel,
    this.nextSenderNum,
    this.nextSenderLevel,
    this.senderPer,
    this.senderRemining,
    this.remSenderLevel,
    this.reciverNum,
    this.reciverLevel,
    this.nextReciverNum,
    this.nextReciverLevel,
    this.reciverPer,
    this.remReceiverLevel,
    this.senderImage,
    this.receiverImage,
    this.expSender,
    this.expReceiver,
  });

  @override
  List<Object?> get props =>
      [
        senderNum,
        senderLevel,
        nextSenderNum,
        nextSenderLevel,
        senderPer, senderRemining,
        remSenderLevel,
        reciverNum,
        reciverLevel,
        nextReciverNum,
        nextReciverLevel,
        reciverPer,
        remReceiverLevel,
        senderImage,
        receiverImage,
        expSender,
        expReceiver,
        currentSender,
        currentReceiver,
      ];
}
