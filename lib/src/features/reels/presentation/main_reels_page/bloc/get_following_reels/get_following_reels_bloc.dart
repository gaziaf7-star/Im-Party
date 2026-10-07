import 'package:general/src/features/reels/domain/entities/reel_entity.dart';
import 'package:general/src/features/reels/domain/use_case/get_following_reels_use_case.dart';

import '../../../../../../core/index.dart';

part 'get_following_reels_event.dart';
part 'get_following_reels_state.dart';


class GetFollowingReelsBloc extends Bloc<BaseGetFollowingReelsEvent, GetFollowingReelsState> {
  final GetFollowingReelsUseCase useCase;

  GetFollowingReelsBloc(this.useCase)
      : super(const GetFollowingReelsState()) {
    on<GetFollowingReelsEvent>((event, emit) async {
      emit(state.copyWith(
          requestState: RequestState.loading)); // Emit loading state

      final result = await useCase('1'); // Call the use case

      result.fold(
            (left) => emit(state.copyWith(
          requestState: handleErrorResponse(left),
          errorMessage:
          NetworkExceptions.getErrorMessage(left), // Emit error state
        )),
            (right) => emit(state.copyWith(
          requestState:
          handleLoadedResponse<List<ReelsEntity>>(right.data),
          commentsList: right.data ?? [], // Emit success state with data
        )),
      );
    });
  }
}
