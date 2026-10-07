import 'dart:async';
import 'package:general/src/features/room/data/model/extra_profile_data_model.dart';
import 'package:general/src/features/room/domain/use_case/extra_profile_data_uc.dart';
import 'package:general/src/core/index.dart';

part 'extra_data_profile_events.dart';
part 'extra_data_profile_states.dart';

class FetchExtraDataBloc
    extends Bloc<ExtraProfileDataEvent, FetchExtraDataStates> {
  final ExtraProfileDataUc _extraProfileDataUc;

  // This bloc is a DI singleton shared across every profile bottom sheet
  // opened during the app's lifetime (registerLazySingleton), while the
  // default bloc event transformer runs each dispatched event concurrently.
  // Tapping seat A then quickly seat B fires two overlapping fetches on the
  // SAME instance; whichever network call lands last used to win regardless
  // of which one the user actually opened. Track the most recently
  // REQUESTED userId and drop a completed fetch whose result is no longer
  // the latest request, so a slow stale response can never overwrite the
  // currently-open profile's data.
  String? _latestRequestedUserId;

  FetchExtraDataBloc(
    this._extraProfileDataUc,
  ) : super(const FetchExtraDataStates()) {
    on<FetchExtraDataProfile>(_etchExtraDataProfile);
  }

  Future<void> _etchExtraDataProfile(
      FetchExtraDataProfile event, Emitter<FetchExtraDataStates> emit) async {
    _latestRequestedUserId = event.userId;
    emit(state.copyWith(requestState: RequestState.loading));
    try {
      final result = await _extraProfileDataUc.call(event.userId);
      if (_latestRequestedUserId != event.userId) return;
      result.fold(
        (left) => emit(state.copyWith(
            requestState: handleErrorResponse(left),
            extraDataMessage: NetworkExceptions.getErrorMessage(left))),
        (right) {
          emit(state.copyWith(
              extraProfileData: right.data,
              requestState:
                  handleLoadedResponse<ExtraProfileDataModel>(right.data)));
        },
      );
    } catch (e) {
      if (_latestRequestedUserId != event.userId) return;
      emit(state.copyWith(
        requestState: RequestState.error,
        extraDataMessage: e.toString(),
      ));
    }
  }
}
