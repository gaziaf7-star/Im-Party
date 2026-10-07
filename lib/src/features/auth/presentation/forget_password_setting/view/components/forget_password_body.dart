/*
part of 'package:general/src/features/auth/presentation/forget_password_setting/view/forget_password_page.dart';

class _RecoverPasswordBody extends StatelessWidget {
  const _RecoverPasswordBody();

  @override
  Widget build(BuildContext context) {
    return BackgroundWidgetGradient(
      child: BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
        builder: (__, state) {
          return Padding(
            padding: context.paddingSymmetric(horizontal: 20.w),
            child: Form(
              key: state.formKeyRP,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    scale: 6,
                    fit: BoxFit.contain,
                    AssetsManager.logo,

                  ),
                  30.hBox,
                  PhoneFormFieldWidget(
                    hintText: '',
                    title: StringManager.whatsapp.tr(),
                    phoneController: state.phoneController,
                    onChanged: (value) => context.read<ResetPasswordBloc>().add(
                          RecoverPasswordFetchPhoneEvent(
                            phone: value,
                            validatePhoneNumber: value.isValid(),
                          ),
                        ),
                  ),
                  10.hBox,
                  TextWidget(
                    StringManager.conferm,
                    style: context.bodyLarge.w500
                        .colorExt(ColorManager.textPrimary)
                        .size(12),
                  ),
                  const Spacer(),
                  BlocBuilder<SendCodeBloc, SendCodeState>(
                    builder: (context, state_) {
                      return Padding(
                        padding: context.paddingSymmetric(
                            horizontal: 20, vertical: 40),
                        child: ButtonWidget(
                          height: 55.h,

                          title: StringManager.next.tr(),
                          isLoading: state_.requestState.isLoading,
                          onPressed: () {
                            if (state.formKeyRP.currentState?.validate() ==
                                false) {
                              return;
                            }
                            context.read<SendCodeBloc>().add(
                                  SendCodeEvent(
                                    context: context,
                                    parameter: SendCodeParameter(
                                      isDifferent: false,
                                      phone: state
                                          .phoneController.value.international,
                                      otpType: OtpType.passwordChange,
                                    ),
                                  ),
                                );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
*/
