import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/data/model/user_intro_model.dart';
import 'package:general/src/features/profile/domain/profile_use_case/get_user_intro_use_case.dart';
import 'get_user_intro_event.dart';
import 'get_user_intro_state.dart';

class GetUserIntroBloc extends Bloc<GetUserIntroEvent, GetUserIntroState> {
  GetUserIntroUseCase getUserIntroUseCase;
  GetUserIntroBloc({required this.getUserIntroUseCase})
      : super(const GetUserIntroState()) {
    on<GetUserIntro>((event, emit) async {
      if (!event.force &&
          (state.requestState == RequestState.loaded ||
              state.requestState == RequestState.empty) &&
          state.loadedUserId == event.id) {
        return;
      }
      emit(state.copyWith(requestState: RequestState.loading));
      final result = await getUserIntroUseCase.call(event.id);

      result.fold(
          (l) => emit(state.copyWith(
                requestState: RequestState.error,
                errorMessage: l,
              )),
          (r) => emit(state.copyWith(
                userIntroModel: r.data ?? [],
                loadedUserId: event.id,
                requestState:
                    handleLoadedResponse<List<UserIntroModel>>(r.data),
              )));
    });
  }
}
