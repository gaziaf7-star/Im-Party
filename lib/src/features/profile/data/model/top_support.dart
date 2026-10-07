import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/data/model/top.dart';

class TopSupportModel extends Equatable {
  final List<Top> topUser;
  final List<Top> otherUsers;
  const TopSupportModel({
    required this.topUser,
    required this.otherUsers
  });

  factory TopSupportModel.fromJson(Map<String, dynamic> json) {
    return TopSupportModel(

      topUser: List<Top>.from(
        (json['top'] is List ? json['top'] as List : const [])
            .whereType<Map<String, dynamic>>()
            .map((element) => Top.fromJson(element)),
      ),
      otherUsers: List<Top>.from(
        (json['other'] is List ? json['other'] as List : const [])
            .whereType<Map<String, dynamic>>()
            .map((element) =>  Top.fromJson(element)),
      ),
    );
  }

  @override
  List<Object?> get props => [
    otherUsers,
    topUser
  ];
}
