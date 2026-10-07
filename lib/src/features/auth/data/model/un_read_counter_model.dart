import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/domain/entities/un_read_counter_entity.dart';

class UnreadCounterModel extends UnreadCounterEntity {
  const UnreadCounterModel({
    required super.systemMessage,
    required super.officialMessage,
    required super.followers,
    required super.followeds,
    required super.friend,
    required super.visitor,
    required super.mall,
    required super.myBag,
  });

  @override
  UnreadCounterModel copyWith({
    int? systemMessage,
    int? officialMessage,
    int? followers,
    int? followeds,
    int? friend,
    int? visitor,
    int? mall,
    int? myBag,
  }) =>
      UnreadCounterModel(
        systemMessage: systemMessage ?? this.systemMessage,
        officialMessage: officialMessage ?? this.officialMessage,
        followers: followers ?? this.followers,
        followeds: followeds ?? this.followeds,
        friend: friend ?? this.friend,
        visitor: visitor ?? this.visitor,
        mall: mall ?? this.mall,
        myBag: myBag ?? this.myBag,
      );

  factory UnreadCounterModel.fromJson(Map<String, dynamic> json) {
    return UnreadCounterModel(
      systemMessage: parseValue<int>(json['system_message'], 0),
      officialMessage: parseValue<int>(json['official_message'], 0),
      followers: parseValue<int>(json['followers'], 0),
      followeds: parseValue<int>(json['followeds'], 0),
      friend: parseValue<int>(json['friend'], 0),
      visitor: parseValue<int>(json['visitor'], 0),
      mall: parseValue<int>(json['mall'], 0),
      myBag: parseValue<int>(json['bag'], 0),
    );
  }
}
