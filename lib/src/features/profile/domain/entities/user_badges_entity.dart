import 'package:equatable/equatable.dart';

class UserBadgesEntity extends Equatable {
  final List<BadgeEntity> top;
  final List<BadgeEntity> regular;

  const UserBadgesEntity({
    required this.top,
    required this.regular,
  });

  @override
  List<Object?> get props => [top, regular];
}

class BadgeEntity extends Equatable {
  final String image;
  final String imageType;

  const BadgeEntity({
    required this.image,
    required this.imageType,
  });

  @override
  List<Object?> get props => [image, imageType];
}
