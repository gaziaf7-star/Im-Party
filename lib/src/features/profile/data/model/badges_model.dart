import '../../../../../reels_viewer/reels_viewer.dart';

class ImageData extends Equatable {
  final int id;
  final dynamic type;
  final String image;
  final String description;
  final String name;

  const ImageData(
      {required this.image,
      required this.id,
      required this.description,
      required this.type,
      required this.name});

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      type: parseValue<String>(json['type'], ''),
      image: parseValue<String>(json['image'], ''),
      id: parseValue<int>(json['id'], 0),
      description: parseValue<String>(json['description'], ''),
      name: parseValue<String>(json['name'], ''),
    );
  }

  @override
  List<Object?> get props => [image];
}
