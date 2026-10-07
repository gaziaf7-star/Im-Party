import 'package:general/src/features/room/domain/entities/boom_rules_entity.dart';

class BombRulesResponse {
  final bool success;
  final String message;
  final List<BombRulesModel> data;

  const BombRulesResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BombRulesResponse.fromJson(Map<String, dynamic> json) {
    return BombRulesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] is List ? json['data'] as List : const [])
          .whereType<Map<String, dynamic>>()
          .map((e) => BombRulesModel.fromJson(e))
          .toList(),
    );
  }
}

class BombRulesModel extends BombRulesEntity {
  const BombRulesModel({
    required super.id,
    required super.rulesAr,
    required super.rulesEn,
    required super.content,
  });

  factory BombRulesModel.fromJson(Map<String, dynamic> json) {
    return BombRulesModel(
      id: json['id'] ?? 0,
      rulesAr: json['rules_ar'] ?? '',
      rulesEn: json['rules_en'] ?? '',
      content: json['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rules_ar': rulesAr,
      'rules_en': rulesEn,
      'content': content,
    };
  }
}
