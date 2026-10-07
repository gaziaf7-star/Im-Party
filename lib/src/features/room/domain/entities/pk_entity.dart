import 'package:equatable/equatable.dart';

class PKEntity extends Equatable {
  final int? timeMPk;
  final int? timeSPk;
  final int? team1Score;
  final int? team2Score;
  final dynamic percentageTeam1;
  final dynamic percentageTeam2;
  final int? pkId;

  const PKEntity({
    this.timeMPk,
    this.timeSPk,
    this.team1Score,
    this.team2Score,
    this.percentageTeam1,
    this.percentageTeam2,
    this.pkId,
  });

  @override
  List<Object?> get props => [
    timeMPk,
    timeSPk,
    team1Score,
    team2Score,
    percentageTeam1,
    percentageTeam2,
    pkId,
  ];
}
