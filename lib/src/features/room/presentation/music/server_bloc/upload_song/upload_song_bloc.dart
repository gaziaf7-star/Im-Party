import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/entities/music_url.dart';
import 'package:general/src/features/room/domain/use_case/get_music_uc.dart';
import 'package:general/src/features/room/domain/use_case/get_my_music_uc.dart';
import 'package:general/src/features/room/domain/use_case/upload_song_use_case.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

part 'upload_song_event.dart';

part 'upload_song_state.dart';

class UploadSongBloc extends Bloc<BaseUploadSongEvent, UploadSongState> {
  final GetPreSignedUrlSongUseCase getPreSignedUrlUseCase;
  final UploadFileSongToStorageUseCase uploadFileToStorageUseCase;
  final NotifyBackendSongUseCase notifyBackendUseCase;
  final GetMyMusicUc getMyMusicUc;
  final GetMusicUc getMusicUc;

  UploadSongBloc(this.getPreSignedUrlUseCase, this.uploadFileToStorageUseCase,
      this.notifyBackendUseCase, this.getMusicUc, this.getMyMusicUc)
      : super(const UploadSongState()) {
    on<GetPreSignedUrlEvent>((event, emit) async {
      emit(state.copyWith(requestState: RequestState.loading));

      final result = await getPreSignedUrlUseCase(event.param.song!);
      result.fold(
        (failure) => emit(
          state.copyWith(
            requestState: handleErrorResponse(failure),
            message: NetworkExceptions.getErrorMessage(failure),
          ),
        ),
        (success) {
          emit(
            state.copyWith(
              backendName: success['name'],
              preSignedUrl: success['upload_url'],
            ),
          );
          add(
            UploadFileToStorageEvent(
              event.context,
              UploadSongParam(
                  backendName: success['name'],
                  preSignedUrl: success['upload_url'],
                  song: event.param.song),
            ),
          );
        },
      );
    });
    on<UploadFileToStorageEvent>((event, emit) async {
      final result = await uploadFileToStorageUseCase(event.param);
      result.fold(
        (failure) => emit(
          state.copyWith(
            requestState: handleErrorResponse(failure),
            message: NetworkExceptions.getErrorMessage(failure),
          ),
        ),
        (success) {
          add(NotifyBackendEvent(
            event.context,
          ));
        },
      );
    });
    on<NotifyBackendEvent>((event, emit) async {
      final result = await notifyBackendUseCase(UploadSongParam(
          description: state.descreption,
          backendName: state.backendName,
          songImage: state.songImage,
          songName: state.songName));
      result.fold(
        (failure) => emit(
          state.copyWith(
            requestState: handleErrorResponse(failure),
            message: NetworkExceptions.getErrorMessage(failure),
          ),
        ),
        (success) {
          emit(
            state.copyWith(
              requestState: RequestState.loaded,
            ),
          );
          add(const GetMyMusicEvent());
        },
      );
    });
    on<GetMusicEvent>((event, emit) async {
      final result = await getMusicUc();
      result.fold(
        (failure) => emit(
          state.copyWith(
            musicListRequestState: handleErrorResponse(failure),
            message: NetworkExceptions.getErrorMessage(failure),
          ),
        ),
        (success) {
          emit(
            state.copyWith(
                musicListRequestState: RequestState.loaded,
                musicListData: success.data),
          );
        },
      );
    });
    on<GetMyMusicEvent>((event, emit) async {
      final result = await getMyMusicUc();
      result.fold(
        (failure) => emit(
          state.copyWith(
            myMusicListRequestState: handleErrorResponse(failure),
            message: NetworkExceptions.getErrorMessage(failure),
          ),
        ),
        (success) {
          final List<int> likedIds = List<int>.from(
            HiveManager().getData<List<dynamic>>(
                    KeysManager.MUSIC_BOX, KeysManager.LIKED_SONG_IDS_KEY,
                    defaultValue: []) ??
                [],
          );

          final List<MusicUrlEntity> updatedSongs = success.data!.map((song) {
            final bool isLiked = likedIds.contains(song.id);
            return song.copyWith(isLiked: isLiked);
          }).toList();

          final List<MusicUrlEntity> likedSongs =
              updatedSongs.where((song) => song.isLiked).toList();

          emit(
            state.copyWith(
                myMusicListRequestState: RequestState.loaded,
                myMusicListData: updatedSongs,
                favoriteListData: likedSongs),
          );
        },
      );
    });
    on<PickSongEvent>((event, emit) async {
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final PlatformFile pickedFile = result.files.first;
      final File videoFile = File(pickedFile.path!);
      final metadata = await MetadataRetriever.fromFile(videoFile);
      final Uint8List? albumArt = metadata.albumArt;
      String songImage = '';
      if (albumArt != null) {
        final tempDir = await getTemporaryDirectory();
        songImage = tempDir.path;
      }

      // Keep the real song title: the uploaded object gets a random storage
      // name, so the backend can only show what we send it here.
      String songName = (metadata.trackName ?? '').trim();
      if (songName.isEmpty) {
        songName = pickedFile.name;
        final dot = songName.lastIndexOf('.');
        if (dot > 0) songName = songName.substring(0, dot);
      }

      add(
        GetPreSignedUrlEvent(event.context, UploadSongParam(song: videoFile)),
      );

      emit(state.copyWith(
          reelVideo: videoFile, songImage: songImage, songName: songName));
    });
    // Adds a whole selection, SEQUENTIALLY. The presign -> PUT -> notify chain
    // keeps its progress on this one bloc's state, so running two at once would
    // have them overwrite each other's `backendName` and file — songs would be
    // registered under the wrong object. One at a time is also kinder to the
    // upload bandwidth of a phone on mobile data.
    on<UploadDeviceSongsEvent>((event, emit) async {
      var added = 0;
      final failed = <String>[];

      for (final song in event.songs) {
        final file = File(song.path);

        // The media store can list a track whose file has since been moved or
        // deleted; uploading a missing path fails deep inside the storage call
        // with an unhelpful error.
        if (!await file.exists()) {
          failed.add(song.title);
          continue;
        }

        // Guard against a known MediaStore quirk: on some devices the
        // `_data` column on_audio_query reads back for a track can resolve
        // to that track's cached album-art/thumbnail file instead of the
        // actual audio file (both are indexed under the same row). A
        // thumbnail is a tiny image (a handful to a few dozen KB); no real
        // audio track is. Catching it here means we never upload/register a
        // "song" that is actually a JPEG/PNG, however the wrong path
        // happened -- independent of pinning down the exact MediaStore
        // cause.
        const minPlausibleAudioBytes = 50 * 1024;
        final fileLength = await file.length();
        if (fileLength < minPlausibleAudioBytes) {
          Methods.printLog(
            '🎵 [UPLOAD_SONG_SUSPICIOUS_SIZE] title=${song.title} '
            'path=${song.path} sizeBytes=$fileLength '
            '-- skipped, looks like a thumbnail/album-art file, not audio',
          );
          failed.add(song.title);
          continue;
        }

        emit(state.copyWith(requestState: RequestState.loading));

        final ok = await _uploadOne(file, song.title);
        ok ? added++ : failed.add(song.title);
      }

      emit(state.copyWith(
        requestState: added > 0 ? RequestState.loaded : RequestState.error,
        message: _bulkMessage(added, failed),
      ));

      // Refresh both tabs so what was just added is actually visible.
      add(const GetMyMusicEvent());
      add(const GetMusicEvent());
    });

    on<FavoriteSongEvent>((event, emit) async {
      final List<MusicUrlEntity> songs = List.of(state.myMusicListData);

      final int index = songs.indexWhere((element) => element.id == event.id);
      if (index != -1) {
        final updatedSong =
            songs[index].copyWith(isLiked: !songs[index].isLiked);

        songs[index] = updatedSong;

        final List<int> likedIds = List<int>.from(
          HiveManager().getData<List<dynamic>>(
                  KeysManager.MUSIC_BOX, KeysManager.LIKED_SONG_IDS_KEY,
                  defaultValue: []) ??
              [],
        );

        if (updatedSong.isLiked) {
          if (!likedIds.contains(updatedSong.id)) {
            likedIds.add(updatedSong.id);
          }
        } else {
          likedIds.remove(updatedSong.id);
        }

        await HiveManager().saveData<List<int>>(
          KeysManager.MUSIC_BOX,
          KeysManager.LIKED_SONG_IDS_KEY,
          likedIds,
        );

        final List<MusicUrlEntity> likedSongs =
            songs.where((song) => song.isLiked).toList();
        emit(state.copyWith(
            myMusicListData: songs, favoriteListData: likedSongs));
      }
    });
  }

