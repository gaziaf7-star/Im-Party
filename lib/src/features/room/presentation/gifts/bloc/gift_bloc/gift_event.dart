part of 'gift_bloc.dart';

abstract class GiftEvent extends Equatable {
  const GiftEvent();
  @override
  List<Object?> get props => [];
}

class ShowGiftsEvent extends GiftEvent {
  final String pathGift;
  final bool isShowGift;
  final bool? isFamousGift;
  final bool? isShowIntroFullScreen;
  final ShowGiftType giftType;

  const ShowGiftsEvent({
    required this.pathGift,
    this.isFamousGift,
    this.isShowIntroFullScreen,
    required this.isShowGift,
    required this.giftType,
  });

  @override
  List<Object?> get props => [
        pathGift,
        isShowGift,
        isFamousGift,
        isShowIntroFullScreen,
        giftType,
      ];
}

class ShowBannerEvent extends GiftEvent {
  final bool show;
  final Map<String, dynamic>? bannerData;

  const ShowBannerEvent({
    required this.show,
    this.bannerData,
  });

  @override
  List<Object?> get props => [show, bannerData];
}

class UpdateRoomGiftsPriceEvent extends GiftEvent {
  final String price;
  const UpdateRoomGiftsPriceEvent({required this.price});

  @override
  List<Object?> get props => [price];
}

class SetVideoVisibilityEvent extends GiftEvent {
  final bool isVisible;
  const SetVideoVisibilityEvent({required this.isVisible});

  @override
  List<Object?> get props => [isVisible];
}

class ChangeGiftDataEvent extends GiftEvent {
  final int? giftId;
  final int? giftPrice;
  final int? numOfGift;
  final int? categoryId;
  const ChangeGiftDataEvent({
    this.giftId,
    this.numOfGift,
    this.giftPrice,
    this.categoryId,
  });

  @override
  List<Object?> get props => [giftId, numOfGift, giftPrice, categoryId];
}

class SetGiftDownloadingEvent extends GiftEvent {
  final bool isDownloading;
  const SetGiftDownloadingEvent({required this.isDownloading});

  @override
  List<Object?> get props => [isDownloading];
}

/// Consolidates price update + animation display + banner into a single
/// event, reducing per-gift bloc emissions from 3-4 down to 1.
class ShowGiftCompositeEvent extends GiftEvent {
  final String pathGift;
  final ShowGiftType giftType;
  final bool isFamousGift;
  final bool isShowIntroFullScreen;
  final String price;
  final bool showBanner;

  const ShowGiftCompositeEvent({
    required this.pathGift,
    required this.giftType,
    this.isFamousGift = false,
    this.isShowIntroFullScreen = false,
    this.price = '',
    this.showBanner = false,
  });

  @override
  List<Object?> get props => [
        pathGift,
        giftType,
        isFamousGift,
        isShowIntroFullScreen,
        price,
        showBanner,
      ];
}
