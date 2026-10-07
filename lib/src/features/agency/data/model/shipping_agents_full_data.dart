import '../../../../../reels_viewer/reels_viewer.dart';
import '../../../auth/data/model/country_model.dart';
import 'package:general/src/features/agency/agency.dart';

class ShippingAgentsFullDataModel extends ShippingAgentsFullDataEntity {
  const ShippingAgentsFullDataModel({
    super.id,
    super.ownerId,
    super.ownerImage,
    super.ownerName,
    super.name,
    super.phone,
    super.image,
    super.uuid,
    List<PaymentsGetwaysModel>? super.paymentGetaway,
    List<CountryModel>? super.countries,
    super.frame,
    super.frameId,
    super.level,
    super.vip,
    super.chargeCount,
    super.idImage,
    super.specialId,
    super.imageColorEntity,
    super.status,
  });

  factory ShippingAgentsFullDataModel.fromJson(Map<String, dynamic> json) {
    return ShippingAgentsFullDataModel(
      id:  parseValue<int>(json['agency_id'],0),
      ownerId: parseValue<int>(json['id'],0),
      name: parseValue<String>(json['name'],'') ,
      phone: parseValue<String>(json['phone'],'') ,
      image: parseValue<String>(json['image'],'') ,
      uuid: parseValue<String>(json['uuid'] ,''),
      paymentGetaway: json['payment_getaway'] is List
          ? List<PaymentsGetwaysModel>.from(
        (json['payment_getaway'] as List).whereType<Map<String, dynamic>>().map(
              (element) => PaymentsGetwaysModel.fromJson(element),
        ),
      )
          : null,
      countries: json['countries'] is List
          ? List<CountryModel>.from(
        (json['countries'] as List).whereType<Map<String, dynamic>>().map(
              (element) => CountryModel.fromJson(element),
        ),
      )
          : null,
      frame:parseValue<String>(json['frame'],'') ,
      frameId: parseValue<int>(json['frame_id'],0)  ,
      level:parseValue<int>(json['level'] ,0) ,
      vip: parseValue<int>(json['vip'],0) ,
      chargeCount: parseValue<int>(json['charge_count'],0) ,
      idImage: parseValue<String>(json['id_image'],'') ,
      specialId: parseValue<String>(json['special_id'],''),
      ownerImage: parseValue<String>(json['owner_image'],''),
      ownerName: parseValue<String>(json['owner_name'],''),
      status: parseValue<int>(json['status'],0),
      imageColorEntity: json['image_color'] is Map<String, dynamic>
          ? ImageColorModel.fromJson(json['image_color'])
          : null,
    );
  }

}
