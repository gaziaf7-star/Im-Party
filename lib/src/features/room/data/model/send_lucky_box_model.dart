import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/entities/send_lucky_box_entity.dart';

class SendLuckyBoxModel extends SendLuckyBoxEntity {
  const SendLuckyBoxModel({
    required super.id,
    required super.user,
    required super.coins,
    required super.usersNum,
    required super.type,
    required super.endTime,
  });

  factory SendLuckyBoxModel.fromJson(Map<String, dynamic> json) {
    return SendLuckyBoxModel(
      id: parseValue<int>(json['id'], 0),
      user: UserLuckyBoxModel.fromJson(
          json['user'] is Map<String, dynamic> ? json['user'] : {}),
      coins: parseValue<int>(json['coins'], 0),
      usersNum: parseValue<String>(json['users_num'], ""),
      type: parseValue<String>(json['type'], ""),
      endTime: DateTime.parse(json['end_time'] ?? ""),
    );
  }
}

class UserLuckyBoxModel extends UserLuckyBoxEntity {
  const UserLuckyBoxModel({
    required super.id,
    required super.uuid,
    required super.image,
    required super.name,
    required super.isFollow,
  });

  factory UserLuckyBoxModel.fromJson(Map<String, dynamic> json) {
    return UserLuckyBoxModel(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      image: json['image'] ?? '',
      name: json['name'] ?? '',
      isFollow: json['is_follow'] ?? false,
    );
  }
}
