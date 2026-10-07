import 'package:equatable/equatable.dart';

class PickUpLuckyBoxEntity extends Equatable {
  final String? type;
  final bool? isWin;
  final int? coins;

  const PickUpLuckyBoxEntity({
    this.type,
    this.isWin,
    this.coins,
  });

  @override
  List<Object?> get props => [
        type,
        isWin,
        coins,
      ];
}
