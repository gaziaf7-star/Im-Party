import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

class MyAgencyModel extends MyHostsAgencyEntity {
  const MyAgencyModel(
      {super.id,
      super.name,
      super.notice,
      super.img,
      super.memberCount,
      super.topStars});

  factory MyAgencyModel.fromJson(Map<String, dynamic> json) {
    return MyAgencyModel(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['name'], ''),
      notice: parseValue<String>(json['notice'], ''),
      img: parseValue<String>(json['image'], ''),
      memberCount: parseValue<int>(json['member_count'], 0),
      topStars: parseValue<List<String>>(json['top_stars'], []),
    );
  }
}

class MyShippingAgencyModel extends MyShippingAgencyEntity {
  const MyShippingAgencyModel(
      {super.id, super.name, super.img, super.successTransaction});

  factory MyShippingAgencyModel.fromJson(Map<String, dynamic> json) {
    return MyShippingAgencyModel(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['name'], ''),
      img: parseValue<String>(json['image'], ''),
      successTransaction: parseValue<int>(json['complete-transactions'], 0),
    );
  }
}