  /// One song, all three steps, awaited.
  ///
  /// Deliberately calls the use cases directly instead of dispatching the
  /// event chain: the chain is fire-and-forget, so a loop over it would start
  /// every upload at once and they would trample each other's state.
  ///
  /// Returns whether the song ended up registered.
  Future<bool> _uploadOne(File file, String title) async {
    try {
      final signed = await getPreSignedUrlUseCase(file);

      final param = signed.fold<UploadSongParam?>(
        (_) => null,
        (data) => UploadSongParam(
          song: file,
          backendName: data['name'],
          preSignedUrl: data['upload_url'],
          songName: title,
        ),
      );
      if (param == null) return false;

      final stored = await uploadFileToStorageUseCase(param);
      final storedOk = stored.fold((_) => false, (code) => code >= 200 && code < 300);
      if (!storedOk) return false;

      final notified = await notifyBackendUseCase(param);

      return notified.fold((_) => false, (_) => true);
    } catch (_) {
      // A single bad file must not abandon the rest of the selection.
      return false;
    }
  }

  /// Honest about partial success: "added 8" when two of ten failed would hide
  /// the failures, and naming every failure would be unreadable for a big batch.
  String _bulkMessage(int added, List<String> failed) {
    if (failed.isEmpty) {
      return '${StringManager.musicAdded.tr()} ($added)';
    }
    if (added == 0) {
      return StringManager.musicAddFailed.tr();
    }

    return '${StringManager.musicAdded.tr()} ($added) · '
        '${StringManager.musicAddPartial.tr()} (${failed.length})';
  }
}
