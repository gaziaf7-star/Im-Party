import 'dart:async';

import 'package:general/src/features/reels/domain/use_case/make_like_use_case.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/bloc/get_reels/get_reels_bloc.dart';

import '../../../../../../core/index.dart';

part 'make_like_event.dart';
part 'make_like_state.dart';

/// Network owner for the reel like TOGGLE endpoint
/// (`POST /reals/{id}/like` — no liked flag, so each call flips server state).
///
/// Because the endpoint is a pure toggle, firing one request per tap desyncs
/// the UI on rapid taps (N requests racing). Instead we coalesce taps per reel
/// id over a short window and send a SINGLE toggle only when the net number of
/// taps is ODD (even net → server already in the right state → send nothing).
///
/// On a sent toggle's failure we undo the optimistic UI change via
/// `RevertLikeEvent` on [GetReelsBloc] and surface a localized toast.
class MakeLikeBloc extends Bloc<BaseMakeLikeEvent, MakeLikeState> {
  final MakeLikeUseCase makeLikeUseCase;

  /// Net tap count per reel id within the current debounce window.
  final Map<String, int> _pendingToggles = {};

  /// Active debounce timer per reel id.
  final Map<String, Timer> _debounceTimers = {};

  static const Duration _debounce = Duration(milliseconds: 400);

  MakeLikeBloc(this.makeLikeUseCase) : super(const MakeLikeState()) {
    on<MakeLikeEvent>(_onMakeLike);
    on<_FlushLikeEvent>(_onFlushLike);
  }

  void _onMakeLike(MakeLikeEvent event, Emitter<MakeLikeState> emit) {
    final reelId = event.reelId;
    _pendingToggles.update(reelId, (v) => v + 1, ifAbsent: () => 1);

    _debounceTimers[reelId]?.cancel();
    _debounceTimers[reelId] = Timer(_debounce, () {
      if (isClosed) return;
      add(_FlushLikeEvent(reelId));
    });

    emit(state.copyWith(requestState: RequestState.loading));
  }

  Future<void> _onFlushLike(
      _FlushLikeEvent event, Emitter<MakeLikeState> emit) async {
    final reelId = event.reelId;
    _debounceTimers.remove(reelId)?.cancel();
    final net = _pendingToggles.remove(reelId) ?? 0;

    // Even net toggles cancel out: the server is already in the correct state.
    if (net.isEven) {
      emit(state.copyWith(requestState: RequestState.loaded));
      return;
    }

    final result = await makeLikeUseCase(reelId);
    if (isClosed) return;

    result.fold(
      (failure) {
        di<GetReelsBloc>().add(RevertLikeEvent(int.tryParse(reelId) ?? -1));
        Methods.showToast(
          navKey.currentContext,
          message: StringManager.someThingWentWrong.tr(),
          isError: true,
        );
        emit(state.copyWith(
          requestState: RequestState.error,
          errorMessage: NetworkExceptions.getErrorMessage(failure),
        ));
      },
      (success) => emit(state.copyWith(
        requestState: RequestState.loaded,
        successMessage: success.message,
      )),
    );
  }

  @override
  Future<void> close() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    _pendingToggles.clear();
    return super.close();
  }
}
