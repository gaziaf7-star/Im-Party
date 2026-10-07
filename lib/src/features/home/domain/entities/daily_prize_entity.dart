import 'package:equatable/equatable.dart';

class DailyPrizesEntity extends Equatable {
  final int currentDay;
  final int totalDays;
  final List<GiftPerDayEntity> gifts;
  final bool isReceived;

  const DailyPrizesEntity({
    required this.currentDay,
    required this.totalDays,
    required this.gifts,
    required this.isReceived,
  });

  DailyPrizesEntity copyWith({
    bool? isReceived,
  }) {
    return DailyPrizesEntity(
      currentDay: currentDay,
      totalDays: totalDays,
      gifts: gifts,
      isReceived: isReceived ?? this.isReceived,
    );
  }

  @override
  List<Object?> get props => [
    currentDay,
    totalDays,
    gifts,
    isReceived,
  ];
}

class GiftPerDayEntity extends Equatable {
  final int day;
  final GiftEntity gift;

  const GiftPerDayEntity({
    required this.day,
    required this.gift,
  });

  @override
  List<Object?> get props => [day, gift];
}

class GiftEntity extends Equatable {
  final String name;
  final String image;

  const GiftEntity({
    required this.name,
    required this.image,
  });

  @override
  List<Object?> get props => [name, image];
}
