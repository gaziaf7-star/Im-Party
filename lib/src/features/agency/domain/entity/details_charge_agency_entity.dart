import 'package:equatable/equatable.dart';
import 'package:general/src/features/auth/domain/entities/my_data_entity.dart';

class DetailsChargeAgencyEntity extends Equatable {
  final int? id;
  final int? value;
  final String? time;
  final String? stringValue;

  final ReceiverEntity? senderEntity;
  final ReceiverEntity? receiverEntity;

  const DetailsChargeAgencyEntity({
    this.id,
    this.value,
    this.time,
    this.senderEntity,
    this.receiverEntity,
    this.stringValue,
  });

  @override
  List<Object?> get props =>
      [id, value, time, senderEntity, receiverEntity, stringValue];
}

class ReceiverEntity extends Equatable {
  final int? id;
  final String? uuid;
  final String? name;
  final String? img;
  final String? type;
  final String? idImage;
  final String? colorNamed;
  final ImageColorEntity? imageColorEntity;

  const ReceiverEntity({
    required this.id,
    required this.uuid,
    required this.name,
    required this.img,
    required this.type,
    required this.idImage,
    required this.colorNamed,
    required this.imageColorEntity,
  });

  @override
  List<Object?> get props =>
      [id, uuid, name, img, type, imageColorEntity, idImage,colorNamed];
}
