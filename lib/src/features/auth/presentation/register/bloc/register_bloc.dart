import 'package:flutter/cupertino.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

part 'register_event.dart';

part 'register_state.dart';

class RegisterBloc extends Bloc<BaseRegisterEvent, RegisterState> {
  final RegisterUc _registerUc;

  RegisterBloc(this._registerUc)
      : super(
          RegisterState(
            formKey: GlobalKey<FormState>(),
            phoneController: PhoneController(
              initialValue: const PhoneNumber(isoCode: IsoCode.EG, nsn: ""),
            ),
            phoneNumber: TextEditingController(),
            passwordController: TextEditingController(),
          ),
        ) {
    on<RegisterEvent>(_registerEvent);
    on<PhoneNumberEvent>(_phoneEvent);
    on<TogglePasswordVisibilityEvent>(_toggleEvent);
    on<ToggleCheckBoxEvent>(_toggleCheckBox);
    on<CountrySelected>(_changeCountryRegister);
    on<ValidEventRegister>(_validEventRegister);
    on<GetPhoneNumberEvent>(_getPhoneNumberEvent);
  }

  void _validEventRegister(
      ValidEventRegister event, Emitter<RegisterState> emit) {
    bool isValid = state.phoneNumber.text.isNotEmpty &&
        di<OtpBloc>().state.code.text.isNotEmpty &&
        state.passwordController.text.isNotEmpty;

    if (state.isFormValid != isValid) {
      emit(state.copyWith(isFormValid: isValid));
    }
  }

  void _getPhoneNumberEvent(
      GetPhoneNumberEvent event, Emitter<RegisterState> emit) {
    emit(state.copyWith(phoneNumber: event.phone));
  }

  // Events
  void _phoneEvent(PhoneNumberEvent event, Emitter<RegisterState> emit) => emit(
        state.copyWith(
          phoneController: PhoneController(
              initialValue: event.phoneNumber ??
                  const PhoneNumber(isoCode: IsoCode.EG, nsn: "")),
          validatePhoneNumber: event.validatePhoneNumber,
        ),
      );

  void _changeCountryRegister(
      CountrySelected event, Emitter<RegisterState> emit) {
    emit(state.copyWith(
      selectedCountryName: event.countryName,
      selectedCountryCode: event.countryCode,
    ));
  }

  void _toggleEvent(
      TogglePasswordVisibilityEvent event, Emitter<RegisterState> emit) {
    if (event.isFirst) {
      emit(
        state.copyWith(
          isPassword: !state.isPassword,
          suffixIcon:
              state.isPassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
        ),
      );
    } else {
      emit(
        state.copyWith(
          confirmSuffixIcon: state.isConfirmPassword
              ? CupertinoIcons.eye
              : CupertinoIcons.eye_slash,
        ),
      );
    }
  }

  void _toggleCheckBox(ToggleCheckBoxEvent event, Emitter<RegisterState> emit) {
    emit(state.copyWith(isChecked: !state.isChecked));
  }

  Future<void> _registerEvent(
    RegisterEvent event,
    Emitter<RegisterState> emit,
  ) async {
    if (state.formKey.currentState?.validate() == false) {
      return;
    }
    emit(state.copyWith(reqState: RequestState.loading));
    final result = await _registerUc(
      AuthParameterUC(
        phone: event.parameter.phone,
        password: event.parameter.password,
        code: event.parameter.code,
        firebaseIdToken: event.parameter.firebaseIdToken,
      ),
    );

    result.fold(
      (left) {
        emit(
          state.copyWith(
            reqState: RequestState.error,
            message: NetworkExceptions.getErrorMessage(left),
          ),
        );

        Methods.showToast(event.context, message: state.message, isError: true);
      },
      (right) async {
        emit(
          state.copyWith(
            reqState: RequestState.loaded,
            message: right.message,
          ),
        );

        Methods.showToast(event.context, message: state.message);
        await Methods.saveUserToken(token_: right.data ?? 'no_token');
        // di<AddInformationBloc>()
        //     .add(AddInformationEvent(event.context: event.context, ));

        if (event.context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
              event.context, Routes.addInformation, (_) => false);
        }
      },
    );
  }

  @override
  Future<void> close() {
    state.phoneNumber.dispose();
    state.phoneController.dispose();
    state.passwordController.dispose();
    return super.close();
  }
}
