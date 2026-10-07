import 'package:general/src/core/index.dart';

class ManagerTypeEntity extends Equatable {
  final int? id;
  final String? name;
  final String? image;
  final String? description;

  const ManagerTypeEntity({
    this.id,
    this.name,
    this.image,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, image, description];
}