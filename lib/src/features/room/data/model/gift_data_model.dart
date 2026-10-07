import 'package:general/src/features/room/domain/entities/gift_data_entity.dart';

class GiftDataModel extends GiftDataEntity {
  const GiftDataModel({
    required super.giftImg,
    required super.roomGiftsPrice,
    required super.type,
    required super.isFamousGift,
  });

  // copyWith method for GiftData
  @override
  GiftDataModel copyWith({
    String? giftImg,
    String? roomGiftsPrice,
    bool? isFamousGift,
    String? type,
  }) {
    return GiftDataModel(
      giftImg: giftImg ?? this.giftImg,
      roomGiftsPrice: roomGiftsPrice ?? this.roomGiftsPrice,
      type: type ?? this.type,
      isFamousGift: isFamousGift ?? this.isFamousGift,
    );
  }

  // Conversion to GiftDataEntity
  GiftDataEntity toEntity() {
    return GiftDataEntity(
      giftImg: giftImg,
      roomGiftsPrice: roomGiftsPrice,
      type: type,
      isFamousGift: isFamousGift,
    );
  }

  // Conversion from GiftDataEntity to GiftData
  static GiftDataModel fromEntity(GiftDataEntity entity) {
    return GiftDataModel(
      giftImg: entity.giftImg,
      roomGiftsPrice: entity.roomGiftsPrice,
      type: entity.type,
      isFamousGift: entity.isFamousGift,
    );
  }
}