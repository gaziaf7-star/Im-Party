import 'package:general/src/features/room/domain/entities/super_bomb_entity.dart';
import '../../../../core/utils/methods.dart';

class SuperBombModel extends SuperBombEntity {
  const SuperBombModel({
    required super.success,
    required super.message,
    required super.data,
  });

  factory SuperBombModel.fromJson(Map<String, dynamic> json) {
    return SuperBombModel(
      success: parseValue<bool>(json['success'], false),
      message: parseValue<String>(json['message'], ''),
      data: json['data'] is List
          ? List<SuperBombDataModel>.from(
              (json['data'] as List)
                  .whereType<Map<String, dynamic>>()
                  .map(
                    (element) => SuperBombDataModel.fromJson(element),
                  ),
            )
          : <SuperBombDataModel>[],
    );
  }

  SuperBombModel copyWith({
    bool? success,
    String? message,
    List<SuperBombDataModel>? data,
  }) {
    return SuperBombModel(
      success: success ?? this.success,
      message: message ?? this.message,
      data: data ?? (this.data as List<SuperBombDataModel>),
    );
  }
}

class SuperBombDataModel extends SuperBombDataEntity {
  const SuperBombDataModel({
    required super.id,
    required super.level,
    required super.minTarget,
    required super.target,
    required super.roomBooms,
    required super.rewards,
  });

  factory SuperBombDataModel.fromJson(Map<String, dynamic> json) {
    return SuperBombDataModel(
      id: parseValue<int>(json['id'], 0),
      level: parseValue<int>(json['level'], 0),
      minTarget: parseValue<int>(json['min_target'], 0),
      target: parseValue<int>(json['target'], 0),
      roomBooms: json['room_booms'] is List
          ? List<RoomBoomModel>.from(
              (json['room_booms'] as List)
                  .whereType<Map<String, dynamic>>()
                  .map(
                    (element) => RoomBoomModel.fromJson(element),
                  ),
            )
          : <RoomBoomModel>[],
      rewards: json['rewards'] is List
          ? List<RewardModel>.from(
              (json['rewards'] as List)
                  .whereType<Map<String, dynamic>>()
                  .map(
                    (element) => RewardModel.fromJson(element),
                  ),
            )
          : <RewardModel>[],
     
    );
  }

  SuperBombDataModel copyWith({
    int? id,
    int? level,
    int? minTarget,
    int? target,
    List<RoomBoomModel>? roomBooms,
    List<RewardModel>? rewards,
    
  }) {
    return SuperBombDataModel(
      id: id ?? this.id,
      level: level ?? this.level,
      minTarget: minTarget ?? this.minTarget,
      target: target ?? this.target,
      roomBooms: roomBooms ?? (this.roomBooms as List<RoomBoomModel>),
      rewards: rewards ?? (this.rewards as List<RewardModel>),
   
    );
  }
}

class RoomBoomModel extends RoomBoomEntity {
  const RoomBoomModel({
    required super.id,
    required super.startedAt,
    super.endedAt,
    required super.totalGiftsValue,
    super.level,
    required super.topContributors,
  });

  factory RoomBoomModel.fromJson(Map<String, dynamic> json) {
    return RoomBoomModel(
      id: parseValue<int>(json['id'], 0),
      startedAt: parseValue<String>(json['started_at'], ''),
      endedAt: parseValue<String?>(json['ended_at'], null),
      totalGiftsValue: parseValue<String>(json['total_gifts_value'], ''),
      level: parseValue<int?>(json['level'], null),
      topContributors: json['top_contributors'] is List
          ? List<TopContributorsModel>.from(
              (json['top_contributors'] as List)
                  .whereType<Map<String, dynamic>>()
                  .map(
                    (element) => TopContributorsModel.fromJson(element),
                  ),
            )
          : <TopContributorsModel>[],
    );
  }

  RoomBoomModel copyWith({
    int? id,
    String? startedAt,
    String? endedAt,
    String? totalGiftsValue,
    int? level,
    List<TopContributorsModel>? topContributors,
  }) {
    return RoomBoomModel(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      totalGiftsValue: totalGiftsValue ?? this.totalGiftsValue,
      level: level ?? this.level,
      topContributors: topContributors ??
          (this.topContributors as List<TopContributorsModel>),
    );
  }
}

class RewardModel extends RewardEntity {
  const RewardModel({
    required super.id,
    required super.priority,
    required super.type,
    required super.image,
    required super.giftImageType,
    required super.title,
    required super.count,
    required super.price,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: parseValue<int>(json['id'], 0),
      priority: parseValue<int>(json['priority'], 0),
      type: parseValue<String>(json['type'], ''),
      image: parseValue<String>(json['image'], ''),
      giftImageType: parseValue<String>(json['gift_image_type'], ''),
      title: parseValue<String>(json['title'], ''),
      count: parseValue<int>(json['count'], 0),
      price: parseValue<int>(json['price'], 0),
    );
  }

  RewardModel copyWith({
    int? id,
    int? priority,
    String? type,
    String? image,
    String? giftImageType,
    String? title,
    int? count,
    int? price,
  }) {
    return RewardModel(
      id: id ?? this.id,
      priority: priority ?? this.priority,
      type: type ?? this.type,
      image: image ?? this.image,
      giftImageType: giftImageType ?? this.giftImageType,
      title: title ?? this.title,
      count: count ?? this.count,
      price: price ?? this.price,
    );
  }
}

class TopContributorsModel extends TopContributorsEntity {
  const TopContributorsModel({
    required super.id,
    required super.name,
    required super.img,
    required super.totalGift,
    super.uuid,
  });

  factory TopContributorsModel.fromJson(Map<String, dynamic> json) {
    return TopContributorsModel(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['name'], ""),
      img: parseValue<String>(json['img'], ''),
      totalGift: parseValue<String>(json['total_gift'], ''),
      uuid: parseValue<String?>(json['uuid'], null),
    );
  }

  TopContributorsModel copyWith({
    int? id,
    String? name,
    String? img,
    String? totalGift,
    String? uuid,
  }) {
    return TopContributorsModel(
      id: id ?? this.id,
      name: name ?? this.name,
      img: img ?? this.img,
      totalGift: totalGift ?? this.totalGift,
      uuid: uuid ?? this.uuid,
    );
  }
}
