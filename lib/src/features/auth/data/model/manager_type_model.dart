import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

class ManagerTypeModel extends ManagerTypeEntity {
  const ManagerTypeModel({
    required super.id,
    required super.name,
    required super.image,
    required super.description,
  });

  factory ManagerTypeModel.fromJson(Map<String, dynamic> json) {
    return ManagerTypeModel(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['name'], ''),
      image: parseValue<String>(json['img'], ''),
      description: parseValue<String>(json['description'], ''),
    );
  }
}
