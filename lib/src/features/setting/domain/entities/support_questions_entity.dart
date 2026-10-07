import 'package:equatable/equatable.dart';

class SupportQuestionsEntity extends Equatable {
  final int? id;
  final String? question;
  final String? answer;
  final int? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SupportQuestionsEntity({
    required this.id,
    required this.question,
    required this.answer,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props =>[id,question,answer,status,createdAt,updatedAt];
}
