import 'package:general/src/features/profile/domain/entities/replace_with_gold_entity.dart';

import '../../../../core/utils/methods.dart';

class ReplaceWithGoldModel extends ReplaceWithGoldEntity {
  const ReplaceWithGoldModel({required super.diamonds, required super.data});
  factory ReplaceWithGoldModel.fromJson(Map<String, dynamic> json) {
    return ReplaceWithGoldModel(
      diamonds: parseValue<int>(json['message'], 0),
      data: List<ReplaceWithGoldItemModel>.from(
          json["data"].map((x) => ReplaceWithGoldItemModel.fromJson(x))),
    );
  }
}

class ReplaceWithGoldItemModel extends ReplaceWithGoldItemEntity {
  const ReplaceWithGoldItemModel(
      {required super.id, required super.coin, required super.diamonds});
  factory ReplaceWithGoldItemModel.fromJson(Map<String, dynamic> json) {
    return ReplaceWithGoldItemModel(
        coin: parseValue<int>(json['value'], 0),
        id: parseValue<int>(json['id'], 0),
        diamonds: parseValue<int>(json['diamonds'], 0));
  }
}
