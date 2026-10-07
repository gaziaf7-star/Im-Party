import 'package:equatable/equatable.dart';

abstract class YoutubeEvent  extends Equatable {
  const YoutubeEvent();
  @override
  List<Object?> get props => [];
}

class ViewYoutubeVideoEvent extends YoutubeEvent {
  final String videoId;
  final double? duration;
  final bool?  notPaused ;

  const ViewYoutubeVideoEvent( { this.notPaused ,  required this.videoId,this.duration});

  @override
  List<Object?> get props => [
    videoId,
    duration,
    notPaused,
  ];
}

class DisposeViewYoutubeVideoEvent extends YoutubeEvent {
  const DisposeViewYoutubeVideoEvent();
}

class InitialViewYoutubeVideoEvent extends YoutubeEvent {
  const InitialViewYoutubeVideoEvent();
}
