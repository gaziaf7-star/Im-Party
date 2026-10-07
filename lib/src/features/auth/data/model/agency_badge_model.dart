import 'package:general/src/core/index.dart';

class AgencyBadgeModel extends Equatable {
  final int? id;
  final String? image;
  final String? imageIntro;
  final String? imageFrame;

  const AgencyBadgeModel({
    this.image,
    this.id,
    this.imageIntro,
    this.imageFrame,
  });

  factory AgencyBadgeModel.fromJson(Map<String, dynamic> json) {
    return AgencyBadgeModel(
      id: parseValue<int>(json['type'], 0),
      image: parseValue<String>(json['image_badge'], ''),
      imageIntro: parseValue<String>(json['image_intro'], ''),
      imageFrame: parseValue<String>(json['image_frame'], ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': id,
      'image_badge': image,
      'image_intro': imageIntro,
      'image_frame': imageFrame,
    };
  }

  @override
  List<Object?> get props => [
        id,
        image,
        imageIntro,
        imageFrame,
      ];
}
