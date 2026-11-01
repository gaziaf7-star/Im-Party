import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/auth/domain/use_cases/check_phone.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUC loginUC;
  final CheckPhoneUC checkPhoneUC;

  LoginBloc({required this.loginUC, required this.checkPhoneUC})
      : super(
          LoginState(
            formKey: GlobalKey<FormState>(),
            phoneController: PhoneController(
              initialValue: const PhoneNumber(isoCode: IsoCode.EG, nsn: ""),
            ),
            passwordController: TextEditingController(),
            phoneControllerNew: TextEditingController(),
          ),
        ) {
    on<FetchPhoneEvent>(_phoneEvent);
    on<TogglePasswordEvent>(_toggleEvent);
    on<LoginWithPhoneEvent>(_loginEvent);
    on<ToggleTheCheckBoxEvent>(_toggleBoxEvent);
    on<ChangeCountryEvent>(_changeCountryEvent);
    on<UpdateFormValidationEvent>(_updateFormValidation);
    on<UpdateFormValidationEventPhoneFound>(_updatFormValidationPhoneFound);
    on<CheckPhoneEvent>(_checkPhone);

    on<ResetLoginStateEvent>((event, emit) {
      emit(state.copyWith(
        isFoundAccount: null,
        showRegisterDialog: false,
      ));
    });
  }

  // Events
  void _toggleBoxEvent(
          ToggleTheCheckBoxEvent event, Emitter<LoginState> emit) =>
      emit(
        state.copyWith(isChecked: event.isChecked),
      );

  void _checkPhone(CheckPhoneEvent event, Emitter<LoginState> emit) async {
    if (state.formKey.currentState?.validate() == false) {
      return;
    }

    emit(state.copyWith(requestStateCheckPhone: RequestState.loading));
    final result = await checkPhoneUC(
        "+${state.selectedCountry?.phoneCode}${state.phoneControllerNew.text}");

    result.fold(
      (left) {
        emit(
          state.copyWith(
            message: NetworkExceptions.getErrorMessage(left),
            requestStateCheckPhone: RequestState.error,
          ),
        );
      },
      (right) async {
        emit(
          state.copyWith(
            message: right.message,
            isFoundAccount: right.data,
            requestStateCheckPhone: RequestState.loaded,
            showRegisterDialog: right.data == false,
          ),
        );
      },
    );
  }

  void _phoneEvent(FetchPhoneEvent event, Emitter<LoginState> emit) => emit(
        state.copyWith(
          phoneController: PhoneController(
            initialValue:
                event.phone ?? const PhoneNumber(isoCode: IsoCode.EG, nsn: ""),
          ),
          validatePhoneNumber: event.validatePhoneNumber,
        ),
      );

  void _toggleEvent(TogglePasswordEvent event, Emitter<LoginState> emit) =>
      emit(
        state.copyWith(
          isPassword: !state.isPassword,
          suffixIcon:
              state.isPassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
        ),
      );

  void _loginEvent(LoginWithPhoneEvent event, Emitter<LoginState> emit) async {
    if (state.formKey.currentState?.validate() == false) {
      return;
    }
    emit(state.copyWith(requestState: RequestState.loading));
    final result = await loginUC(
      AuthParameter(
        // Phone number exactly as typed — no country code.
        phone: state.phoneControllerNew.text.trim(),
        password: state.passwordController.text,
        isMulti: false,
      ),
    );

    result.fold(
      (left) {
        emit(
          state.copyWith(
            message: NetworkExceptions.getErrorMessage(left),
            requestState: RequestState.error,
          ),
        );
        if (state.requestState == RequestState.loaded) {
          return;
        }

        Methods.showToast(event.context, message: state.message, isError: true);
      },
      (right) async {
        emit(
          state.copyWith(
            message: right.message,
            requestState: RequestState.loaded,
          ),
        );

        Methods.showToast(event.context, message: state.message);
        const MyDataModel().clearInstance();
        await DependencyInjectionService.reset();
        await DependencyInjectionService.init();
        event.context.pushNamedAndRemoveUntil(Routes.layout);
        await Methods.saveUserToken(token_: right.data?.authToken ?? '');
        await Methods.saveUserLoginAccountIdToken(
          token: right.data?.authToken ?? '',
          accountId: right.data?.id.toString() ?? '',
        );
      },
    );
  }

  void _changeCountryEvent(ChangeCountryEvent event, Emitter<LoginState> emit) {
    emit(state.copyWith(
        selectedCountry: event.newCountry, isFoundAccount: null));
    add(const UpdateFormValidationEvent());
  }

  void _updateFormValidation(
      UpdateFormValidationEvent event, Emitter<LoginState> emit) {
    bool isValid = state.phoneControllerNew.text.trim().isNotEmpty &&
        state.passwordController.text.isNotEmpty;

    if (state.isFormValid != isValid) {
      emit(state.copyWith(isFormValid: isValid));
    }
  }

  void _updatFormValidationPhoneFound(
      UpdateFormValidationEventPhoneFound event, Emitter<LoginState> emit) {
    bool isValid = state.phoneControllerNew.text.isNotEmpty &&
        state.selectedCountry != null;

    if (state.isFormValidPhoneFound != isValid) {
      emit(state.copyWith(isFormValidPhoneFound: isValid));
    }
  }

  @override
  Future<void> close() {
    state.phoneController.dispose();
    state.passwordController.dispose();
    return super.close();
  }
}
