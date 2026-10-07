import 'package:equatable/equatable.dart';

class SendLuckyBoxEntity extends Equatable {
  final int id;
  final UserLuckyBoxEntity user;
  final int coins;
  final String usersNum;
  final String type;
  final DateTime endTime;

  const SendLuckyBoxEntity({
    required this.id,
    required this.user,
    required this.coins,
    required this.usersNum,
    required this.type,
    required this.endTime,
  });

  @override
  List<Object?> get props => [
    id,
    user,
    coins,
    usersNum,
    type,
    endTime
  ];


}

class UserLuckyBoxEntity  extends Equatable {
  final int id;
  final String uuid;
  final String image;
  final String name;
  final bool isFollow;

  const UserLuckyBoxEntity({
    required this.id,
    required this.uuid,
    required this.image,
    required this.name,
    required this.isFollow,
  });

  @override
  List<Object?> get props => [
    id,
    uuid,
    image,
    name,
    isFollow
  ];


}
