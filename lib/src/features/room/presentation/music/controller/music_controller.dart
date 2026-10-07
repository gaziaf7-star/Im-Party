import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/music/bloc/music_room_bloc.dart';
import 'package:general/src/features/room/presentation/room_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MusicController {
  MusicController._privateConstructor();

  static final MusicController _instance =
      MusicController._privateConstructor();

  factory MusicController() {
    return _instance;
  }

  static const String _volumeKey = 'music_volume';

  static Future<void> cacheVolume(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, value);
  }

  static Future<double> getCachedVolume() async {
    final prefs = await SharedPreferences.getInstance();
    // The value can be persisted as an int when the volume arrives from the
    // realtime musicSync payload (JSON numbers without a fraction decode to int),
    // so reading it back with getDouble would throw an int->double cast error.
    final cached = prefs.get(_volumeKey);
    if (cached is num) return cached.toDouble();
    return 50.0;
  }

  static String formatTime(Duration duration) {
    int totalSeconds = duration.inSeconds;
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;

    String twoDigits(int n) => n.toString().padLeft(2, '0');

    return "${twoDigits(minutes)}:${twoDigits(seconds)}";
  }

  /// Builds the `musicSync` payload describing the current shared-music state.
  /// Carries `controller_id` so receivers know who the active DJ is and can
  /// ignore their own echoed messages. `position` is in milliseconds.
  Map<String, dynamic> buildMusicSyncPayload(MusicAction action) {
    final bloc = di<MusicRoomBloc>();
    final playing = bloc.state.nowPlaying;
    final songs = bloc.state.musicesInRoom;
    final songName =
        (playing >= 0 && playing < songs.length) ? songs[playing].name : '';

    return {
      'message': 'musicSync',
      'sub_action': action.toString(),
      'song_url': bloc.state.songUrl ?? '',
      'song_name': songName,
      'volume': bloc.state.volume,
      'position': bloc.state.currentPosition.inMilliseconds,
      'now_playing': bloc.state.nowPlaying,
      'controller_id': MyDataModel.getInstance().id.toString(),
    };
  }

  /// Broadcasts the given music [action] to every user in the room via the
  /// LiveKit data channel. Only the active DJ should call this.
  void syncMusicAction(MusicAction action) {
    sendRoomData(data: buildMusicSyncPayload(action));
  }
}
