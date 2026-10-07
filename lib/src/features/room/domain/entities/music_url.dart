import 'package:equatable/equatable.dart';

class MusicUrlEntity extends Equatable {
  final int id;
  final int userId;
  final String url;
  final String name;
  final String createdAt;
  final String updatedAt;
  final bool isLiked;

  const MusicUrlEntity({
    required this.id,
    required this.userId,
    required this.url,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.isLiked,
  });

  MusicUrlEntity copyWith({
    int? id,
    int? userId,
    String? url,
    String? name,
    String? createdAt,
    String? updatedAt,
    bool? isLiked,
  }) {
    return MusicUrlEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      url: url ?? this.url,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  @override
  List<Object> get props =>
      [id, userId, url, createdAt, updatedAt, name, isLiked];
}
