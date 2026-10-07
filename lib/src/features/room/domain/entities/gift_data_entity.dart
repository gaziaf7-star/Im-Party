class GiftDataEntity {
  final String giftImg;
  final String roomGiftsPrice;
  final bool? isFamousGift;
  final String type;

  const GiftDataEntity({
    required this.giftImg,
    required this.roomGiftsPrice,
    required this.type,
    this.isFamousGift,
  });

  // copyWith method for the entity
  GiftDataEntity copyWith({
    String? giftImg,
    String? roomGiftsPrice,
    bool? isFamousGift,
    String? type,
  }) {
    return GiftDataEntity(
      giftImg: giftImg ?? this.giftImg,
      roomGiftsPrice: roomGiftsPrice ?? this.roomGiftsPrice,
      type: type ?? this.type,
      isFamousGift: isFamousGift ?? this.isFamousGift,
    );
  }
}