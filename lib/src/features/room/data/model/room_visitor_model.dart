import 'package:general/src/features/room/domain/entities/room_visitor_entity.dart';

import '../../../../core/utils/methods.dart';

class RoomVisitorModel extends RoomVisitorEntity{

  const RoomVisitorModel(
      {super.frameId,
      super.frame,
      super.hasColorName,
      super.id,
      super.image,
      super.name,
      super.receiverLevelImg,
      super.senderLevelImg,
      super.type,
      super.uuid,
      super.vipLevel});

  factory RoomVisitorModel.fromJson(Map<String, dynamic> json) {
    return RoomVisitorModel(
      frameId: parseValue<int>(json['frame_id'], 0),
      frame: parseValue<String>(json['frame'], ''),
      hasColorName: parseValue<bool>(json['has_color_name'], false),
      id: parseValue<int>(json['id'], 0),
      image: parseValue<String>(json['profile_image'], ''),
      name: parseValue<String>(json['name'], ''),
      receiverLevelImg: parseValue<String>(json['level']?['receiver_img'], ''),
      senderLevelImg: parseValue<String>(json['level']?['sender_img'], ''),
      type: parseValue<int>(json['type'], 2),
      uuid: parseValue<String>(json['uuid'], ''),
      vipLevel: parseValue<int>(json['vip']?['level'], 0),
    );
  }

}
