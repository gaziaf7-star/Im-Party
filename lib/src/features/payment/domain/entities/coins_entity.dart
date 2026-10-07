import 'package:equatable/equatable.dart';

class PaymentGatewayEntity extends Equatable {
  final int? id;
  final String? title;
  final String? photo;
  final String? type;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<CoinEntity>? coins;

  const PaymentGatewayEntity({
     this.id,
     this.title,
    this.photo,
    this.type,
     this.createdAt,
     this.updatedAt,
     this.coins,
  });

  @override
  List<Object?> get props => [id, title, photo, type,createdAt, updatedAt, coins];
}

class CoinEntity extends Equatable {
  final int id;
  final double usd;
  final int coin;
  final int? firstChargeCoin;
  final String? status;
  final String? discountCode;
  final DateTime? discountCodeExpireIn;
  final int? extraValue;
  final DateTime? extraValueEndIn;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int sort;
  final int paymentGatewayId;

  const CoinEntity({
    required this.id,
    required this.usd,
    required this.coin,
    this.firstChargeCoin,
    this.status,
    this.discountCode,
    this.discountCodeExpireIn,
    this.extraValue,
    this.extraValueEndIn,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.sort,
    required this.paymentGatewayId,
  });

  @override
  List<Object?> get props => [
        id,
        usd,
        coin,
        firstChargeCoin,
        status,
        discountCode,
        discountCodeExpireIn,
        extraValue,
        extraValueEndIn,
        createdAt,
        updatedAt,
        deletedAt,
        sort,
        paymentGatewayId,
      ];
}