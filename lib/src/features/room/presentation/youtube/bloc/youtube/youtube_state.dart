
import 'package:equatable/equatable.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

abstract class YoutubeState extends Equatable {
  const YoutubeState();
  @override
  List<Object?> get props => [];
}

class YoutubeStateInitial extends YoutubeState {}

class GetViewYoutubeSuccessState extends YoutubeState {
  final YoutubePlayerController controller;

  const GetViewYoutubeSuccessState(this.controller);
}

class DisposeYoutubeSuccessState extends YoutubeState {
  const DisposeYoutubeSuccessState();
}

class YoutubeStateLoading extends YoutubeState {}

