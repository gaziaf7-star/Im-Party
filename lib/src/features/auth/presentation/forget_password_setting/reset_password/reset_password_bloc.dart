import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/domain/use_cases/forget_password_setting_uc.dart';

part 'reset_password_event.dart';

part 'reset_password_state.dart';

class ResetPasswordBloc
    extends Bloc<BaseResetPasswordEvent, ResetPasswordState> {
  final ChangeForgetPassUseCase changePasswordUc;

  ResetPasswordBloc({required this.changePasswordUc})
      : super(
          ResetPasswordState(
            formKeyRP: GlobalKey<FormState>(),
            formKeyCP: GlobalKey<FormState>(),
            phoneController: PhoneController(
              initialValue: const PhoneNumber(isoCode: IsoCode.EG, nsn: ""),
            ),
            passwordCtrl: TextEditingController(),
            confirmPasswordCtrl: TextEditingController(),
          ),
        ) {
    on<RecoverPasswordFetchPhoneEvent>(_phoneEvent);
    on<RecoverPasswordTogglePassword1Event>(_toggle1Event);
    on<RecoverPasswordTogglePassword2Event>(_toggle2Event);
    on<RecoverPasswordEvent>(_recoverPasswordEvent);

  }

  // Events
  void _phoneEvent(RecoverPasswordFetchPhoneEvent event,
          Emitter<ResetPasswordState> emit) =>
      emit(
        state.copyWith(
          phoneController: PhoneController(initialValue: event.phone!),
          validatePhoneNumber: event.validatePhoneNumber,
        ),
      );

  void _toggle1Event(
    RecoverPasswordTogglePassword1Event event,
    Emitter<ResetPasswordState> emit,
  ) =>
      emit(
        state.copyWith(
          isPassword: !state.isPassword,
          suffixIcon:
              state.isPassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
        ),
      );

  void _toggle2Event(
    RecoverPasswordTogglePassword2Event event,
    Emitter<ResetPasswordState> emit,
  ) =>
      emit(
        state.copyWith(
          isConfirmPassword: !state.isConfirmPassword,
          confirmSuffixIcon: state.isConfirmPassword
              ? CupertinoIcons.eye
              : CupertinoIcons.eye_slash,
        ),
      );

  // create_new_password_event
  Future<void> _recoverPasswordEvent(
      RecoverPasswordEvent event, Emitter<ResetPasswordState> emit) async {
    if (state.formKeyCP.currentState?.validate() == false) {
      return;
    }

    emit(state.copyWith(reqStateCP: RequestState.loading));


    /*   log('${AuthParameterUC(
      phone: state.phoneController.value.international,
      password: state.passwordCtrl.text,
      code: state.codeOTP,
    )}');*/
    final result = await changePasswordUc(
      SendCodeParameter(
        phone: event.number,
        password: state.passwordCtrl.text,
        code: event.codeOtp,
        otpType: OtpType.passwordChange,
        type: event.type,
      ),
    );

    result.fold(
      (left) {
        Methods.showToast(event.context, message: state.message!,isError: true);
        emit(
        state.copyWith(
          reqStateCP: RequestState.error,
          message: NetworkExceptions.getErrorMessage(left),
        ),
      );
        Navigator.pop(event.context);
      },
      (right) {
        event.context.pushNamedAndRemoveUntil(Routes.layout);
        //Methods.showToast(event.context, message: StringManager.resetSuccessful.tr());
        emit(
        state.copyWith(
          reqStateCP: RequestState.loaded,
          message: right.message,
        ),
      );
        //
      },
    );
  }


/*  FutureOr<void> _validateFetchCodeOTP(
      ValidateCodeOTPRecoverPasswordEvent event,
      Emitter<ResetPasswordState> emit)async {
    emit(state.copyWith(codeOTP: event.codeOTP));
  }*/
  @override
  Future<void> close() {
    state.phoneController.dispose();
    state.passwordCtrl.dispose();
    state.confirmPasswordCtrl.dispose();
    return super.close();
  }


}
