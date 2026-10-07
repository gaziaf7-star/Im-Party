import 'package:general/src/features/room/domain/entities/charisma_entity.dart';
import '../../../../core/utils/methods.dart';

class CharismaModel extends CharismaEntity {
  const CharismaModel({
    required super.userId,
    required super.total,
    required super.position,
    super.totalValue,
  });

  factory CharismaModel.fromJson(Map<String, dynamic> json) {
    // Prefer the precise integer (total_value) when present; fall back to
    // reversing the abbreviated string for older senders that don't ship it.
    final int totalValue = json['total_value'] != null
        ? parseValue<int>(json['total_value'], 0)
        : Methods().convertFromAbbreviatedString(
            parseValue<String>(json['total'], "0"),
          );
    return CharismaModel(
      userId: parseValue<int>(json['user_id'], 0),
      total: parseValue<String>(json['total'], "0"),
      position: parseValue<int>(json['position'], 0),
      totalValue: totalValue,
    );
  }
}

class CharismaExtraDataModel extends CharismaExtraDataEntity {
  const CharismaExtraDataModel({required super.charisma});

  factory CharismaExtraDataModel.fromJson(Map<String, dynamic> json) {
    return CharismaExtraDataModel(
      charisma: json['charisma'] is List
          ? (json['charisma'] as List)
              .whereType<Map<String, dynamic>>()
              .map((element) => CharismaModel.fromJson(element))
              .toList()
          : null,
    );
  }

  @override
  List<Object?> get props => [charisma];
}
