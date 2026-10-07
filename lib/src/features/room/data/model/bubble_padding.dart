import 'package:general/src/core/index.dart';

class BubblePadding extends Equatable {
  final int id;
  final String image;
  final Data padding;

  const BubblePadding({
    required this.id,
    required this.image,
    required this.padding,
  });

  factory BubblePadding.fromJson(Map<String, dynamic> json) {
    return BubblePadding(
      id: parseValue<int>(json['id'], 0),
      image: parseValue<String>(json['image'], ''),
      padding: json['padding'] is Map<String, dynamic>
          ? Data.fromJson(json['padding'])
          : const Data(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'padding': padding.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, image, padding];

  EdgeInsets? get edgeInsets {
    return EdgeInsets.only(
      top: padding.top.toDouble(),
      left: padding.left.toDouble(),
      right: padding.right.toDouble(),
      bottom: padding.bottom.toDouble(),
    );
  }
}

class Data extends Equatable {
  final int top;
  final int left;
  final int right;
  final int bottom;

  const Data({
    this.top = 0,
    this.left = 0,
    this.right = 0,
    this.bottom = 0,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      top: parseValue<int>(json['top'], 0),
      left: parseValue<int>(json['left'], 0),
      right: parseValue<int>(json['right'], 0),
      bottom: parseValue<int>(json['bottom'], 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'top': top,
      'left': left,
      'right': right,
      'bottom': bottom,
    };
  }

  @override
  List<Object?> get props => [top, left, right, bottom];
}
