part of 'upload_song_bloc.dart';

class UploadSongState extends Equatable {
  final RequestState requestState;
  final RequestState musicListRequestState;
  final RequestState myMusicListRequestState;
  final File? reelVideo;
  final String? songImage;
  final String? message;
  final String? backendName;
  final String? preSignedUrl;
  final String? descreption;
  final String? songName;
  final List<MusicUrlEntity> musicListData;
  final List<MusicUrlEntity> myMusicListData;
  final List<MusicUrlEntity> favoriteListData;

  const UploadSongState({
    this.requestState = RequestState.idle,
    this.musicListRequestState = RequestState.idle,
    this.myMusicListRequestState = RequestState.idle,
    this.message,
    this.backendName,
    this.preSignedUrl,
    this.descreption,
    this.songName,
    this.reelVideo,
    this.songImage,
    this.musicListData = const [],
    this.myMusicListData = const [],
    this.favoriteListData = const [],
  });

  UploadSongState copyWith({
    RequestState? requestState,
    RequestState? musicListRequestState,
    RequestState? myMusicListRequestState,
    String? message,
    String? backendName,
    String? preSignedUrl,
    String? descreption,
    String? songName,
    File? reelVideo,
    String? songImage,
    List<MusicUrlEntity>? musicListData,
    List<MusicUrlEntity>? myMusicListData,
    List<MusicUrlEntity>? favoriteListData,
  }) {
    return UploadSongState(
      requestState: requestState ?? this.requestState,
      musicListRequestState:
          musicListRequestState ?? this.musicListRequestState,
      myMusicListRequestState:
          myMusicListRequestState ?? this.myMusicListRequestState,
      message: message ?? this.message,
      backendName: backendName ?? this.backendName,
      preSignedUrl: preSignedUrl ?? this.preSignedUrl,
      descreption: descreption ?? this.descreption,
      songName: songName ?? this.songName,
      reelVideo: reelVideo ?? this.reelVideo,
      songImage: songImage ?? this.songImage,
      musicListData: musicListData ?? this.musicListData,
      myMusicListData: myMusicListData ?? this.myMusicListData,
      favoriteListData: favoriteListData ?? this.favoriteListData,
    );
  }

  @override
  List<Object?> get props => [
        requestState,
        musicListRequestState,
        myMusicListRequestState,
        message ?? '',
        backendName ?? '',
        preSignedUrl ?? '',
        descreption ?? '',
        songName ?? '',
        reelVideo,
        musicListData,
        myMusicListData,
        favoriteListData,
        songImage
      ];
}
