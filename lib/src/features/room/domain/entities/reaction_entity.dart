import 'package:equatable/equatable.dart';

class ReactionEntity extends Equatable {
  final int id;
  final String title;
  final String type;

  const ReactionEntity({
    required this.id,
    required this.title,
    required this.type,
  });

  @override
  List<Object?> get props => [id, title, type];
}
