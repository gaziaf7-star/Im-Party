import 'package:general/src/features/live_room/presentation/live_room_data.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/music/bloc/music_room_event.dart';
import 'package:general/src/features/room/presentation/music/bloc/music_room_states.dart';
import 'package:general/src/features/room/presentation/music/controller/music_controller.dart';
import 'package:general/src/features/room/presentation/room_controller.dart';

export 'music_room_event.dart';
export 'music_room_states.dart';

const validAudioExtensions = [
  'aac',
  'midi',
  'mp3',
  'wav',
  'm4a',
  'flac',
  'wma',
  'opus',
  'amr',
];

bool _isValidAudio(String uri) {
  if (uri.isEmpty) return false;
  // Remote (uploaded) songs are always playable by URL, even if the URL has
  // no recognizable file extension.
  if (uri.startsWith('http')) return true;
  final extension = uri.split('.').last.toLowerCase();
  return validAudioExtensions.contains(extension);
}

class MusicRoomBloc extends Bloc<MusicRoomEvent, MusicRoomStates> {
  Timer? _updateTimer;
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  /// True only when the shared player is genuinely producing audio right now —
  /// not merely when the [MusicRoomStates.isSongPlaying] UI flag is set. The
  /// flag can stick at `true` after a track ends or fails to load, which would
  /// otherwise make us sync a late joiner onto silent/finished music that no
  /// one else in the room can actually hear. Gate the late-joiner sync on this.
  bool get isAudioActuallyPlaying =>
      !_isDisposed &&
      state.isSongPlaying &&
      state.audioPlayer.state == PlayerState.playing &&
      (state.songUrl?.isNotEmpty ?? false);

  /// True while applying a remote DJ's action, so local actions performed in
  /// response are NOT re-broadcast (prevents feedback loops).
  bool _suppressBroadcast = false;

  /// True when this user is a listener mirroring a remote DJ (not the DJ).
  /// Receivers must not auto-advance to the next track — only the DJ drives
  /// next/prev, broadcasting a fresh `play` each time.
  bool _isReceiverMode = false;

  MusicRoomBloc() : super(MusicRoomStates(audioPlayer: AudioPlayer())) {
    _bindMusicModeToPlayback(state.audioPlayer);
    on<GetMusicRoomListEvent>(_fetchMusicList);
    on<DestroyMusicRoomListEvent>(_destroyMusic);
    on<RepeatMusicRoomEvent>(_repeat);
    on<SetIndexSongPlayingRoomEvent>(_setIndexMusic);
    on<DeleteMusicRoomFromCacheEvent>(_deleteMusic);
    on<PlayMusicRoomEvent>(_playMusic);
    on<PlayRandomMusicRoomEvent>(_playRandomMusic);
    on<AddMusicRoomToCacheEvent>(_addMusic);
    on<AddServerMusicRoomEvent>(_addServerMusic);
    on<ApplyRemoteMusicEvent>(_applyRemoteMusic);
    on<ControlPlayingMusicRoomEvent>(_controllPlayingMusic);
    on<NextAndPreviousMusicRoomEvent>(_nextMusic);
    on<LoadMusicRoomEvent>(_loadMusic);
    on<SetVolumeRoomEvent>(_setVolume);
    on<SeekToPositionRoomEvent>(_seekToPosition);
    on<MusicRoomUpdatePositionEvent>(_updatePosition);
    on<ExitRoomMusicRoomEvent>(_exitRoom);
    on<SetPlayMusicForReceiverRoomEvent>(_setPlayMusicForReceiver);
  }

  // ---------------------- Shared-music broadcast helpers ----------------------

  String get _myId => MyDataModel.getInstance().id.toString();

  /// URI of the song the local player is loading/playing.
  String _currentUri = '';

  /// Music reaches listeners by ONE route only, or they hear it twice:
  ///  * server songs (http): every phone plays its own synced copy, so the
  ///    DJ must NOT also push the music through the mic;
  ///  * songs from the DJ's own phone storage: listeners can't load that
  ///    path, so the DJ's mic carries the music and listeners don't play it.
  bool _viaMic(String uri) => uri.isNotEmpty && !uri.startsWith('http');

