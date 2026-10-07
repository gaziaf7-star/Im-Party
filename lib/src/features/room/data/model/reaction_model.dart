import 'package:general/src/features/room/domain/entities/reaction_entity.dart';

class ReactionModel extends ReactionEntity {
  const ReactionModel({
    required super.id,
    required super.title,
    required super.type,
  });

  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
      id: json['id'] as int,
      title: json['title'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
    };
  }

  
}
