import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';

import '../../../auth/data/model/country_model.dart';

class ChargeAgencyInfoModel extends ChargeAgencyInfoEntity {
  const ChargeAgencyInfoModel({
    super.id,
    super.name,
    super.notice,
    super.status,
    super.usd,
    super.coins,
    super.phone,
    super.url,
    super.img,
    super.contents,
    super.owner,
    List<PaymentsGetwaysModel>? super.payments,
    List<CountryModel>? super.countries,
  });

  factory ChargeAgencyInfoModel.fromJson(Map<String, dynamic> json) {
    return ChargeAgencyInfoModel(
        id: parseValue<int>(json['id'], 0),
        name: parseValue<String>(json['name'], ''),
        notice: parseValue<String>(json['notice'], ''),
        status: parseValue<int>(json['status'], 0),
        usd: parseValue<int>(json['salaryTransfer'], 0),
        coins: parseValue<int>(json['coins'], 0),
        phone: parseValue<String>(json['phone'], ''),
        url: parseValue<String>(json['url'], ''),
        img: parseValue<String>(json['img'], ''),
        contents: parseValue<String>(json['contents'], ''),
        countries: json['countries'] != null
            ? parseValue<List<CountryModel>>(
                json['countries'],
                [],
                customParser: (value) {
                  if (value is List) {
                    return value
                        .map((item) =>
                            CountryModel.fromJson(item as Map<String, dynamic>))
                        .toList();
                  }
                  return [];
                },
              )
            : null,
        payments: json['payments'] != null
            ? parseValue<List<PaymentsGetwaysModel>>(
                json['payments'],
                [],
                customParser: (value) {
                  if (value is List) {
                    return value
                        .map((item) => PaymentsGetwaysModel.fromJson(
                            item as Map<String, dynamic>))
                        .toList();
                  }
                  return [];
                },
              )
            : null,
        owner: json['owner'] is Map<String, dynamic> ? OwnerModel.fromJson(json['owner']) : null);
  }
}

class PaymentsGetwaysModel extends PaymentsGetwaysEntity {
  const PaymentsGetwaysModel({
    super.id,
    super.name,
    super.photo,
    super.isSelected,
  });

  factory PaymentsGetwaysModel.fromJson(Map<String, dynamic> json) {
    return PaymentsGetwaysModel(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['title'], ''),
      photo: parseValue<String>(json['photo'], ''),
      isSelected: parseValue<bool>(json['is_selected'], false),
    );
  }
}

class OwnerModel extends OwnerEntity {
  const OwnerModel({
    super.id,
    super.name,
    super.image,
    super.uuid,
    super.hasColorName,
  });

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['name'], ''),
      image: parseValue<String>(json['profile'] is Map<String, dynamic> ? json['profile']['image'] : null, ''),
      uuid: parseValue<String>(json['uuid'], ''),
      hasColorName: parseValue<bool>(json['has_color_name'], false),
    );
  }
}
