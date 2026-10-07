import 'package:general/src/core/index.dart';

abstract class BaseShowBannersEvent extends Equatable {
  const BaseShowBannersEvent();

  @override
  List<Object?> get props => [];
}


class ShowBannerInAppEvent extends BaseShowBannersEvent {
  final Map<String, dynamic> bannerData;
  const ShowBannerInAppEvent({required this.bannerData});

  @override
  List<Object?> get props => [bannerData];
}