  bool get _isDj => RoomData.instance.musicControllerUserId == _myId;

  /// The room's "sound off" (mute all remote audio) switch.
  bool get _roomSoundOff =>
      RoomData.instance.utdController?.mediaController.isAllRemoteAudioMuted
              .value ==
          true ||
      LiveRoomData.instance.liveController?.mediaController
              .isAllRemoteAudioMuted.value ==
          true;

  /// Player volume (0..1) for a 0..100 [volume]. Room "sound off" also
  /// silences the local music, since listeners play it locally rather than
  /// receive it through the room. The DJ's player is left alone when it is
  /// feeding the mic, or the music would cut out for everyone.
  double _volumeFor(double volume) {
    if (_roomSoundOff && !(_isDj && _viaMic(_currentUri))) return 0;
    return volume / 100;
  }

  /// Re-applies the room "sound off" switch to the music player. Called
  /// whenever that switch changes.
  Future<void> applyRoomSoundMute() =>
      _safeAudioOp(() => state.audioPlayer.setVolume(_volumeFor(state.volume)));

  /// Broadcasts [action] to all room users. No-op when applying a remote
  /// action (avoids feedback loops) or when this user is not the active DJ
  /// (only the DJ may drive shared playback).
  void _broadcast(MusicAction action) {
    if (_suppressBroadcast) {
      Methods.printLog('🎵 [music] broadcast skipped (applying remote) → $action');
      return;
    }
    if (RoomData.instance.musicControllerUserId != _myId) {
      Methods.printLog(
          '🎵 [music] broadcast skipped (not DJ: dj=${RoomData.instance.musicControllerUserId}, me=$_myId) → $action');
      return;
    }
    Methods.printLog('🎵 [music] broadcasting $action');
    MusicController().syncMusicAction(action);
  }

  /// Marks this user as the active DJ (the one controlling shared playback).
  void _claimDj() {
    _isReceiverMode = false;
    RoomData.instance.musicControllerUserId = _myId;
  }

  /// Releases DJ control if this user currently holds it.
  void _releaseDj() {
    if (RoomData.instance.musicControllerUserId == _myId) {
      RoomData.instance.musicControllerUserId = null;
    }
  }

  /// Runs a receiver-side audio op, guarded against a disposed player/bloc.
  Future<void> _safeAudioOp(Future<void> Function() op) async {
    if (_isDisposed || isClosed) return;
    try {
      await op();
    } catch (e) {
      debugPrint('Receiver audio op failed: $e');
    }
  }

  /// Runs a player op that returns a value, re-checking disposal IMMEDIATELY
  /// before the call and swallowing platform exceptions raised because the
  /// player was disposed mid-flight (TOCTOU). Returns null when disposed or on
  /// failure so callers can degrade gracefully instead of crashing.
  Future<T?> _safeAudioRead<T>(Future<T?> Function() op) async {
    if (_isDisposed || isClosed) return null;
    try {
      return await op();
    } catch (e) {
      debugPrint('Player read op failed (likely disposed): $e');
      return null;
    }
  }

  String _nameFromUrl(String url) {
    try {
      final segments = Uri.parse(url).pathSegments;
      return segments.isNotEmpty ? segments.last : 'Music';
    } catch (_) {
      return 'Music';
    }
  }

