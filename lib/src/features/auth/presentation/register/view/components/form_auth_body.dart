part of 'package:general/src/features/auth/presentation/register/view/register_page.dart';

class _FormAuthBody extends StatefulWidget {
  final String countryName;
  final String countryCode;
  final TextEditingController phoneNumberText;

  const _FormAuthBody({
    required this.countryName,
    required this.countryCode,
    required this.phoneNumberText,
  });

  @override
  State<_FormAuthBody> createState() => _FormAuthBodyState();
}

class _FormAuthBodyState extends State<_FormAuthBody> {
  @override
  void initState() {
    super.initState();
    final registerBloc = context.read<RegisterBloc>();
    if (registerBloc.state.selectedCountryName.isEmpty &&
        registerBloc.state.selectedCountryCode.isEmpty) {
      registerBloc.add(
        CountrySelected(
          countryName: widget.countryName,
          countryCode: widget.countryCode,
        ),
      );
    }

    if (widget.phoneNumberText.text.isNotEmpty) {
      context
          .read<RegisterBloc>()
          .add(GetPhoneNumberEvent(phone: widget.phoneNumberText.text));
    }
  }

  void _openCountryPicker(BuildContext context) {
    showCountryPicker(
      context: context,
      showSearch: false,
      countryListTheme: CountryListThemeData(
        textStyle: TextStyle(color: ColorManager.textPrimary),
        searchTextStyle: TextStyle(color: ColorManager.textPrimary),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        padding: const EdgeInsets.only(top: 10),
      ),
      onSelect: (Country country) {
        context.read<RegisterBloc>().add(
              CountrySelected(
                countryName: country.name,
                countryCode: country.countryCode,
              ),
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (prev, curr) =>
          prev.selectedCountryName != curr.selectedCountryName ||
          prev.selectedCountryCode != curr.selectedCountryCode ||
          prev.isFormValid != curr.isFormValid ||
          prev.suffixIcon != curr.suffixIcon ||
          prev.isPassword != curr.isPassword ||
          prev.reqState != curr.reqState,
      builder: (context, state) {
        final displayedCountryCode = state.selectedCountryName.isNotEmpty
            ? state.selectedCountryName
            : widget.countryName;
        return BlocBuilder<OtpBloc, OtpState>(
          buildWhen: (prev, curr) => prev.counter != curr.counter,
          builder: (context, otpState) {
            return Form(
              key: state.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  30.hBox,
                  GestureDetector(
                    onTap: () => _openCountryPicker(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorManager.grayLight,
                        borderRadius: 20.radius,
                      ),
                      child: Row(
                        children: [
                          10.wBox,
                          TextWidget(
                            "${state.selectedCountryName} (+${state.selectedCountryCode})",
                            style: context.bodyMedium
                                .size(16)
                                .colorExt(ColorManager.textPrimary),
                          ),
                          10.wBox,
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey,
                          ),
                          Expanded(
                            child: TextInputWidget(
                              StringManager.phoneNum.tr(),
                              contentPadding: EdgeInsets.zero,
                              keyboardType: TextInputType.phone,
                              controller: state.phoneNumber,
                              onChanged: (value) {
                                context
                                    .read<RegisterBloc>()
                                    .add(const ValidEventRegister());
                              },
                              textColor: ColorManager.textPrimary,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              border: InputBorder.none,
                              errorBorder: InputBorder.none,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return StringManager.requiredField.tr();
                                }
                                if (!Methods().isValidPhoneNumber(
                                    state.selectedCountryCode, value)) {
                                  return StringManager.phoneValidator.tr();
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  15.hBox,
                  TextInputWidget(
                    border: OutlineInputBorder(
                      borderRadius: 30.radius,
                      borderSide: BorderSide(
                        width: 1.5,
                        color: ColorManager.grayLight.withValues(alpha: 0.7),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: 30.radius,
                      borderSide: BorderSide(
                        width: 1.5,
                        color: ColorManager.grayLight.withValues(alpha: 0.7),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: 30.radius,
                      borderSide: BorderSide(
                        width: 1.5,
                        color: ColorManager.grayLight.withValues(alpha: 0.7),
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: 30.radius,
                      borderSide: BorderSide(
                        width: 1.5,
                        color: ColorManager.grayLight.withValues(alpha: 0.7),
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: 30.radius,
                      borderSide: BorderSide(
                        width: 1.5,
                        color: ColorManager.grayLight.withValues(alpha: 0.7),
                      ),
                    ),
                    StringManager.code.tr(),
                    maxLength: 6,
                    showMaxLength: null,
                    fillColor: ColorManager.grayLight.withValues(alpha: 0.7),
                    onChanged: (value) {
                      di<OtpBloc>()
                          .add(FetchCodeOTPEvent(codeOTP: value.toString()));

                      context
                          .read<RegisterBloc>()
                          .add(const ValidEventRegister());
                    },
                    keyboardType: TextInputType.phone,
                    contentPadding:
                        context.paddingSymmetric(vertical: 15, horizontal: 20),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return StringManager.requiredField.tr();
                      }
                      return null;
                    },
                  ),
                  10.hBox,
                  InkWell(
                    onDoubleTap: () {},
                    onTap: () {
                      if (context
                          .read<SendCodeBloc>()
                          .state
                          .requestState
                          .isLoading) {
                        return;
                      }
                      if (otpState.counter == 0) {
                        String phoneNumber = (state.phoneNumber.text.isNotEmpty
                            ? state.phoneNumber.text
                            : widget.phoneNumberText.text);

                        Methods.printLog(displayedCountryCode + phoneNumber);
                        if (phoneNumber.isEmpty) {
                          Methods.showToast(
                            context,
                            isError: true,
                            message: StringManager.pleaseInterYourPhone.tr(),
                          );
                          return;
                        }

                        context.read<SendCodeBloc>().add(
                              SendCodeEvent(
                                context: context,
                                parameter: SendCodeParameter(
                                  phone: '+$displayedCountryCode$phoneNumber',
                                  otpType: OtpType.register,
                                ),
                                isResend: true,
                              ),
                            );
                      }
                    },
                    child: context
                            .watch<SendCodeBloc>()
                            .state
                            .requestState
                            .isLoading
                        ? const LoadingWidget()
                        : otpState.counter == 0
                            ? TextWidget(
                                StringManager.getTheCode_.tr(),
                                style: context.bodySmall
                                    .size(15)
                                    .colorExt(ColorManager.primary),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextWidget(
                                    StringManager.resendCode.tr(),
                                    style: context.bodySmall.colorExt(
                                      ColorManager.textPrimary,
                                    ),
                                  ),
                                  Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: TextWidget(
                                      ' (${Methods.formattedTime(seconds: otpState.counter)})',
                                      style: context.bodyMedium
                                          .colorExt(ColorManager.textPrimary),
                                    ),
                                  ),
                                ],
                              ),
                  ),
                  10.hBox,
                  TextInputWidget(
                    border: OutlineInputBorder(
                      borderRadius: 30.radius,
                      borderSide: BorderSide(
                        width: 1.5,
                        color: ColorManager.grayLight.withValues(alpha: 0.7),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: 30.radius,
                      borderSide: BorderSide(
                        width: 1.5,
                        color: ColorManager.grayLight.withValues(alpha: 0.7),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: 30.radius,
                      borderSide: BorderSide(
                        width: 1.5,
                        color: ColorManager.grayLight.withValues(alpha: 0.7),
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: 30.radius,
                      borderSide: BorderSide(
                        width: 1.5,
                        color: ColorManager.grayLight.withValues(alpha: 0.7),
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: 30.radius,
                      borderSide: BorderSide(
                        width: 1.5,
                        color: ColorManager.grayLight.withValues(alpha: 0.7),
                      ),
                    ),
                    suffixColor: ColorManager.grey,
                    StringManager.password.tr(),
                    fillColor: ColorManager.grayLight.withValues(alpha: 0.7),
                    onChanged: (value) {
                      context
                          .read<RegisterBloc>()
                          .add(const ValidEventRegister());
                    },
                    suffixIcon: state.suffixIcon,
                    isPassword: state.isPassword,
                    controller: state.passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return StringManager.requiredField.tr();
                      }
                      return null;
                    },
                    onPressed: () {
                      context.read<RegisterBloc>().add(
                            const TogglePasswordVisibilityEvent(isFirst: true),
                          );
                    },
                  ),
                  20.hBox,
                  InkWell(
                    onDoubleTap: () {},
                    child: ButtonWidget(
                      title: StringManager.next.tr(),
                      height: 52.h,
                      radius: 30.r,
                      backgroundColor: state.isFormValid ?? false
                          ? ColorManager.primary
                          : Colors.grey.shade400,
                      isLoading: state.reqState.isLoading,
                      onPressed: () {
                        if (otpState.code.text.isNotEmpty) {
                          if (state.formKey.currentState?.validate() != false) {
                            if (state.reqState.isLoading) {
                              return;
                            } else {
                              di<OtpBloc>().add(
                                VerifyCodeOTPEvent(
                                  context: context,
                                  parameter: SendCodeParameter(
                                    otpType: OtpType.register,
                                    phone:
                                        '+$displayedCountryCode${state.phoneNumber.text.isEmpty == true ? widget.phoneNumberText.text : state.phoneNumber.text}',
                                    code: otpState.code.text,
                                    password: state.passwordController.text,
                                  ),
                                ),
                              );
                            }
                          }
                        } else {
                          Methods.showToast(context,
                              message: StringManager.getTheCode.tr(),
                              isError: true);
                        }
                      },
                    ),
                  ),
                  35.hBox,
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        context
                            .read<RecoverPasswordBloc>()
                            .add(ToggleErrorReasonsEvent());
                      },
                      child: TextWidget(
                        style: context.bodyMedium.colorExt(
                          ColorManager.secondaryText,
                        ),
                        StringManager.dontReceiveCode.tr(),
                      ),
                    ),
                  ),
                  10.hBox,
                  if (context
                      .watch<RecoverPasswordBloc>()
                      .state
                      .showErrorReasons)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextWidget(
                        style: context.bodyMedium.colorExt(ColorManager.secondaryText),
                        StringManager.reasonsCodeError.tr(),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
