import 'package:general/src/features/profile/domain/entities/bill_entity.dart';

import '../../../../core/utils/methods.dart';

class BillModel extends BillEntity {
  const BillModel(
      {required super.id,
      required super.value,
      required super.diamonds,
      required super.operationNum,
      required super.uuid,
      required super.createdAt,
      required super.name,
      required super.image,
      required super.type,
      required super.coloredName,
      required super.coins});

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: parseValue<int>(json['id'], 0),
      value: parseValue<int>(json['value'], 0),
      diamonds: parseValue<String>(json['diamonds'], '0'),
      operationNum: parseValue<String>(json['operation_no'], ''),
      createdAt: parseValue<String>(json['created_at'], ''),
      image: parseValue<String>(json['image'], ''),
      type: parseValue<String>(json['type'], ''),
      name: parseValue<String>(json['name'], ''),
      coins: parseValue<String>(json['coins'], '0'),
      uuid: parseValue<String>(json['uuid'], ''),
      coloredName: parseValue<String>(json['color_name'], ''),
    );
  }
}
