import 'package:equatable/equatable.dart';

class UserOnMicEntity extends Equatable {
  final int id;
  final String name;
  final String img;
  final String seatCondition;

  const UserOnMicEntity({
    required this.id,
    required this.name,
    required this.img,
    required this.seatCondition,
  });

  @override
  List<Object?> get props => [id, name, img, seatCondition];
}
