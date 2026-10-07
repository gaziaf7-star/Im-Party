import 'package:audioplayers/audioplayers.dart';
import 'package:general/src/core/index.dart';

class MusicRoomStates extends Equatable {
  final bool isSongPlaying;
  final bool isPlayingSongFloatAnimation;
  final bool isPlayingSongInnerDialogUi;
  final List<MusicObjectParam> musicesInRoom;
  final bool repeatMusic;
  final bool isNext;
  final int nowPlaying;
  final AudioPlayer audioPlayer;
  final double volume;
  final Duration currentPosition;
  final Duration totalDuration;
  final String? songUrl;

  const MusicRoomStates({
    this.musicesInRoom = const [],
    this.isSongPlaying = false,
    this.isPlayingSongFloatAnimation = false,
    this.isPlayingSongInnerDialogUi = false,
    this.isNext = false,
    this.repeatMusic = false,
    this.nowPlaying = 0,
    this.volume = 50.0,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.songUrl = '',
    required this.audioPlayer,
  });

  MusicRoomStates copyWith({
    bool? isSongPlaying,
    bool? isNext,
    bool? isPlayingSongFloatAnimation,
    bool? isPlayingSongInnerDialogUi,
    List<MusicObjectParam>? musicesInRoom,
    bool? repeatMusic,
    int? nowPlaying,
    double? volume,
    Duration? currentPosition,
    Duration? totalDuration,
    String? songUrl,
    AudioPlayer? audioPlayer,
  }) {
    return MusicRoomStates(
      isNext: isNext ?? this.isNext,
      isSongPlaying: isSongPlaying ?? this.isSongPlaying,
      isPlayingSongFloatAnimation:
          isPlayingSongFloatAnimation ?? this.isPlayingSongFloatAnimation,
      isPlayingSongInnerDialogUi:
          isPlayingSongInnerDialogUi ?? this.isPlayingSongInnerDialogUi,
      musicesInRoom: musicesInRoom ?? this.musicesInRoom,
      repeatMusic: repeatMusic ?? this.repeatMusic,
      nowPlaying: nowPlaying ?? this.nowPlaying,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      volume: volume ?? this.volume,
      songUrl: songUrl ?? this.songUrl,
      audioPlayer: audioPlayer ?? this.audioPlayer,
    );
  }

  @override
  List<Object?> get props => [
        isSongPlaying,
        isPlayingSongFloatAnimation,
        musicesInRoom,
        repeatMusic,
        nowPlaying,
        isNext,
        audioPlayer,
        totalDuration,
        currentPosition,
        volume,
        isPlayingSongInnerDialogUi,
        songUrl,
      ];
}
