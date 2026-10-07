import 'package:general/src/features/agency/agency.dart';

import '../../../../../reels_viewer/reels_viewer.dart';

class ShippingAgentRequestModel extends ShippingAgentRequestEntity {
  const ShippingAgentRequestModel({
    super.id,
    super.hostId,
    super.hostName,
    super.hostUuid,
    super.hostImage,
    super.status,
    super.paymentGateway,
    super.paymentGatewayImage,
    super.countryName,
    super.countryFlag,
    super.usd,
    super.coins,
    super.note,
    super.haseColoredName,
    super.isCountryHiden,
  });

  factory ShippingAgentRequestModel.fromJson(Map<String, dynamic> json) {
    return ShippingAgentRequestModel(
      id: parseValue<int>(json['id'],0),
      hostId: parseValue<int>(json['host_id'],0) ,
      hostName: parseValue<String>(json['host_name'],'') ,
      hostUuid:parseValue<String>(json['host_uuid'],'')  ,
      hostImage: parseValue<String>(json['host_image'],'') ,
      status: parseValue<int>(json['status'] ,0),
      paymentGateway:parseValue<String>(json['payment_gateway'],'') ,
      paymentGatewayImage: parseValue<String>(json['payment_gateway_image'],'') ,
      countryName: parseValue<String>(json['country_name'] ,''),
      countryFlag:parseValue<String>(json['country_flag'] ,''),
      usd: parseValue<double>(json['usd'].toDouble(),0.0)  ,
      coins:parseValue<int>(json['coins'],0)  ,
      note: parseValue<String>(json['note'] ,''),
      haseColoredName:parseValue<bool>(json['has_color_name'], false) ,
      isCountryHiden:parseValue<bool>(json['country_hidden'], false)  ,
    );
  }


}
