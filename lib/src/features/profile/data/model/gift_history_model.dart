import '../../../../core/utils/methods.dart';

class GiftHistoryModel {
  final String num;

  final GiftHistoryItemModel data;

  GiftHistoryModel({required this.num, required this.data});

  factory GiftHistoryModel.fromJson(Map<String, dynamic> json) {
    return GiftHistoryModel(
        num: parseValue<String>(json['num'], ''),
        data: json['gift'] is Map<String, dynamic>
            ? GiftHistoryItemModel.fromJson(json['gift'])
            : GiftHistoryItemModel(img: '', showImg: '', name: ''));
  }
}

class GiftHistoryItemModel {
  final String img;
  final String showImg;
  final String name;
  GiftHistoryItemModel(
      {required this.img, required this.showImg, required this.name});

  factory GiftHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return GiftHistoryItemModel(
      img: parseValue<String>(json['img'], ''),
      showImg: parseValue<String>(json['show_img'], ''),
      name: parseValue<String>(json['name'], ''),
    );
  }
}
