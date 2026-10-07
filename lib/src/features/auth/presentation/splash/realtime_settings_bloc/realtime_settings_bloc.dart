import 'package:general/src/core/index.dart';
import '../../../domain/use_cases/realtime_settings_uc.dart';
part 'realtime_settings_event.dart';
part 'realtime_settings_state.dart';

/// Loads `/config/settings` so the data source can apply the Centrifugo realtime
/// flags (`RealtimeConfig.applyFromSettings`). No legacy realtime credentials are stored
/// or broadcast — the realtime transport is Centrifugo.
class RealtimeSettingsBloc
    extends Bloc<RealtimeSettingsEvent, RealtimeSettingsStates> {
  final RealtimeSettingsUc _realtimeSettingsUc;

  RealtimeSettingsBloc(this._realtimeSettingsUc)
      : super(const RealtimeSettingsStates()) {
    on<FetchRealtimeSettings>(_fetchRealtimeSettings);
  }

  void _fetchRealtimeSettings(
    FetchRealtimeSettings event,
    Emitter<RealtimeSettingsStates> emit,
  ) async {
    emit(state.copyWith(reqState: RequestState.loading));
    final result = await _realtimeSettingsUc();

    result.fold(
      (left) {
        emit(
          state.copyWith(
            reqState: RequestState.error,
            message: NetworkExceptions.getErrorMessage(left),
          ),
        );
      },
      (right) {
        emit(
          state.copyWith(
            reqState: RequestState.loaded,
            message: right.message,
          ),
        );
      },
    );
  }
}
