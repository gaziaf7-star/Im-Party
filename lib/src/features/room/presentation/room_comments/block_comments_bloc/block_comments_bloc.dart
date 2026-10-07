import 'dart:async';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/use_case/block_comments_uc.dart';
part 'block_comments_events.dart';
part 'block_comments_states.dart';

class BlockCommentsBloc extends Bloc<BlockCommentsEvents, BlockCommentsStates> {
  final BlockCommentsUC blockCommentsUC;

  BlockCommentsBloc(this.blockCommentsUC) : super(const BlockCommentsStates()) {
    on<BlockEvent>(_blockCommentsEvent);
  }

  Future<void> _blockCommentsEvent(
    BlockEvent event,
    Emitter<BlockCommentsStates> emit,
  ) async {
    emit(state.copyWith(reqState: RequestState.loading));

    final result = await blockCommentsUC(
      BlockCommentsParameter(ownerId: event.ownerId, roomId: event.roomId, value: event.value),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
            reqState: handleErrorResponse(failure),
            blockMessage: NetworkExceptions.getErrorMessage(failure)));
      },
      (success) {
        emit(state.copyWith(
          reqState: RequestState.loaded,
          blockMessage: success.data ?? '',
        ));
      },
    );
  }
}
