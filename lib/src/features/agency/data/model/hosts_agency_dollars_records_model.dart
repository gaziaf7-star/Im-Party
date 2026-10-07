
import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/agency/domain/entity/hosts_agency_dollars_records_entity.dart';

import '../../../../../reels_viewer/reels_viewer.dart';

class HostsAgencyDollarsRecordsModel extends HostsAgencyDollarsRecordsEntity {
  const HostsAgencyDollarsRecordsModel({
    super.id,
    super.value,
    super.time,
    super.senderEntity,
    super.receiverEntity,
    super.stringValue,
    super.isSender,
  });

  factory HostsAgencyDollarsRecordsModel.fromJson(Map<String, dynamic> json) {
    return HostsAgencyDollarsRecordsModel(
      id: parseValue<int>(json['uuid'] ,0),
      value: parseValue<int>(json['usd'],0) ,
      stringValue: parseValue<String>(json['value_string'],'') ,
      time:parseValue<String>(json['time'] ,''),
      isSender:parseValue<bool>(json['is_sender'] ,false),
      senderEntity: json['sender'] is Map<String, dynamic>
          ? ReceiverModel.fromJson(json['sender'])
          : null,
      receiverEntity: json['receiver'] is Map<String, dynamic>
          ? ReceiverModel.fromJson(json['receiver'])
          : null,
    );
  }
}

