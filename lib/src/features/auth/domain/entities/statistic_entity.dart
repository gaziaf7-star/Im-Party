import 'package:general/src/core/index.dart';

class StatisticEntity extends Equatable {
  final int? visitors;
  final int? like;
  final int? followers;
  final String? bio;

  const StatisticEntity({
     this.visitors,
     this.like,
     this.followers,
     this.bio,
  });

  @override
  List<Object?> get props => [
        visitors,
        like,
        followers,
        bio,
      ];
}
