import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/use_case/open_game_uc.dart';
import 'open_game_event.dart';
import 'open_game_state.dart';

class OpenGameBloc extends Bloc<BaseOpenGameEvent, OpenGameState> {
  final OpenGameUseCase openGameUseCase;

  OpenGameBloc({required this.openGameUseCase}) : super(OpenGameInitial()) {
    on<OpenGameEvent>((event, emit) async {
      emit(OpenGameLoadingState());
      final result = await openGameUseCase.call(event.id);
      result.fold(
        (left) => emit(
            OpenGameErrorState(error: NetworkExceptions.getErrorMessage(left))),
        (right) => emit(OpenGameSuccessState(message: right)),
      );
    });
  }
}
