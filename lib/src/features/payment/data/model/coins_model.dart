import 'package:general/src/features/payment/domain/entities/coins_entity.dart';

import '../../../../core/utils/methods.dart';

class PaymentGatewayModel extends PaymentGatewayEntity {
  const PaymentGatewayModel({
     super.id,
     super.title,
    super.photo,
     super.createdAt,
     super.updatedAt,
     super.coins,
     super.type,
  });

  factory PaymentGatewayModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? dateStr) {
      if (dateStr == null) return null;
      try {
        return DateTime.parse(dateStr);
      } catch (_) {
        return null;
      }
    }

    return PaymentGatewayModel(
      id: parseValue<int>(json['id'], 0),
      title: parseValue<String>(json['title'], ''),
      photo: parseValue<String>(json['photo'], ''),
      type: parseValue<String>(json['type'], ''),
      createdAt: parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: parseDate(json['updated_at']) ?? DateTime.now(),
      coins: json['coins'] != null
          ? (json['coins'] is List ? json['coins'] as List : const [])
          .whereType<Map<String, dynamic>>()
          .map((e) => CoinModel.fromJson(e))
          .toList()
          : <CoinModel>[],
    );
  }

}

class CoinModel extends CoinEntity {
  const CoinModel({
    required super.id,
    required super.usd,
    required super.coin,
    super.firstChargeCoin,
    super.status,
    super.discountCode,
    super.discountCodeExpireIn,
    super.extraValue,
    super.extraValueEndIn,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required super.sort,
    required super.paymentGatewayId,
  });


  factory CoinModel.fromJson(Map<String, dynamic> json) {
    return CoinModel(
      id: parseValue<int>(json['id'], 0),
      usd: parseValue<double>(json['usd'], 0.0),
      coin: parseValue<int>(json['coin'], 0),
      firstChargeCoin: parseValue<int>(json['first_charge_coin'], 0),
      status: parseValue<String>(json['status'], ''),
      discountCode: parseValue<String>(json['discount_code'], ''),
      discountCodeExpireIn: json['discount_code_expire_in'] != null
          ? DateTime.parse(json['discount_code_expire_in'])
          : null,
      extraValue: parseValue<int>(json['extra_value'], 0),
      extraValueEndIn: json['extra_value_end_in'] != null
          ? DateTime.parse(json['extra_value_end_in'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
      sort: parseValue<int>(json['sort'], 0),
      paymentGatewayId: parseValue<int>(json['payment_gateway_id'], 0),
    );
  }
}