  Future<void> _playSongAtIndex(
      int index, Emitter<MusicRoomStates> emit, {int attempt = 0}) async {
    if (_isDisposed) return;
    if (index < 0 || index >= state.musicesInRoom.length) return;

    final current = state.musicesInRoom[index];
    final uri = current.uri;

    if (!_isValidAudio(uri)) {
      debugPrint("Skipped: Not a valid audio file → $uri");
      return;
    }

    try {
      // Re-check disposal IMMEDIATELY before each await: the player can be
      // disposed by close()/_exitRoom between any two awaits, and calling a
      // disposed player throws a PlatformException (the C8 crash source).
      if (_isDisposed || isClosed) return;
      await state.audioPlayer.stop();

      if (_isDisposed || isClosed) return;
      _currentUri = uri;
      if (uri.startsWith('http')) {
        await state.audioPlayer.setSource(UrlSource(uri));
      } else {
        await state.audioPlayer.setSource(DeviceFileSource(uri));
      }

      if (_isDisposed || isClosed) return;
      await state.audioPlayer.resume();

      if (_isDisposed || isClosed) return;
      await state.audioPlayer.setVolume(_volumeFor(state.volume));

      if (_isDisposed || isClosed) return;
      emit(state.copyWith(
        nowPlaying: index,
        songUrl: uri,
        isPlayingSongFloatAnimation: true,
        isPlayingSongInnerDialogUi: true,
        isSongPlaying: true,
        currentPosition: Duration.zero,
      ));
    } catch (e) {
      debugPrint("Failed to play song at index $index → $e");
      // The player was stopped above but loading failed, so it is now silent.
      // Clear the playing state instead of leaving isSongPlaying stuck at true —
      // otherwise a late joiner would be synced onto music that isn't audible.
      if (!_isDisposed && !isClosed) {
        if (!_isReceiverMode) _releaseDj();
        stopUpdatingPosition();
        emit(state.copyWith(
          isSongPlaying: false,
          isPlayingSongFloatAnimation: false,
          isPlayingSongInnerDialogUi: false,
        ));
      }

      // Auto-skip a broken track (e.g. an upload that silently became a
      // non-audio file server-side, confirmed via curl returning
      // image/png for a "song" URL) instead of leaving playback dead on
      // an unplayable entry. Only the DJ advances — a receiver only ever
      // mirrors whatever the DJ broadcasts, so it must not pick its own
      // next track. Capped at one full pass over the list so an all-broken
      // playlist gives up instead of recursing forever.
      if (!_isReceiverMode &&
          !_isDisposed &&
          !isClosed &&
          state.musicesInRoom.length > 1 &&
          attempt < state.musicesInRoom.length - 1) {
        final nextIndex = (index + 1) % state.musicesInRoom.length;
        await _playSongAtIndex(nextIndex, emit, attempt: attempt + 1);
      }
    }
  }

  /// Becomes the DJ and broadcasts the current song to every user. Called at
  /// the event-handler level (NOT inside [_playSongAtIndex]) so the broadcast
  /// fires even if local audio loading throws — mirroring the live-room flow.
  void _claimDjAndBroadcastPlay() {
    _claimDj();
    _broadcast(MusicAction.play);
  }

