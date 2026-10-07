import 'package:equatable/equatable.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';

import '../../../../../../core/constants/enums.dart';

abstract class BaseFollowEvent extends Equatable {
  const BaseFollowEvent();

  @override
  List<Object> get props => [];
}

class FollowEvent extends BaseFollowEvent {
  final UserEntity userEntity;
  final RelationType? relationType;
  final int? index;

  const FollowEvent({
    required this.userEntity,
     this.relationType,
     this.index,
  });
}

class UnFollowEvent extends BaseFollowEvent {
  final String userId;
  final RelationType? relationType;

  const UnFollowEvent({
    required this.userId,
     this.relationType,
  });
}
