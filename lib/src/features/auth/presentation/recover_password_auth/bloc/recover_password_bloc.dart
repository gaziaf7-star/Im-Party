import 'package:flutter/cupertino.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

part 'recover_password_event.dart';
part 'recover_password_state.dart';

class RecoverPasswordBloc
    extends Bloc<BaseRecoverPasswordEvent, RecoverPasswordState> {
  final ForgetPasswordUC _forgetPasswordUc;

  RecoverPasswordBloc(this._forgetPasswordUc)
      : super(
          RecoverPasswordState(
            formKeyRP: GlobalKey<FormState>(),
            formKeyCP: GlobalKey<FormState>(),
            phoneController: PhoneController(
              initialValue: const PhoneNumber(isoCode: IsoCode.EG, nsn: ""),
            ),
            passwordCtrl: TextEditingController(),
            confirmPasswordCtrl: TextEditingController(),
            phoneControllerNew: TextEditingController(),
          ),
        ) {
    on<RecoverPasswordFetchPhoneEvent>(_phoneEvent);
    on<RecoverTogglePasswordEvent>(_recoverTogglePasswordEvent);
    on<RecoverToggleConfirmPasswordEvent>(_recoverToggleConfirmPasswordEvent);
    on<RecoverPasswordEvent>(_recoverPasswordEvent);
    on<ToggleErrorReasonsEvent>(_toggleErrorReasons);
    on<ChangeCountryRecoverEvent>(_changeCountryEvent);
    on<IsPhoneEmptyEvent>(_isPhoneValida);
    on<ValidaEvent>(_validaPhoneCode);
  }

  void _isPhoneValida(
      IsPhoneEmptyEvent event, Emitter<RecoverPasswordState> emit) {
    bool isValid = state.phoneControllerNew.text.isNotEmpty;
    if (state.isPhoneEmpty != isValid) {
      emit(state.copyWith(isPhoneEmpty: isValid));
    }
  }

  void _validaPhoneCode(ValidaEvent event, Emitter<RecoverPasswordState> emit) {
    bool isValid = state.phoneControllerNew.text.isNotEmpty &&
        di<OtpBloc>().state.code.text.isNotEmpty;

    if (state.isFormValid != isValid) {
      emit(state.copyWith(isFormValid: isValid));
    }
  }

  void _changeCountryEvent(
      ChangeCountryRecoverEvent event, Emitter<RecoverPasswordState> emit) {
    emit(state.copyWith(selectedCountry: event.newCountry));
  }

  void _phoneEvent(
    RecoverPasswordFetchPhoneEvent event,
    Emitter<RecoverPasswordState> emit,
  ) {
    emit(
      state.copyWith(
        phoneController: PhoneController(initialValue: event.phoneNumber!),
        validatePhoneNumber: event.validatePhoneNumber,
      ),
    );
  }

  void _toggleErrorReasons(
    ToggleErrorReasonsEvent event,
    Emitter<RecoverPasswordState> emit,
  ) {
    emit(state.copyWith(showErrorReasons: !state.showErrorReasons));
  }

  void _recoverTogglePasswordEvent(
    RecoverTogglePasswordEvent event,
    Emitter<RecoverPasswordState> emit,
  ) =>
      emit(
        state.copyWith(
          isPassword: !state.isPassword,
          suffixIcon:
              state.isPassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
        ),
      );

  void _recoverToggleConfirmPasswordEvent(
    RecoverToggleConfirmPasswordEvent event,
    Emitter<RecoverPasswordState> emit,
  ) =>
      emit(
        state.copyWith(
          isConfirmPassword: !state.isConfirmPassword,
          confirmSuffixIcon: state.isConfirmPassword
              ? CupertinoIcons.eye
              : CupertinoIcons.eye_slash,
        ),
      );

  Future<void> _recoverPasswordEvent(
    RecoverPasswordEvent event,
    Emitter<RecoverPasswordState> emit,
  ) async {
    if (state.formKeyCP.currentState?.validate() == false) {
      return;
    }
    emit(state.copyWith(reqStateCP: RequestState.loading));
    final result = await _forgetPasswordUc(
      AuthParameterUC(
        phone: event.phone,
        password: state.passwordCtrl.text,
        code: event.code,
        firebaseIdToken: event.code,
      ),
    );

    result.fold(
      (left) {
        emit(
          state.copyWith(
            reqStateCP: RequestState.error,
            message: NetworkExceptions.getErrorMessage(left),
          ),
        );
        Methods.showToast(event.context, message: state.message, isError: true);
      },
      (right) {
        emit(
          state.copyWith(
            reqStateCP: RequestState.loaded,
            message: right.message,
          ),
        );
        debugPrint(
          '[LOGIN_REDIRECT] source=RecoverPasswordBloc status=success '
          'reason=password_changed',
        );
        event.context.pushNamedAndRemoveUntil(Routes.login);
        Methods.showToast(event.context, message: state.message);
      },
    );
  }

  @override
  Future<void> close() {
    state.phoneController.dispose();
    state.passwordCtrl.dispose();
    state.confirmPasswordCtrl.dispose();
    return super.close();
  }
}
