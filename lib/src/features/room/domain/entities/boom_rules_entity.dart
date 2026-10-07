import 'package:equatable/equatable.dart';

class BombRulesEntity extends Equatable {
  final int id;
  final String rulesAr;
  final String rulesEn;
  final String content;

  const BombRulesEntity({
    required this.id,
    required this.rulesAr,
    required this.rulesEn,
    required this.content,
  });

  @override
  List<Object?> get props => [
        id,
        rulesAr,
        rulesEn,
        content,
      ];
}
