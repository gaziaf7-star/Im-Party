import 'package:equatable/equatable.dart';

class OldAgencyEntity extends Equatable {
  final String joinDate;
  final String leaveDate;
  final int agencyId;
  final String img;
  final String joinTimeOnly;

  const OldAgencyEntity({
    required this.joinDate,
    required this.leaveDate,
    required this.agencyId,
    required this.img,
    required this.joinTimeOnly,
  });

  OldAgencyEntity copyWith({
    String? joinDate,
    String? leaveDate,
    int? agencyId,
    String? img,
    String? joinTimeOnly,
  }) {
    return OldAgencyEntity(
      joinDate: joinDate ?? this.joinDate,
      leaveDate: leaveDate ?? this.leaveDate,
      agencyId: agencyId ?? this.agencyId,
      img: img ?? this.img,
      joinTimeOnly: joinTimeOnly ?? this.joinTimeOnly,
    );
  }

  @override
  List<Object?> get props => [
    joinDate,
    leaveDate,
    agencyId,
    img,
    joinTimeOnly,
  ];
}
