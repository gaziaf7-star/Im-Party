import 'package:general/src/core/index.dart';

class FamilyEntity extends Equatable {
  final int? id;
  final int? maxNum;
  final String? img;
  final int? memberNum;
  final String? name;
  final int? ownerFamilyId;
  final List<String>? topStars;

  const FamilyEntity({
    this.id,
    this.maxNum,
    this.img,
    this.memberNum,
    this.name,
    this.ownerFamilyId,
    this.topStars,
  });

  @override
  List<Object?> get props => [maxNum, img, memberNum, name, ownerFamilyId,topStars,id];
}
