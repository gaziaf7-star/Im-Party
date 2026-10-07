import 'package:general/src/core/index.dart';
import 'package:general/src/features/messages/messages.dart';

part 'delete_message_event.dart';
part 'delete_message_state.dart';

class DeleteMessageBloc
    extends Bloc<BaseDeleteMessageEvent, DeleteMessageState> {
  final DeleteMessageUC _deleteMessageUC;
  DeleteMessageBloc(this._deleteMessageUC) : super(const DeleteMessageState()) {
    on<DeleteMessageEvent>(
      (event, emit) async {
        final result = await _deleteMessageUC(
          DeleteMessageParamsUC(
            messageIds: event.messageIds,
            deleteType: event.deleteType,
          ),
        );
        result.fold(
          (left) => emit(state.copyWith(reqState: RequestState.error)),
          (right) => emit(
            state.copyWith(
              message: right.message,
              reqState: RequestState.loaded,
            ),
          ),
        );
      },
    );
  }
}
