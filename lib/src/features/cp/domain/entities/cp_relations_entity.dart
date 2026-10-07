import 'package:equatable/equatable.dart';

class CpRelationsEntity extends Equatable {
  final bool success;
  final String message;
  final List<CpRelationDataEntity> data;
  final dynamic paginates;

  const CpRelationsEntity({
    required this.success,
    required this.message,
    required this.data,
    this.paginates,
  });

  @override
  List<Object?> get props => [success, message, data, paginates];
}

class CpRelationDataEntity extends Equatable {
  final int id;
  final String title;
  final String image;
  final int price;
  final int userCount;

  const CpRelationDataEntity({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    required this.userCount,
  });

  @override
  List<Object?> get props => [id, title, image, price, userCount];
}
