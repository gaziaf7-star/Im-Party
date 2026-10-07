import 'package:equatable/equatable.dart';

class UnreadCounterEntity extends Equatable{
  final int systemMessage;
  final int officialMessage;
  final int followers;
  final int followeds;
  final int friend;
  final int visitor;
  final int mall;
  final int myBag;

  const UnreadCounterEntity({
    required this.systemMessage,
    required this.officialMessage,
    required this.followers,
    required this.followeds,
    required this.friend,
    required this.visitor,
    required this.mall,
    required this.myBag,
  });

  UnreadCounterEntity copyWith({
    int? systemMessage,
    int? officialMessage,
    int? followers,
    int? followeds,
    int? friend,
    int? visitor,
    int? mall,
    int? myBag,
  }) =>
      UnreadCounterEntity(
        systemMessage: systemMessage ?? this.systemMessage,
        officialMessage: officialMessage ?? this.officialMessage,
        followers: followers ?? this.followers,
        followeds: followeds ?? this.followeds,
        friend: friend ?? this.friend,
        visitor: visitor ?? this.visitor,
        mall: mall ?? this.mall,
        myBag: myBag ?? this.myBag,
      );

  @override
  List<Object?> get props => [
  systemMessage,
  officialMessage,
  followers,
  followeds,
  friend,
  visitor,
  mall,
  myBag,
  ];
}
