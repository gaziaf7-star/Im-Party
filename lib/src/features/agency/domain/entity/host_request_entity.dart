import 'package:equatable/equatable.dart';

class HostRequestsEntity extends Equatable {
  final int? id;
  final int? hostId;
  final String? hostName;
  final String? hostUuid;
  final String? hostImage;
  final int? status;
  final String? paymentGateway;
  final String? paymentGatewayImage;
  final dynamic billImage;
  final String? countryName;
  final String? countryFlag;
  final int? usd;
  final int? coins;
  final dynamic note;

  const HostRequestsEntity({
    this.id,
    this.hostId,
    this.hostName,
    this.hostUuid,
    this.hostImage,
    this.status,
    this.paymentGateway,
    this.paymentGatewayImage,
    this.billImage,
    this.countryName,
    this.countryFlag,
    this.usd,
    this.coins,
    this.note,
  });

  @override
  List<Object?> get props => [
    id,
    hostId,
    hostName,
    hostUuid,
    hostImage,
    status,
    paymentGateway,
    paymentGatewayImage,
    billImage,
    countryName,
    countryFlag,
    usd,
    coins,
    note,
  ];

  HostRequestsEntity copyWith({
    int? id,
    int? hostId,
    String? hostName,
    String? hostUuid,
    String? hostImage,
    int? status,
    String? paymentGateway,
    String? paymentGatewayImage,
    dynamic billImage,
    String? countryName,
    String? countryFlag,
    int? usd,
    int? coins,
    dynamic note,
  }) {
    return HostRequestsEntity(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      hostUuid: hostUuid ?? this.hostUuid,
      hostImage: hostImage ?? this.hostImage,
      status: status ?? this.status,
      paymentGateway: paymentGateway ?? this.paymentGateway,
      paymentGatewayImage: paymentGatewayImage ?? this.paymentGatewayImage,
      billImage: billImage ?? this.billImage,
      countryName: countryName ?? this.countryName,
      countryFlag: countryFlag ?? this.countryFlag,
      usd: usd ?? this.usd,
      coins: coins ?? this.coins,
      note: note ?? this.note,
    );
  }
}
