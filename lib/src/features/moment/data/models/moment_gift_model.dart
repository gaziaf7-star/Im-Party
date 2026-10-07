import 'package:general/src/features/moment/domain/entities/moment_gift.dart';

import '../../../../core/utils/methods.dart';

class MomentGiftModel extends MomentGiftEntity {
  const MomentGiftModel({
    required super.id,
    required super.uuid,
    required super.name,
    required super.image,
    required super.level,
    required super.totalNumGift,
  });

  factory MomentGiftModel.fromJson(Map<String, dynamic> json) {
    return MomentGiftModel(
      id: parseValue<int>(json['id'], 0),
      uuid: parseValue<String>(json['uuid'], ''),
      name: parseValue<String>(json['name'], ''),
      image: parseValue<String>(json['image'], ''),
      level: LevelUserModel.fromJson(
          json['level'] is Map<String, dynamic> ? json['level'] : {}),
      totalNumGift: parseValue<int>(json['total_num_gift'], 0),
    );
  }
}

class LevelUserModel extends LevelUserEntity {
  const LevelUserModel({
    required super.receiverNum,
    required super.receiverImg,
    required super.senderNum,
    required super.senderRem,
    required super.receiverRem,
    required super.senderImg,
    required super.receiverLevel,
    required super.nextReceiverNum,
    required super.nextReceiverLevel,
    required super.senderLevel,
    required super.nextSenderNum,
    required super.nextSenderLevel,
    required super.prevReceiverNum,
    required super.prevSenderNum,
    required super.currentReceiverNum,
    required super.currentSenderNum,
    required super.expSender,
    required super.expReceiver,
    required super.rt,
    required super.st,
    required super.rc,
    required super.sc,
    required super.receiverPer,
    required super.senderPer,
  });

  factory LevelUserModel.fromJson(Map<String, dynamic> json) {
    return LevelUserModel(
      receiverNum: parseValue<int>(json['receiver_num'], 0),
      receiverImg: parseValue<String>(json['receiver_img'], ''),
      senderNum: parseValue<int>(json['sender_num'], 0),
      senderRem: parseValue<int>(json['sender_rem'], 0),
      receiverRem: parseValue<int>(json['receiver_rem'], 0),
      senderImg: parseValue<String>(json['sender_img'], ''),
      receiverLevel: parseValue<int>(json['receiver_level'], 0),
      nextReceiverNum: parseValue<int>(json['next_receiver_num'], 0),
      nextReceiverLevel: parseValue<int>(json['next_receiver_level'], 0),
      senderLevel: parseValue<int>(json['sender_level'], 0),
      nextSenderNum: parseValue<int>(json['next_sender_num'], 0),
      nextSenderLevel: parseValue<int>(json['next_sender_level'], 0),
      prevReceiverNum: parseValue<int>(json['prev_receiver_num'], 0),
      prevSenderNum: parseValue<int>(json['prev_sender_num'], 0),
      currentReceiverNum: parseValue<int>(json['current_receiver_num'], 0),
      currentSenderNum: parseValue<int>(json['current_sender_num'], 0),
      expSender: parseValue<String>(json['exp-sender'], ''),
      expReceiver: parseValue<String>(json['exp-receiver'], ''),
      rt: parseValue<int>(json['rt'], 0),
      st: parseValue<int>(json['st'], 0),
      rc: parseValue<int>(json['rc'], 0),
      sc: parseValue<int>(json['sc'], 0),
      receiverPer: parseValue<int>(json['receiver_per'], 0),
      senderPer: parseValue<int>(json['sender_per'], 0),
    );
  }
}
