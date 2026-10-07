import 'package:general/src/core/index.dart';

class NowRoomEntity extends Equatable {
  final bool? isnInRoom;
  final int? uid;
  final bool? inMine;
  final bool? roomStatus;
  final int? id;
  final String? roomName;
  final String? roomCover;
  final String? roomBackground;
  final String? mode;
  final String? giftPrice;

  const NowRoomEntity({
    this.isnInRoom,
    this.uid,
    this.inMine,
    this.roomStatus,
    this.id,
    this.roomName,
    this.roomCover,
    this.roomBackground,
    this.mode,
    this.giftPrice,
  });

  @override
  List<Object?> get props => [isnInRoom, uid, inMine, roomStatus, id, roomName, roomCover, roomBackground, mode, giftPrice];
}
