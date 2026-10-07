import 'package:equatable/equatable.dart';

class CpRelationLevelsGiftsEntity extends Equatable{
  final bool success;
  final String? message;
  final List<LevelDataEntity>? data;
  final dynamic paginates;

  const CpRelationLevelsGiftsEntity({
    required this.success,
    this.message,
    this.data,
    this.paginates,
  });

  @override
  List<Object?> get props => [
    success,
    message,
    data,
    paginates,
  ];
}

class LevelDataEntity extends Equatable{
  final int level;
  final String? title;
  final bool have;
  final List<GiftEntity>? gifts;

  const LevelDataEntity({
    required this.level,
    this.title,
    required this.have,
    this.gifts,
  });

  @override
  List<Object?> get props => [
    level,
    title,
    have,
    gifts,
  ];
}

class GiftEntity extends Equatable{
  final String? title;
  final List<String>? images;

  const GiftEntity({
    this.title,
    this.images,
  });

  @override
  List<Object?> get props => [
    title,
    images,
  ];
}