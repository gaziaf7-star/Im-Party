import 'package:equatable/equatable.dart';

class GiftCategoryEntity extends Equatable {
  final int id;
  final String title;
  final String type;

  const GiftCategoryEntity({
    required this.id,
    required this.title,
    required this.type,
  });

  @override
  List<Object?> get props => [id, title, type];
}