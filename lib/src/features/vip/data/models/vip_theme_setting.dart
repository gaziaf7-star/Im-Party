import 'package:general/src/core/index.dart';

class VipThemeSetting extends Equatable {
  final int vip;
  final String background;

  const VipThemeSetting({
    required this.vip,
    required this.background,
  });

  factory VipThemeSetting.fromJson(Map<String, dynamic> json) {
    return VipThemeSetting(
      vip: parseValue<int>(json['vip'], 0),
      background: parseValue<String>(json['background'], ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vip': vip,
      'background': background,
    };
  }

  @override
  List<Object?> get props => [vip, background];

  /// Returns the full background URL if background is not empty
  String? get backgroundUrl {
    if (background.isEmpty) return null;
    return EndPoints.getImage(background);
  }
}
