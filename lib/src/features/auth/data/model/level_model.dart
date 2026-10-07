import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

class LevelModel extends LevelEntity {
  const LevelModel({
    super.senderNum,
    super.senderLevel,
    super.nextSenderNum,
    super.nextSenderLevel,
    super.senderPer,
    super.senderRemining,
    super.remSenderLevel,
    super.reciverNum,
    super.reciverLevel,
    super.nextReciverNum,
    super.nextReciverLevel,
    super.reciverPer,
    super.remReceiverLevel,
    super.senderImage,
    super.receiverImage,
    super.expSender,
    super.expReceiver,
    super.currentReceiver,
    super.currentSender,
  });

  factory LevelModel.fromJson(Map<String, dynamic> map) {
    return LevelModel(
      senderNum: parseValue<int>(map['sender_num'], 0),
      senderLevel: parseValue<int>(map['sender_level'], 0),
      nextSenderNum: parseValue<int>(map['next_sender_num'], 0),
      nextSenderLevel: parseValue<int>(map['next_sender_level'], 0),
      senderPer: parseValue<double>(map['sender_per'], 0.0),
      senderRemining: parseValue<double>(map['remaining_to_next_level'], 0.0),
      remSenderLevel: parseValue<int>(map['sender_rem'], 0),
      reciverNum: parseValue<int>(map['receiver_num'], 0),
      reciverLevel: parseValue<int>(map['receiver_level'], 0),
      nextReciverNum: parseValue<int>(map['next_receiver_num'], 0),
      nextReciverLevel: parseValue<int>(map['next_receiver_level'], 0),
      reciverPer: parseValue<double>(map['receiver_per'], 0.0),
      remReceiverLevel: parseValue<int>(map['receiver_rem'], 0),
      senderImage: parseValue<String>(map['sender_img'], ''),
      receiverImage: parseValue<String>(map['receiver_img'], ''),
      expSender: parseValue<String>(map['exp-sender'], ''),
      expReceiver: parseValue<String>(map['exp_receiver'], ''),
      currentReceiver: parseValue<int>(map['current_receiver_num'], 0),
      currentSender: parseValue<int>(map['current_sender_num'], 0),
    );
  }

  LevelEntity toEntity() {
    return LevelEntity(
      senderNum: senderNum,
      senderLevel: senderLevel,
      nextSenderNum: nextSenderNum,
      nextSenderLevel: nextSenderLevel,
      senderPer: senderPer,
      remSenderLevel: remSenderLevel,
      reciverNum: reciverNum,
      reciverLevel: reciverLevel,
      nextReciverNum: nextReciverNum,
      nextReciverLevel: nextReciverLevel,
      reciverPer: reciverPer,
      remReceiverLevel: remReceiverLevel,
      senderImage: senderImage,
      receiverImage: receiverImage,
      expReceiver: expReceiver,
      expSender: expSender,
      currentReceiver: currentReceiver,
      currentSender: currentSender,
    );
  }
}
