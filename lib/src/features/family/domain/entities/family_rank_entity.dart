import 'package:equatable/equatable.dart';
import 'package:general/src/core/constants/enums.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/family/domain/entities/show_family_entity.dart';


class FamilyRankEntity extends Equatable {
  final int? id;
  final String? name;
  final String? introduce;
  final String? img;
  final String? rank;
  final CountryEntity? countryEntity;
  final FamilyLevelEntity? familyLevelEntity;
  final RequestState joinFamilyRequestState;

  const FamilyRankEntity({
    this.id,
    this.name,
    this.introduce,
    this.img,
    this.rank,
    this.countryEntity,
    this.familyLevelEntity,
    this.joinFamilyRequestState = RequestState.idle,
  });

  FamilyRankEntity copyWith({
    RequestState? joinFamilyRequestState,
  }) {
    return FamilyRankEntity(
        id: id,
        name: name,
        joinFamilyRequestState:
            joinFamilyRequestState ?? this.joinFamilyRequestState,
        countryEntity: countryEntity,
        rank: rank,
        img: img,
        introduce: introduce,
        familyLevelEntity: familyLevelEntity);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        introduce,
        img,
        rank,
        countryEntity,
        familyLevelEntity,
        joinFamilyRequestState,
      ];
}
