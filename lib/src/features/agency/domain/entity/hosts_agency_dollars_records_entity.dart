import 'package:equatable/equatable.dart';
import 'package:general/src/features/agency/domain/entity/details_charge_agency_entity.dart';

class HostsAgencyDollarsRecordsEntity extends Equatable {
  final int? id;
  final int? value;
  final String? time;
  final String? stringValue;
  final bool? isSender;
  final ReceiverEntity? senderEntity;
  final ReceiverEntity? receiverEntity;

  const HostsAgencyDollarsRecordsEntity({
    this.id,
    this.value,
    this.time,
    this.senderEntity,
    this.receiverEntity,
    this.stringValue,
    this.isSender,
  });

  @override
  List<Object?> get props =>
      [id, value, time, senderEntity, receiverEntity, stringValue, isSender];
}
