import 'package:general/src/core/index.dart';

import '../../domain/entities/room_types_entity.dart';

class RoomTypesModel extends RoomTypesEntity {
  const RoomTypesModel(
      {required super.id, required super.name, required super.image});

  factory RoomTypesModel.fromJson(Map<String, dynamic> json) {
    return RoomTypesModel(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['name'], ''),
      image: parseValue<String>(json['img'], ''),
    );
  }

  @override
  List<Object?> get props => [id, name, image];
}
