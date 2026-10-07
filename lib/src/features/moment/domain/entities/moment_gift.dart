import 'package:equatable/equatable.dart';

class MomentGiftEntity extends Equatable {
  final int id;
  final String uuid;
  final String name;
  final String image;
  final LevelUserEntity level;
  final int totalNumGift;

  const MomentGiftEntity({
    required this.id,
    required this.uuid,
    required this.name,
    required this.image,
    required this.level,
    required this.totalNumGift,
  });

  @override
  List<Object?> get props => [
    id,
    uuid,
    name,
    image,
    level,
    totalNumGift,
  ];
}

class LevelUserEntity extends Equatable {
  final int receiverNum;
  final String receiverImg;
  final int senderNum;
  final int senderRem;
  final int receiverRem;
  final String senderImg;
  final int receiverLevel;
  final int nextReceiverNum;
  final int nextReceiverLevel;
  final int senderLevel;
  final int nextSenderNum;
  final int nextSenderLevel;
  final int prevReceiverNum;
  final int prevSenderNum;
  final int currentReceiverNum;
  final int currentSenderNum;
  final String expSender;
  final String expReceiver;
  final int rt;
  final int st;
  final int rc;
  final int sc;
  final int receiverPer;
  final int senderPer;

  const LevelUserEntity({
    required this.receiverNum,
    required this.receiverImg,
    required this.senderNum,
    required this.senderRem,
    required this.receiverRem,
    required this.senderImg,
    required this.receiverLevel,
    required this.nextReceiverNum,
    required this.nextReceiverLevel,
    required this.senderLevel,
    required this.nextSenderNum,
    required this.nextSenderLevel,
    required this.prevReceiverNum,
    required this.prevSenderNum,
    required this.currentReceiverNum,
    required this.currentSenderNum,
    required this.expSender,
    required this.expReceiver,
    required this.rt,
    required this.st,
    required this.rc,
    required this.sc,
    required this.receiverPer,
    required this.senderPer,
  });

  @override
  List<Object?> get props => [
    receiverNum,
    receiverImg,
    senderNum,
    senderRem,
    receiverRem,
    senderImg,
    receiverLevel,
    nextReceiverNum,
    nextReceiverLevel,
    senderLevel,
    nextSenderNum,
    nextSenderLevel,
    prevReceiverNum,
    prevSenderNum,
    currentReceiverNum,
    currentSenderNum,
    expSender,
    expReceiver,
    rt,
    st,
    rc,
    sc,
    receiverPer,
    senderPer,
  ];
}
