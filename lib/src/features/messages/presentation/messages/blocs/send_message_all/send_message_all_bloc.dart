import 'package:general/src/core/index.dart';
import 'package:general/src/features/messages/domain/usecases/send_message_all_uc.dart';

part 'send_message_all_event.dart';
part 'send_message_all_state.dart';

class SendMessageAllBloc extends Bloc<BaseSendMessageAllEvent, SendMessageAllState> {
  final SendMessageAllUseCase _sendMessageAllUseCase;

  SendMessageAllBloc(this._sendMessageAllUseCase)
      : super(
          SendMessageAllState(
            messageController: TextEditingController(),
          ),
        ) {
    on<SendMessageAllEvent>(_sendMessageAllEvent);
  }

  Future<void> _sendMessageAllEvent(
    SendMessageAllEvent event,
    Emitter<SendMessageAllState> emit,
  ) async {
    emit(state.copyWith(reqState: RequestState.loading,));
    
    final result = await _sendMessageAllUseCase(
      SendMessageAllPram(
        users: event.users!,
        message: event.message,
        url: event.url,
        exceptUsers: event.exceptUsers,
        type: event.type,
      ),
    );
    
    result.fold(
      (left) => emit(state.copyWith(reqState: RequestState.error, errorMessage:  NetworkExceptions.getErrorMessage(left))),
      (right) => emit(
        state.copyWith(
          responseData: right.message,
          reqState: RequestState.loaded,
        ),
      ),
    );
  }
}