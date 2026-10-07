import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

class NowRoomModel extends NowRoomEntity {
  const NowRoomModel({
    super.isnInRoom,
    super.uid,
    super.inMine,
    super.roomStatus,
    super.id,
    super.roomName,
    super.roomCover,
    super.roomBackground,
    super.mode,
    super.giftPrice,
  });

  factory NowRoomModel.fromJson(Map<String, dynamic> json) {
    return NowRoomModel(
      isnInRoom: parseValue<bool>(json['is_in_room'], false),
      uid: parseValue<int>(json['uid'], 0),
      inMine: parseValue<bool>(json['is_mine'], false),
      roomStatus: parseValue<bool>(json['password_status'], false),
      id: parseValue<int>(json['id'], 0),
      roomName: parseValue<String>(json['room_name'], ''),
      roomCover: parseValue<String>(json['room_cover'], ''),
      roomBackground: parseValue<String>(json['room_background'], ''),
      mode: parseValue<String>(json['mode'], '').toString(),
      giftPrice: parseValue<String>(json['giftPrice'], ''),
    );
  }
}
