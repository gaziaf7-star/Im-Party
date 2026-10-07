import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:general/reels_viewer/bloc/reels_viewer_event.dart';
import 'package:general/reels_viewer/bloc/reels_viewer_state.dart';

class ReelViewerBloc extends Bloc<ReelViewerEvent, ReelViewerState> {
  // Persists the last mute choice across bloc instances (in-memory only).
  static bool _isMute = false;

  ReelViewerBloc() : super(ReelViewerState(isMute: _isMute)) {
    on<PlayReelEvent>((event, emit) {
      // event.controller.play();
      emit(state.copyWith(isPlaying: true));
    });

    on<PauseReelEvent>((event, emit) {
      // event.controller.pause();
      emit(state.copyWith(isPlaying: false));
    });
    on<ChangeActiveReelEvent>((event, emit) {
      // Set the active index/type ONLY — do NOT force isPlaying=true here.
      // Forcing play on every active-reel change auto-resumed playback against
      // the user's intent (swipe-while-paused, returning to a paused tab).
      // Playback is owned by _recomputeDesiredPlayback (→ Play/PauseReelEvent),
      // and isPlaying persists across a swipe so a watching user keeps watching
      // and a paused user stays paused.
      emit(state.copyWith(
        activeReelIndex: event.index,
        reelsType: event.reelsType,
      ));
    });
    on<MuteToggleEvent>((event, emit) {
      _isMute = !state.isMute;
      emit(state.copyWith(isMute: _isMute));
    });
    // on<PauseAllReelEvent>((event, emit) {
    //   event.controller.pause();
    //   emit(state.copyWith(isPlaying: false));
    // });
  }
}

