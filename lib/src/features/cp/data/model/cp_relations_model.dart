import '../../../../core/index.dart';

class CpRelationsModel {
  final bool success;
  final String message;
  final List<CpRelationData> data;
  final dynamic paginates;

  CpRelationsModel({
    required this.success,
    required this.message,
    required this.data,
    this.paginates,
  });

  factory CpRelationsModel.fromJson(Map<String, dynamic> json) {
    return CpRelationsModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: List<CpRelationData>.from(
        (json['data'] is List ? json['data'] as List<dynamic> : const [])
            .whereType<Map<String, dynamic>>()
            .map(
          (item) => CpRelationData.fromJson(item),
        ),
      ),
      paginates: json['paginates'],
    );
  }

}

class CpRelationData {
  final int id;
  final String title;
  final String? image;
  final int price;
  final int userCount;

  CpRelationData({
    required this.id,
    required this.title,
    this.image,
    required this.price,
    required this.userCount,
  });

  factory CpRelationData.fromJson(Map<String, dynamic> json) {
    return CpRelationData(
      id: parseValue<int>(json['id'], 0),
      title: parseValue<String>(json['title'], ''),
      image:parseValue<String>(json['image'], ''),
      price: parseValue<int>(json['price'], 0),
      userCount: parseValue<int>(json['user_count'], 0),
    );
  }


}


