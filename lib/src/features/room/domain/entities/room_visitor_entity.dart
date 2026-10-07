import 'package:equatable/equatable.dart';

class RoomVisitorEntity extends Equatable {
  final int? id;
  final String? uuid;
  final String? name;
  final String? image;
  final String? senderLevelImg;
  final String? receiverLevelImg;
  final int? vipLevel;
  final String? frame;
  final int? frameId;
  final bool? hasColorName;
  final int? type; // 0 owner, 1 admin, 2 visitor

  const RoomVisitorEntity({
    this.id,
    this.uuid,
    this.name,
    this.image,
    this.senderLevelImg,
    this.receiverLevelImg,
    this.vipLevel,
    this.frame,
    this.frameId,
    this.hasColorName,
    this.type,
  });

  @override
  List<Object?> get props => [
    id,
    uuid,
    name,
    image,
    senderLevelImg,
    receiverLevelImg,
    vipLevel,
    frame,
    frameId,
    hasColorName,
    type,
  ];
}
