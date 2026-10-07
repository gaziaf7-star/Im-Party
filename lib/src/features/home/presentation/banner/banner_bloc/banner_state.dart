
import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/data/model/banner_model.dart';


class BannerState extends Equatable {
  final BannerModel? bannerEntity;
  final RequestState requestState;
  final int countdown;
  final bool isBannerVisible;


  const BannerState({
    this.bannerEntity,
    this.requestState = RequestState.idle,
    this.countdown = 0,
    this.isBannerVisible = false,

  });

  BannerState copyWith({
    BannerModel? bannerEntity,
    RequestState? requestState,
    int? countdown,
    bool? isBannerVisible,

  }) {
    return BannerState(
      bannerEntity: bannerEntity ?? this.bannerEntity,
      requestState: requestState ?? this.requestState,
      countdown: countdown ?? this.countdown,
      isBannerVisible: isBannerVisible ?? this.isBannerVisible,

    );
  }

  @override
  List<Object?> get props => [bannerEntity, requestState,countdown,isBannerVisible];
}
