import 'package:general/src/core/index.dart';

part 'language_event.dart';
part 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final HiveManager settingsBox;

  LanguageBloc(this.settingsBox) : super(const LanguageInitial()) {
    on<LanguageEvent>((event, emit) async {
      if (event is ChangeLanguageEvent) {
        emit(const LanguageLoading());
        try {
          await HiveManager().saveData(
            KeysManager.USER_BOX,
            KeysManager.LANG_CODE_KEY,
            event.languageCode,
          );
          emit(LanguageChanged(event.languageCode));
        } catch (error) {
          emit(LanguageError('$error'));
        }
      }
    });

    String cachedLanguage = settingsBox.getData<String>(
            KeysManager.USER_BOX, KeysManager.LANG_CODE_KEY) ??
        "en";
    add(ChangeLanguageEvent(cachedLanguage));
  }
}
