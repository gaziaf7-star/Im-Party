part of 'package:general/src/features/auth/presentation/recover_password_auth/view/recover_password_page.dart';

class _RecoverPasswordBody extends StatelessWidget {
  const _RecoverPasswordBody();

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
      showPhoneCode: true,
      onSelect: (Country country) {
        context
            .read<RecoverPasswordBloc>()
            .add(ChangeCountryRecoverEvent(country));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecoverPasswordBloc, RecoverPasswordState>(
      buildWhen: (prev, curr) =>
          prev.selectedCountry != curr.selectedCountry ||
          prev.isPhoneEmpty != curr.isPhoneEmpty ||
          prev.isFormValid != curr.isFormValid,
      builder: (context, state) {
        return BlocBuilder<OtpBloc, OtpState>(
          buildWhen: (prev, curr) =>
              prev.counter != curr.counter || prev.reqState != curr.reqState,
          builder: (context, __) {
            return Padding(
              padding: context.paddingSymmetric(horizontal: 20),
              child: Form(
                key: state.formKeyRP,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    30.hBox,
                    GestureDetector(
                      onTap: () => _openCountryPicker(context),
                      child: Container(
                        decoration: BoxDecoration(
                            color: ColorManager.grayLight,
                            borderRadius: 20.radius),
                        child: Row(
                          children: [
                            10.wBox,
                            TextWidget(
                              " ${state.selectedCountry?.name ?? 'UAE'}${state.selectedCountry?.phoneCode ?? "+971"}",
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
                                border: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: ColorManager.transparent),
                                ),
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                StringManager.phoneNum.tr(),
                                contentPadding: EdgeInsets.zero,
                                keyboardType: TextInputType.phone,
                                controller: state.phoneControllerNew,
                                onChanged: (value) {
                                  context
                                      .read<RecoverPasswordBloc>()
                                      .add(const IsPhoneEmptyEvent());
                                },
                                textColor: ColorManager.textPrimary,

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
                    ),
                    25.hBox,
                    Container(
                      decoration: BoxDecoration(
                        color: ColorManager.grayLight.withValues(alpha: 0.8),
                        borderRadius: 20.radius,
                      ),
                      child: TextInputWidget(
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        border: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: ColorManager.transparent),
                        ),
                        StringManager.code.tr(),
                        onChanged: (value) {
                          di<OtpBloc>().add(
                              FetchCodeOTPEvent(codeOTP: value.toString()));
                          context
                              .read<RecoverPasswordBloc>()
                              .add(const ValidaEvent());
                        },
                        maxLength: 6,
                        keyboardType: TextInputType.phone,
                        contentPadding: context.paddingSymmetric(
                            vertical: 15, horizontal: 10),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return StringManager.requiredField.tr();
                          }
                          return null;
                        },
                        onPressed: () => context
                            .read<LoginBloc>()
                            .add(const TogglePasswordEvent()),
                      ),
                    ),
                    AbsorbPointer(
                      absorbing: state.isPhoneEmpty == true ? false : true,
                      child: TextButton(
                        style: TextButton.styleFrom(
                            padding: context.paddingZero(),
                            textStyle: context.bodySmall.size(10)),
                        onPressed: __.counter == 0
                            ? () {
                                if (state.phoneControllerNew.text.isEmpty) {
                                  return Methods.showToast(context,
                                      isError: true,
                                      message: StringManager
                                          .pleaseInterYourPhone
                                          .tr());
                                }
                                context.read<SendCodeBloc>().add(
                                      SendCodeEvent(
                                        context: context,
                                        parameter: SendCodeParameter(
                                          phone:
                                              '+${state.selectedCountry?.phoneCode ?? '971'}${state.phoneControllerNew.text}',
                                          otpType: OtpType.resetPassword,
                                        ),
                                        isResend: true,
                                      ),
                                    );
                              }
                            : null,
                        child: context
                                .watch<SendCodeBloc>()
                                .state
                                .requestState
                                .isLoading
                            ? const LoadingWidget()
                            : __.counter == 0
                                ? TextWidget(
                                    StringManager.getTheCode_.tr(),
                                    style: context.bodySmall.colorExt(
                                        state.isPhoneEmpty
                                            ? ColorManager.primary
                                            : ColorManager.textPrimary),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextWidget(
                                        StringManager.resendCode.tr(),
                                        style: context.bodySmall
                                            .colorExt(ColorManager.textPrimary),
                                      ),
                                      Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: TextWidget(
                                          (' (${Methods.formattedTime(seconds: __.counter)})'),
                                          style: context.bodyMedium.colorExt(
                                              ColorManager.textPrimary),
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                    AbsorbPointer(
                      absorbing: state.isFormValid == true ? false : true,
                      child: ButtonWidget(
                        title: StringManager.next.tr(),
                        fontSize: 15.sp,
                        height: 48.h,
                        radius: 30.r,
                        backgroundColor: state.isFormValid ?? false
                            ? ColorManager.primary
                            : Colors.grey.shade400,
                        width: double.infinity,
                        isLoading: __.reqState.isLoading,
                        onPressed: () {
                          if (state.formKeyRP.currentState?.validate() ==
                              false) {
                            return Methods.showToast(context,
                                isError: true, message: StringManager.cpr.tr());
                          }
                          di<OtpBloc>().add(
                            VerifyCodeOTPEvent(
                                context: context,
                                parameter: SendCodeParameter(
                                  otpType: OtpType.resetPassword,
                                  phone:
                                      '+${state.selectedCountry?.phoneCode ?? '971'}${state.phoneControllerNew.text}',
                                  code: __.code.text,
                                )),
                          );
                        },
                      ),
                    ),
                    15.hBox,
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          context
                              .read<RecoverPasswordBloc>()
                              .add(ToggleErrorReasonsEvent());
                        },
                        child: TextWidget(
                          style: context.bodyMedium.colorExt(ColorManager.secondaryText),
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
                    20.hBox,
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
