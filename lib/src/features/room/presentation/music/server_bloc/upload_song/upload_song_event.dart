part of 'upload_song_bloc.dart';

abstract class BaseUploadSongEvent extends Equatable {
  const BaseUploadSongEvent();

  @override
  List<Object?> get props => [];
}

class GetPreSignedUrlEvent extends BaseUploadSongEvent {
  final UploadSongParam param;
  final BuildContext context;

  const GetPreSignedUrlEvent(this.context, this.param);

  @override
  List<Object?> get props => [param];
}

class UploadFileToStorageEvent extends BaseUploadSongEvent {
  final BuildContext context;

  final UploadSongParam param;

  const UploadFileToStorageEvent(this.context, this.param);

  @override
  List<Object?> get props => [param, context];
}

class NotifyBackendEvent extends BaseUploadSongEvent {
  final BuildContext context;

  const NotifyBackendEvent(
    this.context,
  );

  @override
  List<Object?> get props => [context];
}

class GetMusicEvent extends BaseUploadSongEvent {
  // final BuildContext context;

  const GetMusicEvent(//   this.context,
      );

  @override
  List<Object?> get props => [];
}

class GetMyMusicEvent extends BaseUploadSongEvent {
  // final BuildContext context;

  const GetMyMusicEvent(//   this.context,
      );

  @override
  List<Object?> get props => [];
}

class PickSongEvent extends BaseUploadSongEvent {
  final BuildContext context;

  const PickSongEvent(
    this.context,
  );

  @override
  List<Object?> get props => [
        context,
      ];
}

/// Songs already chosen from the phone's own media library, so there is no file
/// browser to open — the picker has the path and the title already.
class UploadDeviceSongsEvent extends BaseUploadSongEvent {
  const UploadDeviceSongsEvent({
    required this.context,
    required this.songs,
  });

  final BuildContext context;

  /// `(path, title)` per song, in the order they should be added.
  final List<({String path, String title})> songs;

  @override
  List<Object?> get props => [songs.map((s) => s.path).toList()];
}

class FavoriteSongEvent extends BaseUploadSongEvent {
  final int id;

  const FavoriteSongEvent({
    required this.id,
  });

  @override
  List<Object?> get props => [
        id,
      ];
}
