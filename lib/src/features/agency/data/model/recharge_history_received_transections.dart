import 'package:general/src/features/agency/agency.dart';

import '../../../../../reels_viewer/reels_viewer.dart';


class UserGoogleCoinsHistoryModel extends UserGoogleCoinsHistoryEntity {
  const UserGoogleCoinsHistoryModel({
    super.id,
    super.usd,
    super.coins,
    super.method,
    super.status,
    super.trxNum,
    super.date,
  });

  factory UserGoogleCoinsHistoryModel.fromJson(Map<String, dynamic> json) {
    return UserGoogleCoinsHistoryModel(
      id: parseValue<int>(json['id'] ,0),
      usd: parseValue<int>(json['usd'] ,0),
      coins: parseValue<int>(json['coins'],0) ,
      method: parseValue<String>(json['method'],'') ,
      status: parseValue<String>(json['status'],'') ,
      trxNum: parseValue<String>(json['trx_num'],'') ,
      date: parseValue<String>(json['date'] ,''),
    );
  }


}




class UerChargeCoinsHistoryModel extends UerChargeCoinsHistoryEntity {
  const UerChargeCoinsHistoryModel({
    super.id,
    super.sender,
    super.coins,
    super.usd,
    super.time,
  });

  factory UerChargeCoinsHistoryModel.fromJson(Map<String, dynamic> json) {
    return UerChargeCoinsHistoryModel(
      id: parseValue<dynamic>(json['id'],''),
      sender: json['sender'] is Map<String, dynamic>
          ? SenderDataModel.fromJson(json['sender'])
          : const SenderDataEntity(),
      coins: parseValue<dynamic>(json['value'],''),
      usd: parseValue<dynamic>(json['usd'],''),
      time: parseValue<String>(json['time'],'') ,
    );
  }

}


class SenderDataModel extends SenderDataEntity {
  const SenderDataModel({
    super.id,
    super.uuid,
    super.name,
    super.img,
    super.type,
  });

  factory SenderDataModel.fromJson(Map<String, dynamic> json) {
    return SenderDataModel(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? 0,
      name: parseValue<String>(json['name'],'') ,
      img: parseValue<String>(json['img'] ,''),
      type: parseValue<String>(json['type'] ,''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'img': img,
      'type': type,
    };
  }
}

