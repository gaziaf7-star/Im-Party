import 'package:equatable/equatable.dart';
import 'package:general/src/features/auth/domain/entities/my_data_entity.dart';

class CarouselEntity extends Equatable {
  final int id;
  final String type;
  final String img;
  final String? url;
  final String? avatar;
  final String? cpAvatar2;
  final String? cpName;
  final String? cpName2;
  final String? eventType;
  final int? ownerId;
  final bool? hasPassword;
  final MyRoomEntity? myRoomData;

  const CarouselEntity({
    required this.id,
    required this.img,
    required this.type,
    this.url,
    this.ownerId,
    this.myRoomData,
    this.hasPassword,
    this.avatar,
    this.cpAvatar2,
    this.cpName,
    this.cpName2,
    this.eventType,
  });

  @override
  List<Object?> get props => [
    id,
    img,
    type,
    ownerId,
    hasPassword,
    url,
    avatar,
    eventType,
    cpName2,cpName,cpAvatar2
  ];
}
