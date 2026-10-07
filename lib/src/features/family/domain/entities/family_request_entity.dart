import 'package:equatable/equatable.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';

class FamilyRequestEntity extends Equatable {
  final int id;
  final UserEntity user;
  final String time;

  const FamilyRequestEntity({
    required this.user,
    required this.id,
    required this.time,
  });

  @override
  List<Object?> get props => [
        user,
        id,
        time,
      ];
}
