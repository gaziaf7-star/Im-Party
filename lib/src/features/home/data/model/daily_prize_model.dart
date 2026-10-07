import 'package:general/src/features/home/domain/entities/daily_prize_entity.dart';

import '../../../../../reels_viewer/reels_viewer.dart';

class DailyPrizesModel extends DailyPrizesEntity {
  const DailyPrizesModel({
    required super.currentDay,
    required super.totalDays,
    required super.gifts,
    required super.isReceived,
  });

  factory DailyPrizesModel.fromJson(Map<String, dynamic> json) {
    return DailyPrizesModel(
      currentDay: parseValue<int>(json['current_day'], 0),
      totalDays: parseValue<int>(json['total_days'], 0),
      gifts: (json['gift'] is List ? json['gift'] as List : const [])
          .whereType<Map<String, dynamic>>()
          .map((e) => GiftPerDayModel.fromJson(e))
          .toList(),
      isReceived: parseValue<bool>(json['is_received'], false),
    );
  }
}

class GiftPerDayModel extends GiftPerDayEntity {
  const GiftPerDayModel({
    required super.day,
    required super.gift,
  });

  factory GiftPerDayModel.fromJson(Map<String, dynamic> json) {
    return GiftPerDayModel(
      day: parseValue<int>(json['day'], 0),
      gift: GiftModel.fromJson(
          json['gift'] is Map<String, dynamic> ? json['gift'] : const {}),
    );
  }
}

class GiftModel extends GiftEntity {
  const GiftModel({
    required super.name,
    required super.image,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      name: parseValue<String>(json['name'], ''),
      image: parseValue<String>(json['image'], ''),
    );
  }
}