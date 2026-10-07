import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/country_entity.dart';

class UsersOnlineEntity extends Equatable {
  int? id;
  String? uuid;
  String? image;
  String? name;
  CountryEntity? country;
  bool? isFollowed;
  bool? isFollow;
  bool? isFriend;

  UsersOnlineEntity(
      {this.id,
      this.uuid,
      this.image,
      this.country,
      this.isFollowed,
      this.isFollow,
      this.name,
      this.isFriend});

  UsersOnlineEntity copyWith({
    bool? isFollow,
  }) {
    return UsersOnlineEntity(
      id: id,
      uuid: uuid,
      image: image,
      country: country,
      isFollowed: isFollowed,
      isFollow: isFollow ?? this.isFollow,
      name: name,
      isFriend: isFriend,
    );
  }

  @override
  List<Object?> get props => [
        id,
        uuid,
        image,
        country,
        isFollowed,
        isFollow,
        isFriend,
        name,
      ];
}
