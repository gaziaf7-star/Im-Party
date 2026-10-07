import 'package:equatable/equatable.dart';

class CountryCategoryEntity extends Equatable {
  final int id;
  final String title;
  final String type;

  const CountryCategoryEntity({
    required this.id,
    required this.title,
    required this.type,
  });

  @override
  List<Object?> get props => [id, title, type];
}
