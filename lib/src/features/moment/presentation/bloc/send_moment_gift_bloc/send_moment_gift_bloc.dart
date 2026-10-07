import 'dart:async';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/domain/usecases/send_gift_moment_us.dart';

part 'send_moment_gift_events.dart';
part 'send_moment_gift_states.dart';

class SendMomentGiftBloc extends Bloc<SendMomentGiftEvents, SendMomentGiftStates> {
  final SendGiftMomentUsGiftUC sendMomentGiftUC;

  SendMomentGiftBloc({required this.sendMomentGiftUC}) : super(const IntialSendGiftMomentStates()) {
    on<SendGiftsEvent>(_sendGiftEvent);
  }

  Future<void> _sendGiftEvent(
      SendGiftsEvent event,
    Emitter<SendMomentGiftStates> emit,
  ) async {
    emit(const LoadingSendGiftMomentStates());
    final result = await sendMomentGiftUC(
      SendGiftMomentParameter(
        number: event.number,
        giftId: event.giftId,
        momentID: event.momentID,
      ),
    );

    result.fold(
      (failure) => emit(
        ErrorSendGiftMomentStates(
          error: NetworkExceptions.getErrorMessage(failure),
        ),
      ),
      (success) => emit(
        SuccessSendGiftMomentStates(message: success),
      ),
    );
  }
}
