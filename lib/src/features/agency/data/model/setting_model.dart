
import 'package:general/src/features/agency/agency.dart';

import '../../../../../reels_viewer/reels_viewer.dart';

class SettingModel extends SettingEntity {
  const SettingModel({
    super.version,
    super.hideInvite,
    super.showChat,
    super.sharedKey,
    super.havePendingRequest,
    super.stopTransferSalary,
  });

  factory SettingModel.fromJson(Map<String, dynamic> json) {
    return SettingModel(
      version: json['version'] is Map<String, dynamic>
          ? Version.fromJson(json['version'])
          : null,
      hideInvite: parseValue<bool>(json['hide_invite'], false) ,
      havePendingRequest:parseValue<bool>(json['have_pending_request'], false)  ,
      showChat: parseValue<bool>(json['show_chat'] , true) ,
      stopTransferSalary: parseValue<bool>(json['stop_transfer_salary'] , true) ,
      sharedKey: parseValue<String>(json['shared_key'],'') ,
    );
  }




}

class Version extends VersionEntity {
  const Version({
    super.androidVersion,
    super.iosVersion,
    super.huaweiVersion,
  });

  factory Version.fromJson(Map<String, dynamic> json) {
    return Version(
      androidVersion: parseValue<String>(json['android_version'],''),
      iosVersion:parseValue<String>(json['ios_version'],'') ,
      huaweiVersion: parseValue<String>(json['huawei_version'],''),
    );
  }




}
