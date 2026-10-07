import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

class CloseEffectModel extends CloseEffectEntity {
  CloseEffectModel({
    super.showGift,
    super.showEntring,
    super.showBanner,
  });

  factory CloseEffectModel.fromJson(Map<String, dynamic> json) {
    return CloseEffectModel(
      showGift: parseValue<bool>(
        json['show_git'],
        true,
      ),
      showEntring: parseValue<bool>(json['show_intro'], false),
      showBanner: parseValue<bool>(json['show_banner'], false),
    );
  }
}
