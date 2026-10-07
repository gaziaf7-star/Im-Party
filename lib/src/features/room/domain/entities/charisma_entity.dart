import 'package:equatable/equatable.dart';

class CharismaEntity extends Equatable {
  final int userId;
  final String total;
  final int position;

  /// Precise cumulative charisma carried on the wire alongside the abbreviated
  /// [total] string. The string is for DISPLAY only; this integer is the
  /// authoritative value used for the badge-tier lookup and the monotonic-merge
  /// (reject-sudden-drop) guard, so a round-trip through the lossy abbreviation
  /// no longer flips the badge near a threshold.
  final int totalValue;

  const CharismaEntity({
    required this.userId,
    required this.total,
    required this.position,
    this.totalValue = 0,
  });

  @override
  List<Object?> get props => [userId, total, position, totalValue];
}


class CharismaExtraDataEntity extends Equatable {
  final List<CharismaEntity>? charisma;

  const CharismaExtraDataEntity({required this.charisma});

  @override
  List<Object?> get props => [charisma];
}

