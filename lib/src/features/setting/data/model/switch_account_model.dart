import 'package:general/src/core/index.dart';
import 'package:general/src/features/setting/domain/entities/switch_account_entity.dart';

class SwitchLoginAccountModel extends SwitchLoginAccountEntity {
  const SwitchLoginAccountModel({
    required super.id,
    required super.isFirst,
    required super.authToken,
  });

  factory SwitchLoginAccountModel.fromJson(Map<String, dynamic> json) {
    return SwitchLoginAccountModel(
      id: parseValue<int>(json['id'], 0),
      isFirst: parseValue<bool>(json['is_first'], false),
      authToken: parseValue<String>(json['auth_token'], ''),
    );
  }
}
