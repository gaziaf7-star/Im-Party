import 'package:general/src/features/auth/data/model/user_model.dart';
import 'package:general/src/features/family/domain/entities/family_request_entity.dart';

import '../../../../core/utils/methods.dart';

class FamilyRequestsModel extends FamilyRequestEntity {
  const FamilyRequestsModel({
    required super.user,
    required super.id,
    required super.time,
  });

  factory FamilyRequestsModel.fromJson(Map<String, dynamic> json) {
    return FamilyRequestsModel(
      user: json['user'] is Map<String, dynamic> ? UserModel.fromJson(json['user']) : const UserModel(), // Handle null user
      id: parseValue<int>(json['id'], 0),
      time: parseValue<String>(json['time'], ""),
    );
  }

}