  Future<void> _fetchDurationSafe(Emitter<MusicRoomStates> emit) async {
    const maxAttempts = 10;
    Duration? bestDuration;

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      // The bloc/player can be disposed during this multi-second polling loop;
      // bail out before touching the player to avoid PlatformException crashes.
      if (_isDisposed || isClosed) return;
      final current = await _safeAudioRead(state.audioPlayer.getDuration);

      if (current != null && current > Duration.zero) {
        bestDuration = bestDuration == null || current > bestDuration
            ? current
            : bestDuration;

        await Future.delayed(const Duration(seconds: 1));
        if (_isDisposed || isClosed) return;
        final check = await _safeAudioRead(state.audioPlayer.getDuration);

        if (check != null && check >= bestDuration) {
          if (_isDisposed || isClosed) return;
          emit(state.copyWith(totalDuration: check));
          return;
        }
      } else {
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    if (_isDisposed || isClosed) return;
    emit(state.copyWith(totalDuration: bestDuration ?? Duration.zero));
  }


  /// Keep the RTC capture in step with playback, so viewers actually hear the
  /// music.
  ///
  /// The music is played by a LOCAL audio player, out of the loudspeaker.
  /// LiveKit has no audio-mixing API, so the only route into the room is back
  /// through the microphone — and WebRTC's echo canceller removes loudspeaker
  /// output from the mic by design. The result was a host hearing their own
  /// music while every viewer heard nothing.
  ///
  /// Driven off the player's own state stream rather than from each play/pause
  /// call site: there are a dozen of those and they WILL drift.
  void _bindMusicModeToPlayback(AudioPlayer player) {
    player.onPlayerStateChanged.listen((playerState) {
      final playing = playerState == PlayerState.playing;
      // Only the DJ publishes; a listener mirroring someone else's track must
      // not degrade their own mic for audio they are merely receiving.
      // ...and only for songs from the DJ's own storage. Server songs are
      // already played on every phone; sending them through the mic too
      // made listeners hear the music twice.
      _applyMusicMode(playing && _isDj && _viaMic(_currentUri));
    });
  }

  /// Whichever room is live — audio or video — gets the mode change. Both are
  /// checked because this one bloc serves both room types.
  void _applyMusicMode(bool enabled) {
    RoomData.instance.utdController?.mediaController.setMusicMode(enabled);
    LiveRoomData.instance.liveController?.mediaController.setMusicMode(enabled);
  }

  Future<void> _fetchMusicList(
      GetMusicRoomListEvent event, Emitter<MusicRoomStates> emit) async {
    final List<MusicObjectParam> temp =
        List<MusicObjectParam>.from(state.musicesInRoom);
    final hive = HiveManager();

    var repeatMusicValue =
        await hive.getData(KeysManager.MUSIC_BOX, 'repeat_music_key');
    if (repeatMusicValue != null) {
      emit(state.copyWith(repeatMusic: repeatMusicValue));
    }

    var data =
        await hive.getData(KeysManager.MUSIC_BOX, KeysManager.CACHE_MUSIC_KEY);

    List<dynamic> mapCachedMusic = [];
    if (data != null) {
      mapCachedMusic = jsonDecode(data);
    }
    if (mapCachedMusic.isNotEmpty) {
      for (int i = 0; i < mapCachedMusic.length; i++) {
        final uri = mapCachedMusic[i]['uri'] ?? '';
        if (!_isValidAudio(uri)) continue;

        MusicObjectParam musicObjectParam = MusicObjectParam(
          id: mapCachedMusic[i]['id'] ?? 0,
          artist: mapCachedMusic[i]['artist'] ?? '',
          uri: uri,
          name: mapCachedMusic[i]['name'],
          duration: mapCachedMusic[i]['duration'],
        );
        if (!state.musicesInRoom.contains(musicObjectParam)) {
          temp.add(musicObjectParam);
        }
      }
      emit(state.copyWith(musicesInRoom: temp));
    }

    var lastMusicIndex = await hive.getData(
        KeysManager.MUSIC_BOX, KeysManager.LAAT_MUSIC_INDEX_KEY);
    if (lastMusicIndex != null && temp.isNotEmpty) {
      int index = lastMusicIndex;
      emit(state.copyWith(nowPlaying: index));
    }
    if (event.callback != null) event.callback!();
  }

  Future<void> _destroyMusic(
      DestroyMusicRoomListEvent event, Emitter<MusicRoomStates> emit) async {
    // Tell every other user to stop too, then give up DJ control.
    _broadcast(MusicAction.kill);
    _releaseDj();
    await _safeAudioOp(() => state.audioPlayer.stop());
    if (_isDisposed || isClosed) return;
    emit(state.copyWith(
      isPlayingSongFloatAnimation: false,
      isPlayingSongInnerDialogUi: false,
      isSongPlaying: false,
      totalDuration: Duration.zero,
      currentPosition: Duration.zero,
    ));
    stopUpdatingPosition();
  }

  Future<void> _repeat(
      RepeatMusicRoomEvent event, Emitter<MusicRoomStates> emit) async {
    final hive = HiveManager();
    final newRepeatValue = !state.repeatMusic;
    await hive.saveData(
      KeysManager.MUSIC_BOX,
      'repeat_music_key',
      newRepeatValue,
    );
    emit(state.copyWith(repeatMusic: newRepeatValue));
  }

  Future<void> _setIndexMusic(
      SetIndexSongPlayingRoomEvent event, Emitter<MusicRoomStates> emit) async {
    final hive = HiveManager();
    await hive.saveData(
      KeysManager.MUSIC_BOX,
      KeysManager.LAAT_MUSIC_INDEX_KEY,
      event.index,
    );
    emit(state.copyWith(nowPlaying: event.index));
  }

  Future<void> _deleteMusic(
      DeleteMusicRoomFromCacheEvent event, Emitter<MusicRoomStates> emit) async {
    add(const DestroyMusicRoomListEvent());
    List<MusicObjectParam> result =
        List<MusicObjectParam>.from(state.musicesInRoom);
    final hive = HiveManager();

    result = result..removeAt(event.index);
    emit(state.copyWith(
      nowPlaying: 0,
      musicesInRoom: result,
    ));
    hive.saveData(
      KeysManager.MUSIC_BOX,
      KeysManager.CACHE_MUSIC_KEY,
      jsonEncode(result),
    );
  }

  Future<void> _playMusic(
      PlayMusicRoomEvent event, Emitter<MusicRoomStates> emit) async {
    final hive = HiveManager();
    await hive.saveData(
      KeysManager.MUSIC_BOX,
      KeysManager.LAAT_MUSIC_INDEX_KEY,
      event.index,
    );

    if (state.musicesInRoom.isEmpty || event.index >= state.musicesInRoom.length) return;

    final selected = state.musicesInRoom[event.index];
    if (!_isValidAudio(selected.uri)) {
      debugPrint("Skipped: Not a valid audio file → ${selected.uri}");
      return;
    }

    if (!state.isSongPlaying) {
      emit(state.copyWith(nowPlaying: event.index));
      add(const LoadMusicRoomEvent());
    } else if (state.isSongPlaying && state.nowPlaying == event.index) {
      add(const DestroyMusicRoomListEvent());
      emit(state.copyWith(nowPlaying: 0));
    } else if (state.isSongPlaying && state.nowPlaying != event.index) {
      emit(state.copyWith(nowPlaying: event.index));
      add(const LoadMusicRoomEvent());
    }
  }

  Future<void> _playRandomMusic(
      PlayRandomMusicRoomEvent event, Emitter<MusicRoomStates> emit) async {
    if (state.musicesInRoom.isEmpty) return;

    try {
      await state.audioPlayer.pause();
    } catch (_) {}
    final randomIndex = Random().nextInt(state.musicesInRoom.length);

    await _playSongAtIndex(randomIndex, emit);
    _claimDjAndBroadcastPlay();
    await Future.delayed(const Duration(milliseconds: 500));

    await _fetchDurationSafe(emit);
    startUpdatingPosition();
  }

  Future<void> _addMusic(
      AddMusicRoomToCacheEvent event, Emitter<MusicRoomStates> emit) async {
    final List<MusicObjectParam> result =
        List<MusicObjectParam>.from(state.musicesInRoom);
    final hive = HiveManager();

    if (!_isValidAudio(event.model.data)) {
      debugPrint("Skipped: Not a valid audio file → ${event.model.data}");
      return;
    }

    final duration = event.model.duration;
    if (duration == null) {
      debugPrint("Skipped: Duration is null for → ${event.model.title}");
      return;
    }

    if (!state.musicesInRoom.any((model) => model.id == event.model.id)) {
      result.add(
        MusicObjectParam(
          artist: event.model.artist ?? '',
          id: event.model.id,
          duration: duration,
          name: event.model.title,
          uri: event.model.data,
        ),
      );
      emit(state.copyWith(musicesInRoom: result));
      hive.saveData(
        KeysManager.MUSIC_BOX,
        KeysManager.CACHE_MUSIC_KEY,
        jsonEncode(result),
      );
    }
  }

  Future<void> _controllPlayingMusic(
      ControlPlayingMusicRoomEvent event, Emitter<MusicRoomStates> emit) async {
    if (state.isPlayingSongInnerDialogUi) {
      try {
        await state.audioPlayer.pause();
      } catch (_) {}
      stopUpdatingPosition();
      emit(state.copyWith(
        isPlayingSongInnerDialogUi: false,
        isSongPlaying: false,
      ));
      _broadcast(MusicAction.pause);
    } else {
      try {
        await state.audioPlayer.resume();
      } catch (_) {}
      startUpdatingPosition();
      emit(state.copyWith(
        isPlayingSongInnerDialogUi: true,
        isPlayingSongFloatAnimation: true,
        isSongPlaying: true,
      ));
      _broadcast(MusicAction.resume);
    }
  }

  Future<void> _loadMusic(
      LoadMusicRoomEvent event, Emitter<MusicRoomStates> emit) async {
    if (state.musicesInRoom.isEmpty) return;

    await _playSongAtIndex(state.nowPlaying, emit);
    _claimDjAndBroadcastPlay();
    await Future.delayed(const Duration(milliseconds: 500));

    await _fetchDurationSafe(emit);
    startUpdatingPosition();
  }

  Future<void> _nextMusic(
      NextAndPreviousMusicRoomEvent event, Emitter<MusicRoomStates> emit) async {
    if (state.musicesInRoom.isEmpty) return;

    int newIndex = state.nowPlaying;

    if (event.fromEndState) {
      if (state.repeatMusic) {
        await _playSongAtIndex(state.nowPlaying, emit);
        _claimDjAndBroadcastPlay();
        await Future.delayed(const Duration(milliseconds: 200));
        await _fetchDurationSafe(emit);
        startUpdatingPosition();
        return;
      }
    }

    if (event.isNext) {
      newIndex = (state.nowPlaying + 1) % state.musicesInRoom.length;
    } else {
      newIndex = (state.nowPlaying - 1 >= 0)
          ? state.nowPlaying - 1
          : state.musicesInRoom.length - 1;
    }

    await _playSongAtIndex(newIndex, emit);
    _claimDjAndBroadcastPlay();
    await Future.delayed(const Duration(milliseconds: 200));

    await _fetchDurationSafe(emit);
    startUpdatingPosition();
  }

  Future<void> _setVolume(
      SetVolumeRoomEvent event, Emitter<MusicRoomStates> emit) async {
    emit(state.copyWith(volume: event.volume));
    await _safeAudioOp(
        () => state.audioPlayer.setVolume(_volumeFor(event.volume)));
    // Volume is synced globally — the DJ's volume applies to everyone.
    if (state.isSongPlaying) _broadcast(MusicAction.volume);
  }

  Future<void> _seekToPosition(
      SeekToPositionRoomEvent event, Emitter<MusicRoomStates> emit) async {
    await _safeAudioOp(() => state.audioPlayer.seek(event.newPosition));
    if (_isDisposed || isClosed) return;
    emit(state.copyWith(currentPosition: event.newPosition));
    _broadcast(MusicAction.seekTo);
  }

  Future<void> _updatePosition(
      MusicRoomUpdatePositionEvent event, Emitter<MusicRoomStates> emit) async {
    emit(state.copyWith(currentPosition: event.newPosition));
  }

  Future<void> _exitRoom(
      ExitRoomMusicRoomEvent event, Emitter<MusicRoomStates> emit) async {
    // If I'm the DJ and music is playing, tell everyone to stop before leaving.
    if (state.isSongPlaying &&
        RoomData.instance.musicControllerUserId == _myId) {
      _broadcast(MusicAction.kill);
    }
    _releaseDj();
    _isReceiverMode = false;
    _suppressBroadcast = false;

    try {
      await state.audioPlayer.stop();
      await state.audioPlayer.dispose();
    } catch (e) {
      // AudioPlayer may already be disposed
    }
    stopUpdatingPosition();

    emit(state.copyWith(
      isPlayingSongFloatAnimation: false,
      isPlayingSongInnerDialogUi: false,
      isSongPlaying: false,
      songUrl: '',
      currentPosition: Duration.zero,
      audioPlayer: AudioPlayer(),
    ));
    _currentUri = '';
    _bindMusicModeToPlayback(state.audioPlayer);
  }

  Future<void> _setPlayMusicForReceiver(
      SetPlayMusicForReceiverRoomEvent event,
      Emitter<MusicRoomStates> emit) async {
    emit(state.copyWith(isSongPlaying: event.isPlayingSong));
  }

  // ---------------------- Shared (server) music ----------------------

  /// Adds an uploaded song to the playlist and starts playing it. Playing it
  /// claims DJ control and broadcasts the song URL to everyone (via
  /// [_playSongAtIndex]). Ignored if another user already controls the music.
  Future<void> _addServerMusic(
      AddServerMusicRoomEvent event, Emitter<MusicRoomStates> emit) async {
    final activeDj = RoomData.instance.musicControllerUserId;
    if (activeDj != null && activeDj != _myId) return;

    // Prefer the full visible server list as the queue so next/previous can
    // reach every song, not only the ones already played this session.
    final list = (event.playlist != null && event.playlist!.isNotEmpty)
        ? List<MusicObjectParam>.from(event.playlist!)
        : List<MusicObjectParam>.from(state.musicesInRoom);
    int index = list.indexWhere((m) => m.uri == event.song.uri);
    if (index < 0) {
      list.add(event.song);
      index = list.length - 1;
    }
    emit(state.copyWith(musicesInRoom: list, nowPlaying: index));

    await _playSongAtIndex(index, emit);
    _claimDjAndBroadcastPlay();
    await Future.delayed(const Duration(milliseconds: 300));
    await _fetchDurationSafe(emit);
    startUpdatingPosition();
  }

  /// Applies a remote DJ's action to the local player (receiver side).
  /// Never re-broadcasts (guarded by [_suppressBroadcast]) and never
  /// auto-advances (guarded by [_isReceiverMode]).
  Future<void> _applyRemoteMusic(
      ApplyRemoteMusicEvent event, Emitter<MusicRoomStates> emit) async {
    _suppressBroadcast = true;
    _isReceiverMode = true;
    if (event.controllerId.isNotEmpty) {
      RoomData.instance.musicControllerUserId = event.controllerId;
    }

    try {
      switch (event.action) {
        case MusicAction.play:
          await _receiverPlay(event, emit);
          break;

        case MusicAction.resume:
          if (state.songUrl == null || state.songUrl!.isEmpty) {
            // Nothing loaded yet — treat as a fresh play.
            await _receiverPlay(event, emit);
          } else {
            await _safeAudioOp(() => state.audioPlayer.resume());
            startUpdatingPosition();
            emit(state.copyWith(
              isSongPlaying: true,
              isPlayingSongInnerDialogUi: true,
              isPlayingSongFloatAnimation: true,
            ));
          }
          break;

        case MusicAction.pause:
          await _safeAudioOp(() => state.audioPlayer.pause());
          stopUpdatingPosition();
          emit(state.copyWith(
            isSongPlaying: false,
            isPlayingSongInnerDialogUi: false,
          ));
          break;

        case MusicAction.volume:
          emit(state.copyWith(volume: event.volume));
          await _safeAudioOp(
              () => state.audioPlayer.setVolume(_volumeFor(event.volume)));
          break;

        case MusicAction.seekTo:
          final pos = Duration(milliseconds: event.positionMs);
          await _safeAudioOp(() => state.audioPlayer.seek(pos));
          emit(state.copyWith(currentPosition: pos));
          break;

        case MusicAction.kill:
        case MusicAction.playerExit:
          await _safeAudioOp(() => state.audioPlayer.stop());
          stopUpdatingPosition();
          _isReceiverMode = false;
          RoomData.instance.musicControllerUserId = null;
          emit(state.copyWith(
            isSongPlaying: false,
            isPlayingSongFloatAnimation: false,
            isPlayingSongInnerDialogUi: false,
            currentPosition: Duration.zero,
            totalDuration: Duration.zero,
          ));
          break;

        case MusicAction.repeat:
          // Repeat mode is driven entirely by the DJ; receivers no-op.
          break;
      }
    } finally {
      _suppressBroadcast = false;
    }
  }

  /// Receiver-side: load + play the DJ's song URL, synced to their position.
  Future<void> _receiverPlay(
      ApplyRemoteMusicEvent event, Emitter<MusicRoomStates> emit) async {
    if (event.songUrl.isEmpty) return;

    final song = MusicObjectParam(
      uri: event.songUrl,
      name: event.songName.isNotEmpty
          ? event.songName
          : _nameFromUrl(event.songUrl),
      artist: '',
      id: event.songUrl.hashCode,
      duration: 0,
    );

    await _safeAudioOp(() => state.audioPlayer.stop());
    _currentUri = event.songUrl;
    if (_viaMic(event.songUrl)) {
      emit(state.copyWith(
        musicesInRoom: [song],
        nowPlaying: 0,
        songUrl: event.songUrl,
        volume: event.volume,
        isSongPlaying: true,
        isPlayingSongFloatAnimation: true,
        isPlayingSongInnerDialogUi: true,
      ));
      return;
    }
    await _safeAudioOp(() => state.audioPlayer.setSource(UrlSource(event.songUrl)));
    // Volume before resume, so a muted room never blips out loud.
    await _safeAudioOp(
        () => state.audioPlayer.setVolume(_volumeFor(event.volume)));
    await _safeAudioOp(() => state.audioPlayer.resume());
    if (event.positionMs > 0) {
      await _safeAudioOp(() =>
          state.audioPlayer.seek(Duration(milliseconds: event.positionMs)));
    }

    emit(state.copyWith(
      musicesInRoom: [song],
      nowPlaying: 0,
      songUrl: event.songUrl,
      volume: event.volume,
      currentPosition: Duration(milliseconds: event.positionMs),
      isSongPlaying: true,
      isPlayingSongFloatAnimation: true,
      isPlayingSongInnerDialogUi: true,
    ));

    await _fetchDurationSafe(emit);
    startUpdatingPosition();
  }

  // ---------------------- Timer ----------------------

  void startUpdatingPosition() {
    _updateTimer?.cancel();
    bool triggered = true;

    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_isDisposed || isClosed) {
        timer.cancel();
        return;
      }

      try {
        final currentPosition =
            await _safeAudioRead(state.audioPlayer.getCurrentPosition);

        // Disposal can land during the await above; stop before touching the
        // player's state or emitting.
        if (_isDisposed || isClosed) {
          timer.cancel();
          return;
        }

        if (state.audioPlayer.state == PlayerState.completed) {
          // Receivers never auto-advance — only the DJ drives next/prev and
          // broadcasts the next track. This avoids every listener racing to
          // pick (and broadcast) the next song.
          if (_isReceiverMode) {
            // Track finished locally; wait for the DJ's next `play`.
          } else if (!state.repeatMusic && triggered) {
            triggered = false;
            if (!isClosed) {
              add(const NextAndPreviousMusicRoomEvent(
                  isNext: true, fromEndState: true));
            }
          } else if (state.repeatMusic) {
            if (!isClosed) {
              add(PlayMusicRoomEvent(index: state.nowPlaying));
            }
          }
        }

        if (!isClosed) {
          add(MusicRoomUpdatePositionEvent(
              currentPosition ?? Duration.zero));
        }
      } catch (e) {
        timer.cancel();
      }
    });
  }

  void stopUpdatingPosition() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  @override
  Future<void> close() async {
    // Cancel the position timer FIRST so no in-flight tick fires a player op
    // after we begin tearing down, THEN flip the disposed flag (so any op that
    // already passed its guard bails on its next re-check), THEN dispose.
    _updateTimer?.cancel();
    _updateTimer = null;
    _isDisposed = true;
    _isReceiverMode = false;
    _suppressBroadcast = false;
    _releaseDj();
    try {
      await state.audioPlayer.stop();
      await state.audioPlayer.dispose();
    } catch (e) {
      // AudioPlayer may already be disposed
    }
    return super.close();
  }
}
