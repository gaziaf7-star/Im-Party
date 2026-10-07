import 'package:general/src/core/index.dart';
import 'package:general/src/features/games/domain/entities/user_top_entity.dart';

class RankingEntity extends Equatable {
  final UserTopEntity userEntity;
  final List<UserTopEntity> usersEntity;
  final List<UserTopEntity> otherUsersEntity;

  const RankingEntity({
    required this.userEntity,
    required this.usersEntity,
    required this.otherUsersEntity,
  });

  @override
  List<Object?> get props => [userEntity, otherUsersEntity, usersEntity];
}
