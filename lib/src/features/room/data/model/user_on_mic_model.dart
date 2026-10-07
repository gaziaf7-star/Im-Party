import 'package:general/src/features/room/domain/entities/user_on_mic_entity.dart';

import '../../../../core/utils/methods.dart';

class UserOnMicModel extends UserOnMicEntity {

  const UserOnMicModel(
      {required super.id,
      required super.name,
      required super.img,
      required super.seatCondition});

  factory UserOnMicModel.fromJson(Map<String, dynamic> json) {
    return UserOnMicModel(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['name'], ''),
      img: parseValue<String>(json['img'], ''),
      seatCondition: parseValue<String>(json['seat_condition'], ''),
    );
  }

  @override
  List<Object?> get props => [id, name, img, seatCondition];
}
