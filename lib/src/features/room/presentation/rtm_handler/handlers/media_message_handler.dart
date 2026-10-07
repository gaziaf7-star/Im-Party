import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/music/bloc/music_room_bloc.dart';
import 'package:general/src/features/room/presentation/youtube/bloc/youtube/youtube_bloc.dart';
import 'package:general/src/features/room/presentation/youtube/bloc/youtube/youtube_event.dart';
import 'package:general/src/features/room/presentation/youtube/view/youtube_controller.dart';
import 'package:general/src/features/room/room.dart';

import '../room_message_processor.dart';

/// Handles media RTM messages: YouTube video control and music playback.
class MediaMessageHandler {
  const MediaMessageHandler();

  void handle(CategorizedMessage msg, BuildContext? context) {
    final result = msg.payload;

    switch (msg.messageType) {
      case closeVideo:
        di<YoutubeBloc>().add(const InitialViewYoutubeVideoEvent());
        di<YoutubeBloc>().add(const DisposeViewYoutubeVideoEvent());
        break;

      case "youtube_url":
        YouTubeController().initYouTubeVideo(
          url: result[messageContent]['url'],
          status: result[messageContent]['status'],
        );
        break;

      case "stopVideo":
        YouTubeController().stopYouTubeVideo();
        break;

      case "playVideo":
        YouTubeController()
            .playVideo(duration: result[messageContent]['duration']);
        break;

      case "playVideoForOneUser":
        if (YouTubeController.firstVideo) {
          YouTubeController().initYouTubeVideo(
            status: result[messageContent]["status"],
            duration: result[messageContent]['duration'],
            url: result[messageContent]["url"],
          );
        }
        break;

      case "endVideo":
        if (context != null) {
          YouTubeController().endVideo(context: context);
        }
        break;

      // Shared (synced) music — the DJ broadcasts every control action and
      // every listener mirrors it on their own player.
      case "musicSync":
      case "playMusicForOneUser":
        _handleMusicSync(result, msg.messageType);
        break;

      // Legacy "stop for everyone" — route through the receiver path so the
      // listener stops without re-broadcasting a kill.
      case "destroyMusic":
        final bloc = di<MusicRoomBloc>();
        if (bloc.isClosed || bloc.isDisposed) break;
        bloc.add(const ApplyRemoteMusicEvent(
          action: MusicAction.kill,
          songUrl: '',
          volume: 0,
          positionMs: 0,
          controllerId: '',
        ));
        break;
    }
  }

  /// Applies a remote DJ's `musicSync` (or late-joiner `playMusicForOneUser`)
  /// message to the local [MusicRoomBloc]. Ignores our own echoed messages.
  void _handleMusicSync(Map<String, dynamic> result, String messageType) {
    final content = result[messageContent] as Map<String, dynamic>?;
    if (content == null) return;

    final controllerId = content['controller_id']?.toString() ?? '';
    Methods.printLog(
        '🎵 [music] received $messageType sub=${content['sub_action']} from dj=$controllerId');
    // Ignore messages we broadcast ourselves (no self-echo / no loop).
    if (controllerId == MyDataModel.getInstance().id.toString()) return;

    final subAction = content['sub_action']?.toString() ?? '';
    MusicAction action = MusicAction.values.firstWhere(
      (a) => a.toString() == subAction,
      orElse: () => MusicAction.play,
    );
    // A targeted late-joiner sync is always a fresh play.
    if (messageType == "playMusicForOneUser") action = MusicAction.play;

    final bloc = di<MusicRoomBloc>();
    if (bloc.isClosed || bloc.isDisposed) return;

    bloc.add(ApplyRemoteMusicEvent(
      action: action,
      songUrl: content['song_url']?.toString() ?? '',
      songName: content['song_name']?.toString() ?? '',
      volume: (content['volume'] as num?)?.toDouble() ?? 50.0,
      positionMs: (content['position'] as num?)?.toInt() ?? 0,
      controllerId: controllerId,
    ));
  }
}
