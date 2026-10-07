import 'package:general/src/features/room/domain/entities/background_setting_entity.dart';

import '../../../../core/utils/methods.dart';

class BackgroundSettingModel extends BackGroundSettingEntity {

  const BackgroundSettingModel({required super.cost, required super.expire});

  factory BackgroundSettingModel.fromJson(Map<String, dynamic> json) {
    return BackgroundSettingModel(
      cost: parseValue<String>(json['cost'], ''),
      expire: parseValue<String>(json['expire'], ''),
    );
  }


  @override
  List<Object?> get props => [cost, expire];
}
