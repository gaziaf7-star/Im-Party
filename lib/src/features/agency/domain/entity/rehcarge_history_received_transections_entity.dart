import 'package:equatable/equatable.dart';

class UserGoogleCoinsHistoryEntity extends Equatable {
  final int? id;
  final dynamic usd;
  final int? coins;
  final String? method;
  final String? status;
  final String? trxNum;
  final String? date;

  const UserGoogleCoinsHistoryEntity({
    this.id,
    this.usd,
    this.coins,
    this.method,
    this.status,
    this.trxNum,
    this.date,
  });

  @override
  List<Object?> get props => [id, usd, coins, method, status, trxNum, date];

  UserGoogleCoinsHistoryEntity copyWith({
    int? id,
    dynamic usd,
    int? coins,
    String? method,
    String? status,
    String? trxNum,
    String? date,
  }) {
    return UserGoogleCoinsHistoryEntity(
      id: id ?? this.id,
      usd: usd ?? this.usd,
      coins: coins ?? this.coins,
      method: method ?? this.method,
      status: status ?? this.status,
      trxNum: trxNum ?? this.trxNum,
      date: date ?? this.date,
    );
  }
}


class UerChargeCoinsHistoryEntity extends Equatable {
  final dynamic id;
  final SenderDataEntity? sender;
  final dynamic coins;
  final dynamic usd;
  final String? time;

  const UerChargeCoinsHistoryEntity({
    this.id,
    this.sender,
    this.coins,
    this.usd,
    this.time,
  });

  @override
  List<Object?> get props => [id, sender, coins, usd, time];

  UerChargeCoinsHistoryEntity copyWith({
    dynamic id,
    SenderDataEntity? sender,
    dynamic coins,
    dynamic usd,
    String? time,
  }) {
    return UerChargeCoinsHistoryEntity(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      coins: coins ?? this.coins,
      usd: usd ?? this.usd,
      time: time ?? this.time,
    );
  }
}


class SenderDataEntity extends Equatable {
  final dynamic id;
  final dynamic uuid;
  final String? name;
  final String? img;
  final String? type;

  const SenderDataEntity({
    this.id,
    this.uuid,
    this.name,
    this.img,
    this.type,
  });

  @override
  List<Object?> get props => [id, uuid, name, img, type];

  SenderDataEntity copyWith({
    dynamic id,
    dynamic uuid,
    String? name,
    String? img,
    String? type,
  }) {
    return SenderDataEntity(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      img: img ?? this.img,
      type: type ?? this.type,
    );
  }
}


