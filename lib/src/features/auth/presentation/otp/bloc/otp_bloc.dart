import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/auth/presentation/change_phone/bloc/change_number_bloc.dart';
import 'package:general/src/features/setting/presentation/account_setting/bind_number/bind_number_bloc.dart';

part 'otp_event.dart';

part 'otp_state.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final FirebasePhoneAuthService _firebasePhoneAuthService;

  OtpBloc(this._firebasePhoneAuthService)
      : super(
          OtpState(
            code: TextEditingController(),
          ),
        ) {
    on<FetchCodeOTPEvent>(_fetchCodeOTPEvent);
    on<VerifyCodeOTPEvent>(_verifyCodeEvent);
  }

  /// Holds a Firebase ID token obtained via Android instant/auto verification,
  /// so a manual confirm step can reuse it instead of re-signing in.
  String? _autoVerifiedIdToken;

  void setAutoVerifiedToken(String idToken) {
    _autoVerifiedIdToken = idToken.isEmpty ? null : idToken;
  }

  // Events
  void startTimerCountDown() async {
    state.timer?.cancel();
    emit(state.copyWith(counter: 2 * 60));
    const oneSeconds = Duration(seconds: 1);
    emit(
      state.copyWith(
        timer: Timer.periodic(
          oneSeconds,
          (Timer timer) {
            if (state.counter == 0) {
              timer.cancel();
            } else {
              emit(state.copyWith(counter: state.counter - 1));
            }
          },
        ),
      ),
    );
  }

  void resetTimerCounter({bool cancelTimer = false}) {
    if (cancelTimer) {
      state.timer?.cancel();
    }
    emit(state.copyWith(counter: 0));
  }

  void _fetchCodeOTPEvent(
    FetchCodeOTPEvent event,
    Emitter<OtpState> emit,
  ) {
    emit(state.copyWith(code: event.codeOTP));
  }

  void _verifyCodeEvent(
    VerifyCodeOTPEvent event,
    Emitter<OtpState> emit,
  ) async {
    emit(state.copyWith(reqState: RequestState.loading));

    final String firebaseIdToken;
    try {
      firebaseIdToken = _autoVerifiedIdToken ??
          await _firebasePhoneAuthService.confirmCode(
            smsCode: state.code.text,
          );
      _autoVerifiedIdToken = null;
    } on FirebaseAuthException catch (e) {
      final message = e.message ?? 'The verification code is incorrect.';
      emit(state.copyWith(reqState: RequestState.error, message: message));
      Methods.showToast(event.context, message: message, isError: true);
      return;
    } catch (_) {
      const message = 'The verification code is incorrect.';
      emit(state.copyWith(reqState: RequestState.error, message: message));
      Methods.showToast(event.context, message: message, isError: true);
      return;
    }

    emit(state.copyWith(reqState: RequestState.loaded));
    state.timer?.cancel();

    switch (event.parameter.otpType) {
      case OtpType.resetPassword:
        _createPassword(event, firebaseIdToken);
        return;
      case OtpType.register:
        _register(event, firebaseIdToken);
        return;
      case OtpType.passwordChange:
        _forgetPassword(event, firebaseIdToken);
        return;
      case OtpType.verifyOldPhone:
        _changeNumber(event, firebaseIdToken);
        return;
      case OtpType.verifyNewPhone:
        _changeNewPhone(event, firebaseIdToken);
        return;
      case OtpType.bindAccount:
        _bindNumber(event, firebaseIdToken);
        return;
    }
  }

  void _createPassword(VerifyCodeOTPEvent event, String firebaseIdToken) {
    event.context.pushNamedRoute(
      Routes.createPassword,
      arguments: {
        "phone": event.parameter.phone,
        "code": firebaseIdToken,
        "firebase_id_token": firebaseIdToken,
      },
    );
  }

  void _changeNumber(VerifyCodeOTPEvent event, String firebaseIdToken) {
    event.context.pushNamedRoute(Routes.changePhoneNewScreen,
        arguments: SendCodeParameter(
          otpType: OtpType.verifyOldPhone,
          phone: event.parameter.phone,
          firebaseIdToken: firebaseIdToken,
        ));
  }

  void _register(VerifyCodeOTPEvent event, String firebaseIdToken) {
    event.context.read<RegisterBloc>().add(
          RegisterEvent(
            context: event.context,
            parameter: SendCodeParameter(
              phone: event.parameter.phone,
              code: firebaseIdToken,
              firebaseIdToken: firebaseIdToken,
              password: event.parameter.password,
              otpType: OtpType.register,
            ),
          ),
        );
  }

  void _bindNumber(VerifyCodeOTPEvent event, String firebaseIdToken) {
    event.context.read<AccountBloc>().add(
          BindNumberEvent(
            buildContext: event.context,
            bindAccountParam: SendCodeParameter(
              phone: event.parameter.phone,
              code: firebaseIdToken,
              firebaseIdToken: firebaseIdToken,
              password: event.parameter.password,
              otpType: OtpType.bindAccount,
            ),
          ),
        );
  }

  void _changeNewPhone(VerifyCodeOTPEvent event, String firebaseIdToken) {
    event.context.read<ChangePhoneBloc>().add(
          ChangeNumberEvent(
            context: event.context,
            bindAccountParam: SendCodeParameter(
              phone: event.parameter.phone,
              newPhone: event.parameter.newPhone,
              firebaseIdToken: firebaseIdToken,
              password: event.parameter.password,
              otpType: OtpType.verifyNewPhone,
            ),
          ),
        );
  }

  void _forgetPassword(VerifyCodeOTPEvent event, String firebaseIdToken) {
    event.context.pushNamedRoute(
      Routes.createNewPassword,
      arguments: {
        "phone": event.parameter.phone,
        "code": firebaseIdToken,
        "firebase_id_token": firebaseIdToken,
      },
    );
  }

  @override
  Future<void> close() {
    state.code.clear();
    state.code.dispose();
    state.timer?.cancel();
    return super.close();
  }
}
