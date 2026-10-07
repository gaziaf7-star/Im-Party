import 'package:general/src/features/profile/domain/entities/exchange_log_entity.dart';
import '../../../../core/utils/methods.dart';

class ExchangeLogItemModel extends ExchangeLogItemEntity {
  const ExchangeLogItemModel({
    required super.id,
    required super.diamonds,
    required super.exchange,
    super.date,
    super.status,
  });

  factory ExchangeLogItemModel.fromJson(Map<String, dynamic> json) {
    return ExchangeLogItemModel(
      id: parseValue<int>(json['id'], 0),
      diamonds: parseValue<num>(json['diamonds'] ?? json['diamond'], 0),
      exchange:
      parseValue<num>(json['exchange'] ?? json['coin'] ?? json['coins'], 0),
      date: json['created_at']?.toString() ?? json['date']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

class ExchangeLogModel extends ExchangeLogEntity {
  const ExchangeLogModel({required super.data});

  factory ExchangeLogModel.fromJson(dynamic json) {
    // Some list endpoints in this app return a bare List, others wrap it in
    // {"data": [...]}; the exact shape for this new endpoint wasn't in the
    // spec, so both are handled.
    final List list = (json is Map && json['data'] is List)
        ? json['data']
        : (json is List ? json : const []);
    return ExchangeLogModel(
      data: list
          .map((e) => ExchangeLogItemModel.fromJson(
          Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}