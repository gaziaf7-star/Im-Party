import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/entities/free_games_images_entity.dart';
import 'package:general/src/features/room/domain/use_case/get_free_games_images_uc.dart';

part 'get_free_games_images_event.dart';

part 'get_free_games_images_state.dart';

class GetFreeGamesImagesBloc
    extends Bloc<GetFreeGamesImagesEvent, GetFreeGamesImagesState> {
  final GetFreeGamesImagesUC useCase;

  GetFreeGamesImagesBloc(this.useCase)
      : super(const GetFreeGamesImagesState()) {
    on<GetFreeGamesImagesEvent>((event, emit) async {
      final result = await useCase();
      result.fold(
        (l) {
          emit(state.copyWith(
              message: NetworkExceptions.getErrorMessage(l),
              requestState: RequestState.error));
        },
        (r) {
          emit(state.copyWith(data: r.data, requestState: RequestState.loaded));
        },
      );
    });
  }
}
