import 'package:general/src/features/room/presentation/room_controller.dart';
import 'package:general/src/features/room/presentation/youtube/bloc/youtube/youtube_event.dart';
import 'package:general/src/features/room/presentation/youtube/bloc/youtube/youtube_state.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../../../../core/index.dart';

class YoutubeBloc extends Bloc<YoutubeEvent, YoutubeState> {
  YoutubePlayerController? controller;

  /// The room's "sound off" switch. The video plays on each phone, so
  /// sound-off has to mute this player too, not just the room's voices.
  bool get _roomSoundOff =>
      RoomData.instance.utdController?.mediaController.isAllRemoteAudioMuted
          .value ==
      true;

  /// Whether the current video already got the sound-off applied (the
  /// iframe ignores mute until it is actually playing).
  bool _muteApplied = false;

  /// Mutes/unmutes the video to match the room's "sound off" switch.
  void applyRoomSoundMute() {
    final c = controller;
    if (c == null) return;
    _roomSoundOff ? c.mute() : c.unMute();
    _muteApplied = true;
  }

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
      _muteApplied = false;
      emit(GetViewYoutubeSuccessState(controller!));
      controller!.listen((youtubePlayerValue) async {
        // Start muted if the room's sound is off.
        if (!_muteApplied &&
            youtubePlayerValue.playerState == PlayerState.playing) {
          applyRoomSoundMute();
        }
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
