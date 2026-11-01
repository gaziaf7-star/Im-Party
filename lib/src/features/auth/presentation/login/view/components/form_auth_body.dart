part of 'package:general/src/features/auth/presentation/login/view/login_page.dart';

class _FormAuthBody extends StatelessWidget {
  const _FormAuthBody();

  static const Color _black = Color(0xFF111111);
  static const Color _subText = Color(0xFF68686E);
  static const Color _fieldBg = Color(0xFFF7F7F8);
  static const Color _border = Color(0xFFE3E3E7);

  OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.r),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }

  void _openCountryPicker(BuildContext context) {
    showCountryPicker(
      context: context,
      showSearch: true,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        textStyle: const TextStyle(
          color: _black,
          fontWeight: FontWeight.w500,
        ),
        searchTextStyle: const TextStyle(
          color: _black,
        ),
        inputDecoration: InputDecoration(
          hintText: StringManager.search.tr(),
          hintStyle: TextStyle(
            color: Colors.black.withValues(alpha: 0.42),
          ),
          filled: true,
          fillColor: _fieldBg,
          border: _inputBorder(_border),
          enabledBorder: _inputBorder(_border),
          focusedBorder: _inputBorder(_black, width: 1.4),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        padding: const EdgeInsets.only(top: 10),
      ),
      onSelect: (Country country) {
        context.read<LoginBloc>().add(
          ChangeCountryEvent(country),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.showRegisterDialog) {
          showDialog(
            context: context,
            builder: (_) => RegisterAnimatedDialog(
              phoneNumber: state.phoneControllerNew,
              countryName: state.selectedCountry?.phoneCode ?? "",
              countryCode: state.selectedCountry?.countryCode ?? "",
            ),
          ).then((_) {
            context.read<LoginBloc>().add(
              const ResetLoginStateEvent(),
            );
          });
        }
      },
      builder: (context, state) {
        return BlocBuilder<LoginBloc, LoginState>(
          buildWhen: (prev, curr) =>
          prev.selectedCountry != curr.selectedCountry ||
              prev.isFoundAccount != curr.isFoundAccount ||
              prev.isFormValid != curr.isFormValid ||
              prev.isFormValidPhoneFound !=
                  curr.isFormValidPhoneFound ||
              prev.requestState != curr.requestState ||
              prev.requestStateCheckPhone !=
                  curr.requestStateCheckPhone ||
              prev.isPassword != curr.isPassword ||
              prev.suffixIcon != curr.suffixIcon,
          builder: (context, state) {
            // Phone + password in one step: the password field shows right
            // away and the button logs in (no check-phone "Next" step).
            const accountFound = true;
            final canContinue =
                state.isFormValidPhoneFound == true;
            final canLogin = state.isFormValid == true;

            return Form(
              key: state.formKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      20.w,
                      18.h,
                      20.w,
                      24.h,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                        (constraints.maxHeight - 42.h)
                            .clamp(0.0, double.infinity),
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 88.w,
                                height: 88.w,
                                padding: EdgeInsets.all(14.w),
                                decoration: BoxDecoration(
                                  color: _fieldBg,
                                  borderRadius:
                                  BorderRadius.circular(24.r),
                                  border: Border.all(
                                    color: _border,
                                  ),
                                ),
                                child: Image.asset(
                                  AssetsManager.logo,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            22.hBox,
                            TextWidget(
                              'Welcome back',
                              isTranslate: false,
                              style: context.titleLarge
                                  .size(25)
                                  .bold
                                  .colorExt(_black),
                            ),
                            6.hBox,
                            TextWidget(
                              StringManager.loginTel.tr(),
                              style: context.bodyMedium
                                  .size(14)
                                  .colorExt(_subText),
                            ),
                            26.hBox,

                            _FieldLabel(
                              label: StringManager.phone.tr(),
                            ),
                            8.hBox,
                            TextInputWidget(
                              StringManager
                                  .pleaseInterYourPhone
                                  .tr(),
                              controller:
                              state.phoneControllerNew,
                              keyboardType:
                              TextInputType.phone,
                              textColor: _black,
                              cursorColor: _black,
                              textSize: 15,
                              fillColor: _fieldBg,
                              contentPadding:
                              EdgeInsets.symmetric(
                                horizontal: 15.w,
                                vertical: 16.h,
                              ),
                              hintStyle: context.bodyMedium
                                  .size(14)
                                  .colorExt(
                                Colors.black.withValues(
                                  alpha: 0.42,
                                ),
                              ),
                              border: _inputBorder(_border),
                              enabledBorder:
                              _inputBorder(_border),
                              focusedBorder:
                              _inputBorder(
                                _black,
                                width: 1.4,
                              ),
                              errorBorder:
                              _inputBorder(
                                const Color(0xFFE5484D),
                              ),
                              focusedErrorBorder:
                              _inputBorder(
                                const Color(0xFFE5484D),
                                width: 1.3,
                              ),
                              onChanged: (value) {
                                accountFound
                                    ? context
                                    .read<LoginBloc>()
                                    .add(
                                  const UpdateFormValidationEvent(),
                                )
                                    : context
                                    .read<LoginBloc>()
                                    .add(
                                  const UpdateFormValidationEventPhoneFound(),
                                );
                              },
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty) {
                                  return StringManager
                                      .requiredField
                                      .tr();
                                }
                                return null;
                              },
                            ),

                            if (accountFound) ...[
                              18.hBox,
                              _FieldLabel(
                                label:
                                StringManager.password.tr(),
                              ),
                              8.hBox,
                              TextInputWidget(
                                StringManager.password.tr(),
                                controller:
                                state.passwordController,
                                isPassword: state.isPassword,
                                suffixIcon: state.suffixIcon,
                                suffixIconConstraints:
                                BoxConstraints(
                                  minWidth: 44.w,
                                  maxWidth: 44.w,
                                  minHeight: 44.h,
                                  maxHeight: 44.h,
                                ),
                                suffixColor: Colors.black
                                    .withValues(alpha: 0.56),
                                textColor: _black,
                                cursorColor: _black,
                                textSize: 15,
                                fillColor: _fieldBg,
                                contentPadding:
                                EdgeInsets.symmetric(
                                  horizontal: 15.w,
                                  vertical: 16.h,
                                ),
                                hintStyle: context.bodyMedium
                                    .size(14)
                                    .colorExt(
                                  Colors.black.withValues(
                                    alpha: 0.42,
                                  ),
                                ),
                                border:
                                _inputBorder(_border),
                                enabledBorder:
                                _inputBorder(_border),
                                focusedBorder:
                                _inputBorder(
                                  _black,
                                  width: 1.4,
                                ),
                                errorBorder:
                                _inputBorder(
                                  const Color(0xFFE5484D),
                                ),
                                focusedErrorBorder:
                                _inputBorder(
                                  const Color(0xFFE5484D),
                                  width: 1.3,
                                ),
                                onChanged: (value) {
                                  context
                                      .read<LoginBloc>()
                                      .add(
                                    const UpdateFormValidationEvent(),
                                  );
                                },
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty) {
                                    return StringManager
                                        .requiredField
                                        .tr();
                                  }
                                  return null;
                                },
                                onPressed: () => context
                                    .read<LoginBloc>()
                                    .add(
                                  const TogglePasswordEvent(),
                                ),
                              ),
                              5.hBox,
                              Align(
                                alignment:
                                AlignmentDirectional
                                    .centerEnd,
                                child: TextButton(
                                  onPressed: () =>
                                      context.pushNamedRoute(
                                        Routes.recoverPassword,
                                      ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: _black,
                                    padding:
                                    EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                      vertical: 5.h,
                                    ),
                                  ),
                                  child: Text(
                                    StringManager
                                        .recoverPassword_
                                        .tr(),
                                    style: TextStyle(
                                      color: _black,
                                      fontSize: 13.sp,
                                      fontWeight:
                                      FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            26.hBox,
                            ButtonWidget(
                              title: accountFound
                                  ? StringManager.login.tr()
                                  : StringManager.next.tr(),
                              height: 50.h,
                              width: double.infinity,
                              radius: 25.r,
                              backgroundColor:
                              (accountFound
                                  ? canLogin
                                  : canContinue)
                                  ? _black
                                  : const Color(0xFFD0D0D3),
                              titleColor: Colors.white,
                              cLoadingColor: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              isLoading: accountFound
                                  ? state.requestState.isLoading
                                  : state
                                  .requestStateCheckPhone
                                  .isLoading,
                              onPressed: accountFound
                                  ? (canLogin
                                  ? () {
                                context
                                    .read<LoginBloc>()
                                    .add(
                                  LoginWithPhoneEvent(
                                    context:
                                    context,
                                    isLogin: true,
                                  ),
                                );
                              }
                                  : null)
                                  : (canContinue
                                  ? () {
                                context
                                    .read<LoginBloc>()
                                    .add(
                                  const CheckPhoneEvent(),
                                );
                              }
                                  : null),
                            ),

                            const Spacer(),
                            22.hBox,
                            Center(
                              child: InkWell(
                                onTap: () =>
                                    context.pushNamedRoute(
                                      Routes.privacy,
                                    ),
                                borderRadius:
                                BorderRadius.circular(8.r),
                                child: Padding(
                                  padding:
                                  EdgeInsets.symmetric(
                                    horizontal: 5.w,
                                    vertical: 6.h,
                                  ),
                                  child: Text.rich(
                                    textAlign: TextAlign.center,
                                    TextSpan(
                                      text: StringManager
                                          .agreeLogin
                                          .tr(),
                                      style: TextStyle(
                                        color: _subText,
                                        fontSize: 11.5.sp,
                                        height: 1.35,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: StringManager
                                              .userAgreementLogin
                                              .tr(),
                                          style: const TextStyle(
                                            color: _black,
                                            fontWeight:
                                            FontWeight.w700,
                                            decoration:
                                            TextDecoration
                                                .underline,
                                          ),
                                        ),
                                        TextSpan(
                                          text: StringManager
                                              .andLogin
                                              .tr(),
                                          style: TextStyle(
                                            color: _subText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextWidget(
          label,
          style: context.bodyMedium
              .size(13)
              .w600
              .colorExt(const Color(0xFF111111)),
        ),
        TextWidget(
          ' *',
          isTranslate: false,
          style: context.bodyMedium
              .size(13)
              .bold
              .colorExt(const Color(0xFFE5484D)),
        ),
      ],
    );
  }
}
