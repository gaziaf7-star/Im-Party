import 'package:general/src/features/room/domain/entities/pick_up_lucky_box_entity.dart';

class PickUpLuckyBoxModel extends PickUpLuckyBoxEntity {
  const PickUpLuckyBoxModel({
    super.type,
    super.coins,
    super.isWin,
  });

  factory PickUpLuckyBoxModel.fromJson(dynamic json) {
    return PickUpLuckyBoxModel(
      type: json['type'] ?? "",
      coins: json['coins'] ?? 0,
      isWin: json['is_win'] ?? false,
    );
  }

  @override
  List<Object?> get props => [
        type,
        coins,
        isWin,
      ];
}
