import 'package:general/src/features/room/domain/entities/super_boom_videos_entity.dart';

class SuberBoomVideoseModel extends SupoerBoomVideosEntity {
  const SuberBoomVideoseModel({
    required super.success,
    required super.message,
    required super.data,
  });

  factory SuberBoomVideoseModel.fromJson(Map<String, dynamic> json) {
    return SuberBoomVideoseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] is List ? json['data'] as List : const [])
              .whereType<Map<String, dynamic>>()
              .map((e) => VideoModel.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((e) => (e as VideoModel).toJson()).toList(),
    };
  }
}

class VideoModel extends VideoEntity {
  const VideoModel({
    required super.id,
    required super.level,
    required super.video,
    required super.videoType,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] ?? 0,
      level: json['level'] ?? 0,
      video: json['video'] ?? '',
      videoType: json['image_type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level': level,
      'video': video,
      'image_type': videoType,
    };
  }
}
