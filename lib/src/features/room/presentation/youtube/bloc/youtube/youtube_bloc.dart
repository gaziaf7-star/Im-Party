import 'package:general/src/features/room/presentation/room_controller.dart';
import 'package:general/src/features/room/presentation/youtube/bloc/youtube/youtube_event.dart';
import 'package:general/src/features/room/presentation/youtube/bloc/youtube/youtube_state.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../../../../core/index.dart';

class YoutubeBloc extends Bloc<YoutubeEvent, YoutubeState> {
  YoutubePlayerController? controller;

  YoutubeBloc() : super(YoutubeStateInitial()) {
    on<ViewYoutubeVideoEvent>((event, emit) async {
      bool showController =
          RoomData.instance.room.ownerId == MyDataModel.getInstance().id;
      emit(YoutubeStateLoading());
      String? videoId = YoutubePlayerController.convertUrlToId(event.videoId);

      controller = event.duration == null
          ? YoutubePlayerControllerEx.fromVideoId(
              videoId: videoId ?? '',
              autoPlay: event.notPaused ?? true,
              params: YoutubePlayerParams(
                showFullscreenButton: false,
                showControls: showController,
                origin: 'https://www.youtube-nocookie.com',
              ),
            )
          : YoutubePlayerControllerEx.fromVideoId(
              videoId: videoId ?? '',
              startSeconds: event.duration! + 1,
              autoPlay: event.notPaused ?? true,
              params: YoutubePlayerParams(
                showFullscreenButton: false,
                showControls: showController,
                origin: 'https://www.youtube-nocookie.com',
              ),
            );
      emit(GetViewYoutubeSuccessState(controller!));
      controller!.listen((youtubePlayerValue) async {
        if (showController) {
          if (youtubePlayerValue.playerState == PlayerState.paused ||
              youtubePlayerValue.playerState == PlayerState.ended) {
            sendRoomData(data: {
              "message": 'stopVideo',
            });
          }
          if (youtubePlayerValue.playerState == PlayerState.playing) {
            double duration = await controller!.currentTime;
            sendRoomData(data: {"message": 'playVideo', "duration": duration});
          }
        }
      });
    });

    on<DisposeViewYoutubeVideoEvent>((event, emit) {
      controller?.close();
      controller = null;
      emit(const DisposeYoutubeSuccessState());
    });
    on<InitialViewYoutubeVideoEvent>((event, emit) {
      emit(YoutubeStateInitial());
    });
  }
}

extension YoutubePlayerControllerEx on YoutubePlayerController {
  static YoutubePlayerController fromVideoId({
    required String videoId,
    YoutubePlayerParams params = const YoutubePlayerParams(),
    bool autoPlay = false,
    double? startSeconds,
    double? endSeconds,
  }) {
    final controller = YoutubePlayerController(params: params);
    final url = 'http://www.youtube.com/v/$videoId';

    if (autoPlay) {
      controller.loadVideoByUrl(
        mediaContentUrl: url,
        startSeconds: startSeconds,
        endSeconds: endSeconds,
      );
    } else {
      controller.cueVideoByUrl(
        mediaContentUrl: url,
        startSeconds: startSeconds,
        endSeconds: endSeconds,
      );
    }

    return controller;
  }
}
