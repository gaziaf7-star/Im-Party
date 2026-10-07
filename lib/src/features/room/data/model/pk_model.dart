import 'package:general/src/features/room/domain/entities/pk_entity.dart';

import '../../../../core/utils/methods.dart';

class PKModel extends PKEntity {

  const PKModel(
      {super.timeMPk,
      super.timeSPk,
      super.team1Score,
      super.team2Score,
      super.percentageTeam2,
      super.percentageTeam1,
      super.pkId});

  factory PKModel.fromJson(Map<String, dynamic> json) {
    return PKModel(
      timeMPk: parseValue<int>(json['m'], 0),
      timeSPk: parseValue<int>(json['s'], 0),
      team1Score: parseValue<int>(json['team1_score'], 0),
      team2Score: parseValue<int>(json['team2_score'], 0),
      percentageTeam1: parseValue<double>(json['t1_scale'], 0.0),
      percentageTeam2: parseValue<double>(json['t2_scale'], 0.0),
      pkId: parseValue<int>(json['id'], 0),
    );
  }


  @override
  List<Object?> get props => [
        team1Score,
        team2Score,
        timeSPk,
        timeMPk,
        percentageTeam1,
        percentageTeam2
      ];
}
