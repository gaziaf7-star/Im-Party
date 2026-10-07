import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

class CountryModel extends CountryEntity {
  const CountryModel({
    super.id,
    super.name,
    super.photo,
    super.lang,
    super.phoneCode,
    super.iso,
    super.nameEn,
    super.supporters,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) =>
      CountryModel(
        id: parseValue<int>(json['id'], 0),
        name: parseValue<String>(json['name'], ''),
        photo: parseValue<String>(json['flag'], ''),
        lang: parseValue<String>(json['lang'], ''),
        phoneCode: parseValue<String>(json['phone_code'], ''),
        iso: parseValue<String>(json['iso'], ''),
        nameEn: parseValue<String>(json['e_name'], ''),
        supporters: (json['supporters'] is List ? json['supporters'] as List<dynamic> : null)
            ?.whereType<Map<String, dynamic>>()
            .map((e) => SupporterModel.fromJson(e))
            .toList() ??
            [],
      );
}

class SupporterModel extends SupporterEntity {
  const SupporterModel({
    super.id,
    super.uuid,
    super.name,
    super.avatar,
    super.total,
  });

  factory SupporterModel.fromJson(Map<String, dynamic> json) =>
      SupporterModel(
        id: parseValue<int>(json['id'], 0),
        uuid: parseValue<String>(json['uuid'], ''),
        name: parseValue<String>(json['name'], ''),
        avatar: parseValue<String>(json['avatar'], ''),
        total: parseValue<int>(json['total'], 0),
      );
}
