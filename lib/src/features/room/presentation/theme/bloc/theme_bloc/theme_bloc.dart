import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';
part 'theme_events.dart';
part 'theme_states.dart';

class ThemeBloc extends Bloc<ThemeEvents, ThemeStates> {
  final BackGroundUC _backGroundUseCase;

  ThemeBloc( this._backGroundUseCase,) : super(const ThemeStates()) {
    on<GetThemesEvent>(_fetchThemes);
    on<SelectThemeEvent>(_onselectTheme);

}

Future<void> _fetchThemes(
      GetThemesEvent event,
      Emitter<ThemeStates> emit,
      ) async {
      emit(state.copyWith(requestState: RequestState.loading));

      final result = await _backGroundUseCase.call();

      result.fold((failure) {
        emit(state.copyWith(
          requestState: handleErrorResponse(failure),
            message: NetworkExceptions.getErrorMessage(failure)));
      }, (success) {
        emit(state.copyWith(backgroundList: success,requestState: handleLoadedResponse<List<BackgroundModel>>(success)));
      });
    }

  Future<void> _onselectTheme(
      SelectThemeEvent event,
      Emitter<ThemeStates> emit,
      ) async {
    emit(state.copyWith(imageId: event.imageId));
  }
}