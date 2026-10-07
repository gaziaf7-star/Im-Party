import 'package:general/src/features/room/domain/entities/send_gift_entity.dart';

class SendGiftModel extends SendGiftEntity {
  const SendGiftModel({
    required super.success,
    required super.message,
    super.data,
  });

  factory SendGiftModel.fromJson(Map<String, dynamic> json) {
    return SendGiftModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] is Map<String, dynamic>
          ? SendGiftDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data != null ? (data as SendGiftDataModel).toJson() : null,
    };
  }

  SendGiftEntity toEntity() {
    return SendGiftEntity(
      success: success,
      message: message,
      data: data != null
          ? SendGiftDataEntity(
              ids: (data as SendGiftDataModel).ids,
            )
          : null,
    );
  }
}

class SendGiftDataModel extends SendGiftDataEntity {
  const SendGiftDataModel({
    required super.ids,
  });

  factory SendGiftDataModel.fromJson(Map<String, dynamic> json) {
    return SendGiftDataModel(
      ids: (json['ids'] is List ? json['ids'] as List<dynamic> : null)
              ?.map((e) => e as int)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ids': ids,
    };
  }
}