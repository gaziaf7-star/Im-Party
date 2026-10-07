import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/use_case/delete_song.dart';

import '../upload_song/upload_song_bloc.dart';

part 'delete_song_event.dart';

part 'delete_song_state.dart';

class DeleteSongBloc extends Bloc<DeleteSongEvent, DeleteSongState> {
  final DeleteSongUC deleteSongUC;

  DeleteSongBloc(this.deleteSongUC) : super(const DeleteSongState()) {
    on<DeleteSongEvent>((event, emit) async {
      final result = await deleteSongUC(event.songId);

      result.fold((l) {
        emit(state.copyWith(
            message: NetworkExceptions.getErrorMessage(l),
            requestState: RequestState.loaded));
      }, (r) {
        di<UploadSongBloc>().add(const GetMyMusicEvent());
        emit(state.copyWith(
            message: r.message, requestState: RequestState.loaded));
      });
    });
  }
}
