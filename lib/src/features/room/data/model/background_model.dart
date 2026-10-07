import 'package:general/src/features/room/domain/entities/background_entity.dart';

import '../../../../core/utils/methods.dart';

class BackgroundModel extends BackGroundEntity {

  const BackgroundModel({required super.id, required super.img});

  factory BackgroundModel.fromJson(Map<String, dynamic> json) {
    return BackgroundModel(
      id: parseValue<int>(json['id'], 0),
      img: parseValue<String>(json['img'], ''),
    );
  }


  @override
  List<Object?> get props => [id, img];
}
