import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/domain/profile_use_case/get_my_level_data_uc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_my_level/get_my_level_event.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_my_level/get_my_level_state.dart';

class GetMyLevelBloc extends Bloc<GetMyLevelEvent, GetMyLevelState> {
  final GetMyLevelDataUseCase getMyLevelDataUseCase;

  GetMyLevelBloc({required this.getMyLevelDataUseCase})
      : super(const GetMyLevelState()) {
    on<GetMyLevelData>(
      (event, emit) async {
        final result = await getMyLevelDataUseCase();
        result.fold(
          (failure) => emit(
            state.copyWith(
              myLevelMessage: NetworkExceptions.getErrorMessage(failure),
              myLevelState: RequestState.error,
            ),
          ),
          (success) {
            emit(
              state.copyWith(
                myLevel: success.data,
                myLevelState: RequestState.loaded,
              ),
            );
          },
        );
      },
    );
  }
}
