import 'package:general/src/core/index.dart';

class GetVipPrevModel extends Equatable {
  final String? key;
  final String? titleAr;
  final String? titleEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final bool? isActive;
  final bool? isAllowToUser;
  final int? mine;
  final int? minPrice;

  const GetVipPrevModel({
    this.key,
    this.minPrice,
    this.titleAr,
    this.titleEn,
    this.descriptionAr,
    this.descriptionEn,
    this.isActive,
    this.isAllowToUser,
    this.mine,
  });

  factory GetVipPrevModel.fromJson(Map<String, dynamic> map) {
    return GetVipPrevModel(
      key: parseValue<String>(map['key'], ""),
      titleAr: parseValue<String>(map['title'], ""),
      titleEn: parseValue<String>(map['title_en'], ""),
      descriptionAr: parseValue<String>(map['description'], ""),
      descriptionEn: parseValue<String>(map['description_en'], ""),
      mine: parseValue<int>(map['min'], 0),
      minPrice: parseValue<int>(map['min_price'], 0),
      isActive: parseValue<bool>(map['is_active'], false),
      isAllowToUser: parseValue<bool>(map['is_allow_to_user'], false),
    );
  }


  String get description =>
   (   HiveManager().getData(KeysManager.USER_BOX, KeysManager.LANG_CODE_KEY) ==
              'ar'
          ? descriptionAr
          : descriptionEn)??'';

  String get title =>
    (  HiveManager().getData(KeysManager.USER_BOX, KeysManager.LANG_CODE_KEY) ==
              'ar'
          ? titleAr
          : titleEn)??'';

  GetVipPrevModel copyWith({
    String? key,
    String? titleAr,
    String? titleEn,
    String? descriptionAr,
    String? descriptionEn,
    bool? isActive,
    bool? isAllowToUser,
    int? mine,
    int? minPrice,
  }) {
    return GetVipPrevModel(
      key: key ?? this.key,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      isActive: isActive ?? this.isActive,
      isAllowToUser: isAllowToUser ?? this.isAllowToUser,
      mine: mine ?? this.mine,
      minPrice: minPrice ?? this.minPrice,
    );
  }

  @override
  List<Object?> get props => [
        key,
        titleAr,
        titleEn,
        descriptionAr,
        descriptionEn,
        isActive,
        isAllowToUser,
        mine,
        minPrice,
      ];
}
