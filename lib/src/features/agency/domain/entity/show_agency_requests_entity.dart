import 'package:equatable/equatable.dart';
import 'package:general/src/features/agency/domain/entity/agency_member_entity.dart';


class ShowAgencyRequestModelEntity extends Equatable {
  final int? id;
  final String? uuid;
  final int? diamonds;
  final String? name;
  final LevelEntity? level;
  final ProfileEntity? profile;
  final bool? hasColorName;
  final int? status;
  final String? operator;
  final String? date;

  const ShowAgencyRequestModelEntity({
    this.id,
    this.uuid,
    this.diamonds,
    this.name,
    this.level,
    this.profile,
    this.hasColorName,
    this.status,
    this.operator,
    this.date,
  });

  @override
  List<Object?> get props => [
    id,
    uuid,
    diamonds,
    name,
    level,
    profile,
    hasColorName,
    status,
    operator,
    date,
  ];

  ShowAgencyRequestModelEntity copyWith({
    int? id,
    String? uuid,
    int? diamonds,
    String? name,
    LevelEntity? level,
    ProfileEntity? profile,
    bool? hasColorName,
    int? status,
    String? operator,
    String? date,
  }) {
    return ShowAgencyRequestModelEntity(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      diamonds: diamonds ?? this.diamonds,
      name: name ?? this.name,
      level: level ?? this.level,
      profile: profile ?? this.profile,
      hasColorName: hasColorName ?? this.hasColorName,
      status: status ?? this.status,
      operator: operator ?? this.operator,
      date: date ?? this.date,
    );
  }
}


