import 'package:equatable/equatable.dart';

class SuperBombEntity extends Equatable {
  final bool success;
  final String message;
  final List<SuperBombDataEntity> data;

  const SuperBombEntity({
    required this.success,
    required this.message,
    required this.data,
  });

  @override
  List<Object?> get props => [success, message, data];
}

class SuperBombDataEntity extends Equatable {
  final int id;
  final int level;
  final int minTarget;
  final int target;
  final List<RoomBoomEntity> roomBooms;
  final List<RewardEntity> rewards;

  const SuperBombDataEntity({
    required this.id,
    required this.level,
    required this.minTarget,
    required this.target,
    required this.roomBooms,
    required this.rewards,
  });

  @override
  List<Object?> get props => [
        id,
        level,
        minTarget,
        target,
        roomBooms,
        rewards,
      ];
}

class RoomBoomEntity extends Equatable {
  final int id;
  final String startedAt;
  final String? endedAt;
  final String totalGiftsValue;
  final int? level;
  final List<TopContributorsEntity> topContributors;

  const RoomBoomEntity({
    required this.id,
    required this.startedAt,
    this.endedAt,
    required this.totalGiftsValue,
    this.level,
    required this.topContributors,
  });

  @override
  List<Object?> get props => [
        id,
        startedAt,
        endedAt,
        totalGiftsValue,
        level,
        topContributors,
      ];
}

class RewardEntity extends Equatable {
  final int id;
  final int priority;
  final String type;
  final String image;
  final String giftImageType;
  final String title;
  final int price;
  final int count;

  const RewardEntity({
    required this.id,
    required this.priority,
    required this.type,
    required this.image,
    required this.giftImageType,
    required this.title,
    required this.count,
    required this.price,
  });

  @override
  List<Object?> get props =>
      [id, priority, type, image, giftImageType, title, count, price];
}

class TopContributorsEntity extends Equatable {
  final int id;
  final String name;
  final String img;
  final String totalGift;
  final String? uuid;

  const TopContributorsEntity({
    required this.id,
    required this.name,
    required this.img,
    required this.totalGift,
    this.uuid,
  });

  @override
  List<Object?> get props => [id, name, img, totalGift, uuid];
}
