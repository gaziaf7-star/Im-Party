import 'package:general/src/features/auth/data/model/country_model.dart';
import 'package:general/src/features/games/domain/entities/online_user_entity.dart';

import '../../../../core/utils/methods.dart';

class UsersOnlineModel extends UsersOnlineEntity {
  UsersOnlineModel(
      {super.id,
      super.uuid,
      super.image,
      super.country,
      super.isFollowed,
      super.name,
      super.isFollow,
      super.isFriend});

  factory UsersOnlineModel.fromJson(Map<String, dynamic> json) {
    return UsersOnlineModel(
      id: parseValue<int>(json['id'], 0),
      uuid: parseValue<String>(json['uuid'], ''),
      image: parseValue<String>(json['image'], ''),
      name: parseValue<String>(json['name'], ''),
      country: json['country'] is Map<String, dynamic>
          ? CountryModel.fromJson(json['country'])
          : null,
      isFollowed: parseValue<bool>(json['is_followed'], false),
      isFollow: parseValue<bool>(json['is_follow'], false),
      isFriend: parseValue<bool>(json['is_friend'], false),
    );
  }
}
