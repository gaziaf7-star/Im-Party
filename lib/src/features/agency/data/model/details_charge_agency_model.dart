import 'package:general/src/features/agency/agency.dart';

import '../../../../../reels_viewer/reels_viewer.dart';

class DetailsChargeAgencyModel extends DetailsChargeAgencyEntity {
  const DetailsChargeAgencyModel({
    super.id,
    super.value,
    super.time,
    super.senderEntity,
    super.receiverEntity,
    super.stringValue,
  });

  factory DetailsChargeAgencyModel.fromJson(Map<String, dynamic> json) {
    return DetailsChargeAgencyModel(
      id: parseValue<int>(json['id'], 0),
      value: parseValue<int>(json['value'], 0),
      stringValue: parseValue<String>(json['value_string'], ''),
      time: parseValue<String>(json['time'], ''),
      senderEntity: json['sender'] is Map<String, dynamic> ? ReceiverModel.fromJson(json['sender']) : null,
      receiverEntity: json['receiver'] is Map<String, dynamic> ? ReceiverModel.fromJson(json['receiver']) : null,
    );
  }
}

class ReceiverModel extends ReceiverEntity {
  const ReceiverModel({
    super.id,
    super.uuid,
    super.name,
    super.img,
    super.type,
    super.idImage,
    super.imageColorEntity,
    super.colorNamed,
  });

  factory ReceiverModel.fromJson(Map<String, dynamic> json) {
    // Methods.printLog('Colored name is ${parseValue<String>(json['colored_name'], '')}');
    return ReceiverModel(
      id: parseValue<int>(json["id"], 0),
      uuid: parseValue<String>(json["uuid"], ''),
      name: parseValue<String>(json["name"], ''),
      img: parseValue<String>(json["image"], ''),
      type: parseValue<String>(json["type"], ''),
      idImage: parseValue<String>(json["id_image"], ''),
      colorNamed: parseValue<String>(json['colored_name'], ''),
      imageColorEntity: json["image_color"] is Map<String, dynamic>
          ? ImageColorModel.fromJson(json['image_color'])
          : null,
    );
  }
}
