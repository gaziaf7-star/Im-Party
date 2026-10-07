import '../../../../core/utils/methods.dart';
import '../../domain/entities/support_questions_entity.dart';

class SupportQuestionsModel extends SupportQuestionsEntity {
  const SupportQuestionsModel({
   super.id,
    super.question,
    super.answer,
    super.status,
    super.createdAt,
    super.updatedAt,
  });

  factory SupportQuestionsModel.fromJson(Map<String, dynamic> json) {
    return SupportQuestionsModel(
      id: parseValue<int>(json['id'], 0),
      question: parseValue<String>(json['question'], ""),
      answer: parseValue<String>(json['answer'], ""),
      status: parseValue<int>(json['status'], 0),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

}
