import 'package:flutter/cupertino.dart';
import 'package:country_picker/country_picker.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/setting/domain/use_case/bind_google_use_case.dart';

import '../../../domain/use_case/bind_number_use_case.dart';

part 'bind_number_event.dart';

part 'bind_number_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final BindNumberUseCase bindNumberUseCase;
  final ChangePassUseCase changePassUseCase;
  final BindGoogleUseCase bindGoogleUseCase;

  AccountBloc({
    required this.bindNumberUseCase,
    required this.changePassUseCase,
    required this.bindGoogleUseCase,
  }) : super(
          AccountState(
            formKey: GlobalKey<FormState>(),
            phoneController: PhoneController(
              initialValue: const PhoneNumber(isoCode: IsoCode.EG, nsn: ""),
            ),
            passwordController: TextEditingController(),
            phoneControllerNew: TextEditingController(),
          ),
        ) {
    on<FetchPhoneEvent>(_phoneEvent);
    on<FetchPasswordEvent>(_fetchPassword);
    on<TogglePasswordBindEvent>(_toggleEvent);
    on<ChangeCountryBindPhone>(_changeCountryBindPhone);

    on<BindNumberEvent>((event, emit) async {
      final result = await bindNumberUseCase(
        SendCodeParameter(
          phone: event.bindAccountParam.phone,
          password: state.passwordController.text,
          code: event.bindAccountParam.code,
          firebaseIdToken: event.bindAccountParam.firebaseIdToken,
          otpType: OtpType.bindAccount,
        ),
      );
      result.fold((l) {
        emit(state.copyWith(
            bindNumberState: RequestState.error,
            bindNumberError: NetworkExceptions.getErrorMessage(l)));
        Methods.showToast(event.buildContext,
            message: state.bindNumberError ?? '', isError: true);
      }, (r) {
        emit(state.copyWith(
            bindNumberState: RequestState.loaded,
            bindNumberSuccessMessage: r.message));
        const MyDataModel().copyWith(
          isPhone: true,
        );
        Methods.showToast(
          event.buildContext,
          message: state.bindNumberSuccessMessage ?? '',
        );
        event.buildContext.popUntilRoute(Routes.layout);
      });
    });

    on<ChangePasswordEvent>((event, emit) async {
      final result = await changePassUseCase(event.bindAccountParam);
      result.fold(
          (l) => emit(state.copyWith(
              changePasswordState: RequestState.error,
              changePasswordError: NetworkExceptions.getErrorMessage(l))),
          (r) => emit(state.copyWith(
              changePasswordState: RequestState.loaded,
              changeNumberSuccessMessage: r.message)));
    });

    on<BindGoogleEvent>((event, emit) async {
      final result = await bindGoogleUseCase();
      result.fold((l) {
        emit(state.copyWith(
            googleAuthState: RequestState.error,
            googleAuthError: NetworkExceptions.getErrorMessage(l)));
      }, (r) {
        emit(state.copyWith(
            googleAuthState: RequestState.loaded, googleAuthSuccessMessage: r));
        const MyDataModel().copyWith(
          isGoogle: true,
        );
        Methods.showToast(event.context, message: r);
        event.context.popUntilRoute(Routes.layout);
      });
    });
  }

  void _phoneEvent(FetchPhoneEvent event, Emitter<AccountState> emit) => emit(
        state.copyWith(
          phoneController: PhoneController(
            initialValue:
                event.phone ?? const PhoneNumber(isoCode: IsoCode.EG, nsn: ""),
          ),
          validatePhoneNumber: event.validatePhoneNumber,
        ),
      );

  void _fetchPassword(FetchPasswordEvent event, Emitter<AccountState> emit) =>
      emit(
        state.copyWith(passwordController: event.passWord ?? ''),
      );

  void _toggleEvent(
          TogglePasswordBindEvent event, Emitter<AccountState> emit) =>
      emit(
        state.copyWith(
          isPassword: !state.isPassword,
          suffixIcon:
              state.isPassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
        ),
      );
  void _changeCountryBindPhone(
      ChangeCountryBindPhone event, Emitter<AccountState> emit) {
    emit(state.copyWith(selectedCountry: event.newCountry));
  }
}
