import 'package:general/src/core/index.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

abstract class MusicRoomEvent extends Equatable {
  const MusicRoomEvent();

  @override
  List<Object?> get props => [];
}

class GetMusicRoomListEvent extends MusicRoomEvent {
  final void Function()? callback;

  const GetMusicRoomListEvent({this.callback});
}

class DestroyMusicRoomListEvent extends MusicRoomEvent {
  const DestroyMusicRoomListEvent();
}

class RepeatMusicRoomEvent extends MusicRoomEvent {
  const RepeatMusicRoomEvent();
}

class SetIndexSongPlayingRoomEvent extends MusicRoomEvent {
  final int index;

  const SetIndexSongPlayingRoomEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class DeleteMusicRoomFromCacheEvent extends MusicRoomEvent {
  final int index;

  const DeleteMusicRoomFromCacheEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class AddMusicRoomToCacheEvent extends MusicRoomEvent {
  final SongModel model;

  const AddMusicRoomToCacheEvent({required this.model});

  @override
  List<Object?> get props => [model];
}

class PlayMusicRoomEvent extends MusicRoomEvent {
  final int index;

  const PlayMusicRoomEvent({required this.index});

  @override
  List<Object?> get props => [index];
}

class PlayRandomMusicRoomEvent extends MusicRoomEvent {
  const PlayRandomMusicRoomEvent();
}

class ControlPlayingMusicRoomEvent extends MusicRoomEvent {
  const ControlPlayingMusicRoomEvent();
}

class LoadMusicRoomEvent extends MusicRoomEvent {
  const LoadMusicRoomEvent();
}

class SetVolumeRoomEvent extends MusicRoomEvent {
  final double volume;

  const SetVolumeRoomEvent(this.volume);

  @override
  List<Object?> get props => [volume];
}

class MusicRoomUpdatePositionEvent extends MusicRoomEvent {
  final Duration newPosition;

  const MusicRoomUpdatePositionEvent(this.newPosition);

  @override
  List<Object?> get props => [newPosition];
}

class SeekToPositionRoomEvent extends MusicRoomEvent {
  final Duration newPosition;

  const SeekToPositionRoomEvent(this.newPosition);

  @override
  List<Object?> get props => [newPosition];
}

class NextAndPreviousMusicRoomEvent extends MusicRoomEvent {
  final bool isNext;
  final bool fromEndState;

  const NextAndPreviousMusicRoomEvent({
    required this.isNext,
    this.fromEndState = false,
  });

  @override
  List<Object?> get props => [isNext, fromEndState];
}

class ExitRoomMusicRoomEvent extends MusicRoomEvent {
  const ExitRoomMusicRoomEvent();
}

class SetPlayMusicForReceiverRoomEvent extends MusicRoomEvent {
  final bool isPlayingSong;

  const SetPlayMusicForReceiverRoomEvent(this.isPlayingSong);

  @override
  List<Object?> get props => [isPlayingSong];
}

/// Adds an uploaded (server-backed) song to the in-room playlist so it can be
/// played by URL and shared with every user. Used by the upload/server list UI.
class AddServerMusicRoomEvent extends MusicRoomEvent {
  final MusicObjectParam song;

  /// The full visible server list the song was tapped from. When provided it
  /// becomes the in-room queue, so next/previous can move through the whole
  /// list instead of only the songs already played this session.
  final List<MusicObjectParam>? playlist;

  const AddServerMusicRoomEvent({required this.song, this.playlist});

  @override
  List<Object?> get props => [song, playlist];
}

/// Applies a remote DJ's music action to the local player (receiver side).
/// Dispatched by [MediaMessageHandler] when a `musicSync` /
/// `playMusicForOneUser` message arrives. Never re-broadcasts.
class ApplyRemoteMusicEvent extends MusicRoomEvent {
  final MusicAction action;
  final String songUrl;
  final double volume;
  final int positionMs;
  final String controllerId;

  /// Display name of the DJ's current song, so listeners show the real title
  /// instead of the storage filename derived from the URL.
  final String songName;

  const ApplyRemoteMusicEvent({
    required this.action,
    required this.songUrl,
    required this.volume,
    required this.positionMs,
    required this.controllerId,
    this.songName = '',
  });

  @override
  List<Object?> get props =>
      [action, songUrl, volume, positionMs, controllerId, songName];
}
