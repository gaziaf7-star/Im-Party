import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

part 'send_code_event.dart';
part 'send_code_state.dart';

class SendCodeBloc extends Bloc<BaseSendCodeEvent, SendCodeState> {
  final FirebasePhoneAuthService _firebasePhoneAuthService;

  SendCodeBloc(this._firebasePhoneAuthService)
      : super(const SendCodeState()) {
    on<SendCodeEvent>(_sendCodeEvent);
  }

  // Events
  Future<void> _sendCodeEvent(
    SendCodeEvent event,
    Emitter<SendCodeState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));

    final completer = Completer<void>();

    await _firebasePhoneAuthService.startVerification(
      phone: event.parameter.phone,
      onCodeSent: (verificationId) {
        emit(
          state.copyWith(
            requestState: RequestState.loaded,
            verificationId: verificationId,
          ),
        );
        // Manual entry is expected from here; drop any stale auto-verify token.
        di<OtpBloc>().setAutoVerifiedToken('');
        di<OtpBloc>().startTimerCountDown();
        if (!completer.isCompleted) completer.complete();
      },
      onAutoVerified: (idToken) {
        di<OtpBloc>().setAutoVerifiedToken(idToken);
        if (!completer.isCompleted) completer.complete();
      },
      onError: (message) {
        emit(
          state.copyWith(
            requestState: RequestState.error,
            message: message,
          ),
        );
        Methods.showToast(event.context, message: message, isError: true);
        di<OtpBloc>().startTimerCountDown();
        if (!completer.isCompleted) completer.complete();
      },
    );

    await completer.future;
  }
}
