part of 'gift_bloc.dart';

class GiftState extends Equatable {
  final bool showBanner;
  final bool isShowIntroFullScreen;
  final String price;
  final String gift;
  final bool isShowGift;
  final bool isVisible;
  final bool isFamousGift;
  final bool isDownloadingGift;
  final Map<String, dynamic>? bannerData;
  final int giftId;
  final int giftPrice;
  final int numOfGift;
  final int? selectedCategoryId;
  final ShowGiftType? giftType;

  const GiftState({
    this.showBanner = false,
    this.isShowIntroFullScreen = false,
    this.price = '',
    this.gift = '',
    this.isVisible = false,
    this.isShowGift = false,
    this.isFamousGift = false,
    this.isDownloadingGift = false,
    this.giftId = 0,
    this.giftPrice = 0,
    this.numOfGift = -1,
    this.selectedCategoryId,
    this.bannerData,
    this.giftType,
  });

  GiftState copyWith({
    bool? showBanner,
    bool? isShowIntroFullScreen,
    String? price,
    String? gift,
    bool? isVisible,
    bool? isFamousGift,
    bool? isShowGift,
    bool? isDownloadingGift,
    int? giftId,
    int? giftPrice,
    int? numOfGift,
    int? selectedCategoryId,
    ShowGiftType? giftType,
    Map<String, dynamic>? bannerData,
  }) {
    return GiftState(
      showBanner: showBanner ?? this.showBanner,
      isShowIntroFullScreen:
          isShowIntroFullScreen ?? this.isShowIntroFullScreen,
      price: price ?? this.price,
      gift: gift ?? this.gift,
      isVisible: isVisible ?? this.isVisible,
      isShowGift: isShowGift ?? this.isShowGift,
      isDownloadingGift: isDownloadingGift ?? this.isDownloadingGift,
      giftId: giftId ?? this.giftId,
      giftPrice: giftPrice ?? this.giftPrice,
      numOfGift: numOfGift ?? this.numOfGift,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      giftType: giftType ?? this.giftType,
      isFamousGift: isFamousGift ?? this.isFamousGift,
      bannerData: bannerData ?? this.bannerData,
    );
  }

  @override
  List<Object?> get props => [
        showBanner,
        isShowIntroFullScreen,
        price,
        gift,
        isVisible,
        isShowGift,
        isDownloadingGift,
        numOfGift,
        giftPrice,
        giftId,
        selectedCategoryId,
        giftType,
        isFamousGift,
        bannerData
      ];
}
