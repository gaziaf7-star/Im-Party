part of 'package:general/src/features/setting/presentation/account_setting/view/page/bind_number_screen.dart';

class _BindNumberBody extends StatelessWidget {
  const _BindNumberBody();

  void _openCountryPicker(BuildContext context) {
    showCountryPicker(
      context: context,
      showSearch: true,
      countryListTheme: const CountryListThemeData(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        padding: EdgeInsets.only(top: 10),
      ),
      showPhoneCode: true,
      onSelect: (Country country) {
        context.read<AccountBloc>().add(ChangeCountryBindPhone(country));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      buildWhen: (prev, curr) => prev.formKey != curr.formKey || prev.phoneControllerNew != curr.phoneControllerNew || prev.selectedCountry != curr.selectedCountry || prev.passwordController != curr.passwordController || prev.suffixIcon != curr.suffixIcon || prev.isPassword != curr.isPassword,
      builder: (__, state) {
        return SingleChildScrollView(
          child: SizedBox(
            height: ScreenUtil().screenHeight,
            width: ScreenUtil().screenWidth,
            child: Padding(
              padding: context.paddingSymmetric(horizontal: 20.w),
              child: Form(
                key: state.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    15.hBox,
                    Image.asset(
                      scale: 7,
                      fit: BoxFit.contain,
                      AssetsManager.logo,
                    ),
                    10.hBox,
                    TextWidget(
                      StringManager.bindPhone.tr(),
                      style: context.bodyLarge.bold
                          .colorExt(ColorManager.textPrimary),
                    ),
                    15.hBox,
                    TextWidget(
                      StringManager.addYourPhone.tr(),
                      style:
                          context.bodyMedium.colorExt(ColorManager.textPrimary),
                    ),
                    15.hBox,
                    TextInputWidget(
                      StringManager.phoneNum.tr(),
                      contentPadding: EdgeInsets.zero,
                      keyboardType: TextInputType.phone,
                      controller: state.phoneControllerNew,
                      prefixIcon: TextButton(
                        onPressed: () => _openCountryPicker(context),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextWidget(
                              " ${state.selectedCountry?.name ?? 'UAE'} (+${state.selectedCountry?.phoneCode ?? "971"})",
                              style: context.bodyMedium.size(16),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey,
                            ),
                            Expanded(
                              child: TextInputWidget(
                                border: InputBorder.none,
                                StringManager.phoneNum.tr(),
                                contentPadding: EdgeInsets.zero,
                                keyboardType: TextInputType.phone,
                                controller: state.phoneControllerNew,

                                textColor: ColorManager.textPrimary,

                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                // controller: state.phoneControllerNew,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return StringManager.requiredField.tr();
                                  }
                                  if (!Methods().isValidPhoneNumber(
                                      state.selectedCountry?.countryCode ??
                                          "SA",
                                      value)) {
                                    return StringManager.phoneValidator.tr();
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      textColor: ColorManager.textPrimary,
                      fillColor: ColorManager.gray.withValues(alpha: (0.2)),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: 30.radius,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: 30.radius,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: 30.radius,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: 30.radius,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: 30.radius,
                      ),

                      // controller: state.phoneControllerNew,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return StringManager.requiredField.tr();
                        }
                        if (!Methods().isValidPhoneNumber(
                            state.selectedCountry?.countryCode ?? "SA",
                            value)) {
                          return StringManager.phoneValidator.tr();
                        }
                        return null;
                      },
                    ),
                    10.hBox,
                    TextInputWidget(
                      StringManager.password.tr(),
                      title: StringManager.password.tr(),
                      controller: state.passwordController,
                      suffixIcon: state.suffixIcon,
                      suffixColor: ColorManager.textPrimary,
                      isPassword: state.isPassword,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: 30.radius,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: 30.radius,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: 30.radius,
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: 30.radius,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: 30.radius,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return StringManager.requiredField.tr();
                        }
                        return null;
                      },
                      onPressed: () => context
                          .read<AccountBloc>()
                          .add(const TogglePasswordBindEvent()),
                      fillColor: ColorManager.gray.withValues(alpha: (0.2)),
                    ),
                    10.hBox,
                    TextWidget(
                      StringManager.conferm.tr(),
                      style: context.bodyLarge.w500
                          .colorExt(ColorManager.textPrimary)
                          .size(12),
                    ),
                    const Spacer(
                      flex: 4,
                    ),
                    BlocConsumer<SendCodeBloc, SendCodeState>(
                      listener: (context, __) {
                        if (__.requestState == RequestState.loaded) {
                          context.pushNamedRoute(
                            Routes.otp,
                            arguments: SendCodeParameter(
                              isDifferent: false,
                              code: di<OtpBloc>().state.code.text,
                              password: state.passwordController.text,
                              phone:
                                  '+${state.selectedCountry?.phoneCode ?? '971'}${state.phoneControllerNew.text}',
                              otpType: OtpType.bindAccount,
                            ),
                          );
                        }
                      },
                      builder: (context, state_) {
                        return Padding(
                          padding: context.paddingSymmetric(
                              horizontal: 20, vertical: 40),
                          child: ButtonWidget(
                            title: StringManager.next.tr(),
                            isLoading: state_.requestState.isLoading,
                            onPressed: () {
                              if (state.formKey.currentState?.validate() ==
                                  false) {
                                return;
                              }
                              context.read<SendCodeBloc>().add(
                                    SendCodeEvent(
                                      context: context,
                                      parameter: SendCodeParameter(
                                        isDifferent: true,
                                        password: state.passwordController.text,
                                        phone:
                                            '+${state.selectedCountry?.phoneCode ?? '971'}${state.phoneControllerNew.text}',
                                        otpType: OtpType.bindAccount,
                                      ),
                                    ),
                                  );
                            },
                          ),
                        );
                      },
                    ),
                    const Spacer()
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
