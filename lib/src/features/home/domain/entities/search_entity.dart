
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';

import '../../home.dart';

class SearchEntity extends Equatable {
  final List<UserEntity> users;
  final List<RoomEntity>? rooms;
  final int? numberOfFriends;

  const SearchEntity({
    required this.users,
    required this.rooms,
    this.numberOfFriends,
  });

  @override
  List<Object?> get props => [users, rooms, numberOfFriends];
}

/* class UserEntity extends Equatable {
  final String name;
  final String nickname;
  final int id;
  final int isFollow;
  final StoreEntity store;
  final String lang;
  final String gender;
  final String avatar;

  const UserEntity({
    required this.name,
    required this.nickname,
    required this.id,
    required this.isFollow,
    required this.store,
    required this.lang,
    required this.gender,
    required this.avatar,
  });

  @override
  List<Object?> get props => [
        name,
        nickname,
        id,
        isFollow,
        store,
        lang,
        gender,
        avatar,
      ];
}

class StoreEntity extends Equatable {
  final int id;
  final int diamonds;
  final int coins;
  final int roomCoins;
  final int gold;
  final int withdrawalCoins;
  final int coupons;

  const StoreEntity({
    required this.id,
    required this.diamonds,
    required this.coins,
    required this.roomCoins,
    required this.gold,
    required this.withdrawalCoins,
    required this.coupons,
  });

  @override
  List<Object?> get props => [
        id,
        diamonds,
        coins,
        roomCoins,
        gold,
        withdrawalCoins,
        coupons,
      ];
}

class RoomEntity extends Equatable {
  final String roomName;
  final int uid;
  final int hot;
  final String roomCover;
  final String nickname;
  final String roomWelcome;
  final bool passwordStatus;

  const RoomEntity({
    required this.roomName,
    required this.uid,
    required this.hot,
    required this.roomCover,
    required this.nickname,
    required this.roomWelcome,
    required this.passwordStatus,
  });

  @override
  List<Object?> get props => [
        roomName,
        uid,
        hot,
        roomCover,
        nickname,
        roomWelcome,
        passwordStatus,
      ];
}
 */