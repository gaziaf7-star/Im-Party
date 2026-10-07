import 'package:equatable/equatable.dart';

class LuckyBoxEntity extends Equatable {
  final List<TypeBoxEntity> normalBox;
  final List<TypeBoxEntity> superBox;

  const LuckyBoxEntity({required this.normalBox, required this.superBox});

  @override
  List<Object?> get props => [normalBox, superBox];
}

class TypeBoxEntity extends Equatable {
  final int? id;
  final String? type;
  final int? coins;
  final dynamic userNum;
  final bool? isLabel;
  final String? time;

  const TypeBoxEntity({
    required this.id,
    required this.type,
    required this.coins,
    required this.userNum,
    required this.isLabel,
    required this.time,
  });

  @override
  List<Object?> get props => [id, type, coins, userNum, isLabel, time];
}
