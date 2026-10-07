import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/home/domain/entities/search_entity.dart';
import 'package:general/src/features/home/home.dart';

import '../../../../../reels_viewer/reels_viewer.dart';

class SearchModel extends SearchEntity {
  const SearchModel({
    required super.users,
    required super.rooms,
    super.numberOfFriends,
  });

  factory SearchModel.fromJson(Map<String, dynamic> json) {
    return SearchModel(
      numberOfFriends: parseValue<int>(json['number_of_friends'],0) ,
      users: List<UserModel>.from((json['user'] is List ? json['user'] as List : const [])
          .whereType<Map<String, dynamic>>()
          .map((e) => UserModel.fromJson(e))),
      rooms: json['rooms'] == null
          ? null
          : List<RoomModel>.from(
              (json['rooms'] is List ? json['rooms'] as List : const [])
                  .whereType<Map<String, dynamic>>()
                  .map((e) => RoomModel.fromJson(e))),
    );
  }
}

/* class UserModel extends UserEntity {
  const UserModel({
    required super.name,
    required super.nickname,
    required super.id,
    required super.isFollow,
    required super.store,
    required super.lang,
    required super.gender,
    required super.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      nickname: json['nickname'],
      id: json['id'],
      isFollow: json['is_follow'],
      store: StoreModel.fromJson(json['my_store']),
      lang: json['lang'],
      gender: json['gender'],
      avatar: json['avatar'],
    );
  }
}

class StoreModel extends StoreEntity {
  const StoreModel({
    required super.id,
    required super.diamonds,
    required super.coins,
    required super.roomCoins,
    required super.gold,
    required super.withdrawalCoins,
    required super.coupons,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'],
      diamonds: json['diamonds'],
      coins: json['coins'],
      roomCoins: json['room_coins'],
      gold: json['gold'],
      withdrawalCoins: json['withdrawal_coins'],
      coupons: json['coupons'],
    );
  }
}

class RoomModel extends RoomEntity {
  const RoomModel({
    required super.roomName,
    required super.uid,
    required super.hot,
    required super.roomCover,
    required super.nickname,
    required super.roomWelcome,
    required super.passwordStatus,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      roomWelcome: json['room_welcome'] ?? '',
      roomCover: json['room_cover'] ?? '',
      uid: json['uid'],
      hot: json['hot'],
      nickname: json['nickname'] ?? '',
      roomName: json['room_name'],
      passwordStatus: json['room_pass'],
    );
  }
}
 */