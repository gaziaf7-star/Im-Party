import 'package:general/src/features/room/domain/entities/music_url.dart';

class MusicModel extends MusicUrlEntity {
  const MusicModel({
    required super.id,
    required super.userId,
    required super.url,
    required super.name,
    required super.createdAt,
    required super.updatedAt,
    required super.isLiked,
  });

  factory MusicModel.fromJson(Map<String, dynamic> json) {
    return MusicModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      url: json['url'] ?? '',
      name: json['name'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      isLiked: false,
    );
  }
}
