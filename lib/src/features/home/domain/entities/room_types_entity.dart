import 'package:general/src/core/index.dart';

class RoomTypesEntity extends Equatable{
  final int id;
  final String name;
  final String image;

  const RoomTypesEntity({
    required this.id,
    required this.name,
    required this.image,
  });
  
  @override
  List<Object?> get props => [
    id,name,image
  ];
}
