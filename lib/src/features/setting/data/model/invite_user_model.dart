import 'package:general/src/core/index.dart';
import 'package:general/src/features/setting/domain/entities/invite_user_entity.dart';

class InvitationUsersModel extends InvitationUsersEntity {
  const InvitationUsersModel({
    required super.invitedId,
    required super.userCharge,
    required super.parentPercentage,
    required super.date,
    required super.image,
    required super.name,
  });

  factory InvitationUsersModel.fromMap(Map<String, dynamic> map) {
    return InvitationUsersModel(
      invitedId: parseValue<String>(map['user']?['uuid'], ''),
      name: parseValue<String>(map['user']?['name'], ''),
      userCharge: parseValue<int>(map['user_charge'], 0),
      parentPercentage: parseValue<int>(map['parent_percentage'], 0),
      date: parseValue<String>(map['updated_at'], ''),
      image: parseValue<String>(map['user']?['profile']?['image'], ''),
    );
  }
}
