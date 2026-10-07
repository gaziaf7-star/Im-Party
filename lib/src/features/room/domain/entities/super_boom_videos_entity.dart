import 'package:equatable/equatable.dart';

class SupoerBoomVideosEntity extends Equatable {
  final bool success;
  final String message;
  final List<VideoEntity> data;

  const SupoerBoomVideosEntity({
    required this.success,
    required this.message,
    required this.data,
  });

  @override
  List<Object?> get props => [success, message, data];
}


class VideoEntity extends Equatable {
  final int id;
  final int level;
  final String video;
  final String videoType;

  const VideoEntity({
    required this.id,
    required this.level,
    required this.video,
    required this.videoType,
  });

  @override
  List<Object?> get props => [id, level, video, videoType];
}