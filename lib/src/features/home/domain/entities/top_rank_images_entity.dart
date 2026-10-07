import 'package:equatable/equatable.dart';


class TopRankImagesEntity extends Equatable {
  final List<String> sender;
  final List<String> receiver;
  final List<String> room;
  final List<TopCpEntity> topCpEntity;
  final List<TopGamersEntity> topGamers;

  const TopRankImagesEntity({
    required this.sender,
    required this.receiver,
    required this.room,
    required this.topCpEntity,
    required this.topGamers,
  });

  @override
  List<Object?> get props => [sender, receiver, room,topGamers];
}

class TopCpEntity extends Equatable{
  final UserEntity? userOne;
  final UserEntity? userTwo;

  const TopCpEntity({this.userOne, this.userTwo});

  @override
  List<Object?> get props => [
    userOne,
    userTwo
  ];


}


class UserEntity  extends Equatable{
 final String? image;

 const UserEntity(
      {
        this.image,});

  @override
  List<Object?> get props => [
    image,
  ];


}

class TopGamersEntity  extends Equatable{
 final String? image;

 const TopGamersEntity(
      {
        this.image,});

  @override
  List<Object?> get props => [
    image,
  ];


}
