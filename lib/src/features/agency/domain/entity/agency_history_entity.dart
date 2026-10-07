import 'package:equatable/equatable.dart';


class AgencyHistoryEntity extends Equatable {
  final int id;
  final String uuid;
  final String image;
  final String name;
  final int totalUsed;
  final int diamonds;

  const AgencyHistoryEntity({
    required this.id,
    required this.uuid,
    required this.image,
    required this.name,
    required this.totalUsed,
    required this.diamonds,
  });

  @override
  List<Object?> get props => [id, uuid, image, name, totalUsed, diamonds];
}
