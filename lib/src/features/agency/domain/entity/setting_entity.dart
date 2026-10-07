import 'package:equatable/equatable.dart';

class SettingEntity extends Equatable {
  final VersionEntity? version;
  final bool? hideInvite;
  final bool? showChat;
  final bool? stopTransferSalary;
  final bool? havePendingRequest;
  final bool? groupBan;
  final String? sharedKey;

  const SettingEntity({
    this.version,
    this.hideInvite,
    this.showChat,
    this.sharedKey,
    this.havePendingRequest,
    this.stopTransferSalary,
    this.groupBan,
  });

  @override
  List<Object?> get props => [
        version,
        hideInvite,
        showChat,
        stopTransferSalary,
        havePendingRequest,
        sharedKey,
        groupBan
      ];

  SettingEntity copyWith({
    VersionEntity? version,
    bool? hideInvite,
    bool? showChat,
    bool? stopTransferSalary,
    bool? havePendingRequest,
    bool? groupBan,
    String? sharedKey,
  }) {
    return SettingEntity(
      version: version ?? this.version,
      hideInvite: hideInvite ?? this.hideInvite,
      showChat: showChat ?? this.showChat,
      groupBan: groupBan ?? this.groupBan,
      stopTransferSalary: stopTransferSalary ?? this.stopTransferSalary,
      havePendingRequest: havePendingRequest ?? this.havePendingRequest,
      sharedKey: sharedKey ?? this.sharedKey,
    );
  }
}

class VersionEntity extends Equatable {
  final String? androidVersion;
  final String? iosVersion;
  final String? huaweiVersion;

  const VersionEntity({
    this.androidVersion,
    this.iosVersion,
    this.huaweiVersion,
  });

  VersionEntity copyWith({
    String? androidVersion,
    String? iosVersion,
    String? huaweiVersion,
  }) {
    return VersionEntity(
      androidVersion: androidVersion ?? this.androidVersion,
      iosVersion: iosVersion ?? this.iosVersion,
      huaweiVersion: huaweiVersion ?? this.huaweiVersion,
    );
  }

  @override
  List<Object?> get props => [androidVersion, iosVersion, huaweiVersion];
}
