
import '../../../../core/utils/methods.dart';

class AllLevels {
  final int id;
  final int level;
  final String img;


  AllLevels(
      {
        required this.id,
        required this.level,
        required this.img,
       });

  factory AllLevels.fromJson(Map<String, dynamic> json) {
    return AllLevels(
      id: parseValue<int>(json['id'], 0),
      img: parseValue<String>(json['img'], ''),
      level: parseValue<int>(json['level'], 0),
    );
  }

}
