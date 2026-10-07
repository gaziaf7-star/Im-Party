import 'package:general/src/core/index.dart';

class CloseEffectEntity extends Equatable {
  bool? showGift;
  bool? showEntring;
  bool? showBanner;

  CloseEffectEntity({
    this.showGift,
    this.showEntring,
    this.showBanner,
  });

  CloseEffectEntity copyWith({
    bool? showGift,
    bool? showEntring,
    bool? showBanner,
  }) {
    return CloseEffectEntity(
      showGift: showGift ?? this.showGift,
      showEntring: showEntring ?? this.showEntring,
      showBanner: showBanner ?? this.showBanner,
    );
  }

  @override
  List<Object?> get props => [showGift, showEntring, showBanner];
}
