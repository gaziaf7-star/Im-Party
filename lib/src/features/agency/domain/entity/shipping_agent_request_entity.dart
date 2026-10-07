
import 'package:equatable/equatable.dart';

class ShippingAgentRequestEntity extends Equatable {
  final int? id;
  final int? hostId;
  final String? hostName;
  final String? hostUuid;
  final String? hostImage;
  final int? status;
  final String? paymentGateway;
  final String? paymentGatewayImage;
  final String? countryName;
  final String? countryFlag;
  final double? usd;
  final int? coins;
  final String? note;
  final bool? haseColoredName;
  final bool? isCountryHiden;

  const ShippingAgentRequestEntity({
    this.id,
    this.hostId,
    this.hostName,
    this.hostUuid,
    this.hostImage,
    this.status,
    this.paymentGateway,
    this.paymentGatewayImage,
    this.countryName,
    this.countryFlag,
    this.usd,
    this.coins,
    this.note,
    this.haseColoredName,
    this.isCountryHiden,
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
    countryName,
    countryFlag,
    usd,
    coins,
    note,
    haseColoredName,
    isCountryHiden,
  ];

  ShippingAgentRequestEntity copyWith({
    int? id,
    int? hostId,
    String? hostName,
    String? hostUuid,
    String? hostImage,
    int? status,
    String? paymentGateway,
    String? paymentGatewayImage,
    String? countryName,
    String? countryFlag,
    double? usd,
    int? coins,
    String? note,
    bool? haseColoredName,
    bool? isCountryHiden,
  }) {
    return ShippingAgentRequestEntity(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      hostUuid: hostUuid ?? this.hostUuid,
      hostImage: hostImage ?? this.hostImage,
      status: status ?? this.status,
      paymentGateway: paymentGateway ?? this.paymentGateway,
      paymentGatewayImage: paymentGatewayImage ?? this.paymentGatewayImage,
      countryName: countryName ?? this.countryName,
      countryFlag: countryFlag ?? this.countryFlag,
      usd: usd ?? this.usd,
      coins: coins ?? this.coins,
      note: note ?? this.note,
      haseColoredName: haseColoredName ?? this.haseColoredName,
      isCountryHiden: isCountryHiden ?? this.isCountryHiden,
    );
  }
}
