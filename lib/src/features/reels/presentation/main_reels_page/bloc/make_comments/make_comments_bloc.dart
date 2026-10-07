import 'package:general/src/features/reels/domain/use_case/make_comments_use_case.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/bloc/get_comments/get_comments_bloc.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/bloc/get_reels/get_reels_bloc.dart';

import '../../../../../../core/index.dart';

part 'make_comments_event.dart';

part 'make_comments_state.dart';

class MakeCommentsBloc extends Bloc<BaseMakeCommentsEvent, MakeCommentsState> {
  final MakeCommentsUseCase useCase;

  MakeCommentsBloc(this.useCase) : super(const MakeCommentsState()) {
    on<MakeCommentsEvent>((event, emit) async {
      emit(state.copyWith(
          requestState: RequestState.loading)); // Emit loading state

      final result = await useCase(event.param); // Call the use case

      result.fold(
        (left) => emit(state.copyWith(
          requestState: handleErrorResponse(left),
          errorMessage:
              NetworkExceptions.getErrorMessage(left), // Emit error state
        )),
        (right) {
          emit(state.copyWith(requestState: RequestState.loaded));
          event.getReelsBloc
              .add(LocalMakeCommentsEvent(event.param, event.filter));
          di<GetCommentsBloc>()
              .add(LocalAddCommentsEvent(event.param, type: '+'));
        },
      );
    });
  }
}
