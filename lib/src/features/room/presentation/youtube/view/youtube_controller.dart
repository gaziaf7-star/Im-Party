import 'package:general/src/features/room/presentation/youtube/bloc/youtube/youtube_bloc.dart';
import 'package:general/src/features/room/presentation/youtube/bloc/youtube/youtube_event.dart';
import '../../../../../core/index.dart';

class YouTubeController {
  static bool firstVideo = true;
  static ValueNotifier<bool> isCinemaMode = ValueNotifier<bool>(false);

  void initYouTubeVideo(
      {required String url, required String status, double? duration}) {
    firstVideo = false;
    di<YoutubeBloc>().add(const InitialViewYoutubeVideoEvent());
    Future.delayed(const Duration(milliseconds: 300), () {
      di<YoutubeBloc>().add(
        ViewYoutubeVideoEvent(
          videoId: url,
          duration: duration ?? 0.0,
          notPaused: status == "play" ? true : false,
        ),
      );
    });
  }

  void stopYouTubeVideo() {
    di<YoutubeBloc>().controller?.pauseVideo();
  }

  void playVideo({required double duration}) {
    di<YoutubeBloc>()
        .controller
        ?.seekTo(allowSeekAhead: true, seconds: duration);

    di<YoutubeBloc>().controller?.playVideo();
  }

  void endVideo({required BuildContext context}) {
    di<YoutubeBloc>().add(const DisposeViewYoutubeVideoEvent());
  }
}
