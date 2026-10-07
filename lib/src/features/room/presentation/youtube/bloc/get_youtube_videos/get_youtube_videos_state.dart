import 'package:equatable/equatable.dart';
import 'package:youtube_api/youtube_api.dart';

abstract class GetYoutubeState extends Equatable {
  const GetYoutubeState();
}

class GetYoutubeStateInitial extends GetYoutubeState {
  @override
  List<Object?> get props => [];
}

class GetYoutubeStateLoading extends GetYoutubeState {
  @override
  List<Object?> get props => [];
}

class GetVideosYoutubeSuccessState extends GetYoutubeState {
  final List<YouTubeVideo> results;

  const GetVideosYoutubeSuccessState(this.results);
  @override
  List<Object?> get props => [results];
}

class GetYoutubeStateError extends GetYoutubeState {
  final String message;
  const GetYoutubeStateError(this.message);

  @override
  List<Object?> get props => [message];
}
