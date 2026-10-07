import 'package:general/src/core/index.dart';

class BillEntity extends Equatable{
  final int id;
  final int value;
  final String diamonds;
  final String operationNum;
  final String createdAt;
  final String name;
  final String image;
  final String type;
  final String coins;
  final String uuid;
  final String coloredName;


  const BillEntity({
    required this.id,
    required this.value,
    required this.diamonds,
    required this.operationNum,
    required this.createdAt,
    required this.name,
    required this.image,
    required this.type,
    required this.coins,
    required this.uuid,
    required this.coloredName,

  });

  @override
  List<Object?> get props => [
    id,
    value,
    diamonds,
    operationNum,
    createdAt,
    name,
    image,
    type,
    coins,
    uuid,
    coloredName,
  ];
}
