import '../../../../core/utils/methods.dart';

class UserIntroModel {
  final String image;
  final int id;
  final int count;

  UserIntroModel({
    required this.image,
    required this.id,
    required this.count,
  });

  factory UserIntroModel.fromJson(Map<String, dynamic> json) {
    return UserIntroModel(
      image: parseValue<String>(json['image'], ''),
      id: parseValue<int>(json['id'], 0),
      count: parseValue<int>(json['count'], 0),
    );
  }
}
