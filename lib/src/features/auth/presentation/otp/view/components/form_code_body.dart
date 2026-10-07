part of 'package:general/src/features/auth/presentation/otp/view/otp_page.dart';

class _FormOtpBody extends StatelessWidget {
  const _FormOtpBody({required this.params});

  final SendCodeParameter params;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OtpBloc, OtpState>(
      bloc: di<OtpBloc>(),
      buildWhen: (prev, curr) => prev.counter != curr.counter,
      builder: (context, state) {
        return Padding(
          padding: context.paddingSymmetric(horizontal: 20),
          child: Form(

            child: Column(
              children: [
                PinCodeTextFieldWidget(
                  onChanged: (value) {
                    di<OtpBloc>().add(FetchCodeOTPEvent(codeOTP: value));
                  },
                ),
                15.hBox,
                Align(
                  alignment: AlignmentDirectional.center,
                  child: TextButton(
                    onPressed: state.counter == 0
                        ? () => context.read<SendCodeBloc>().add(
                              SendCodeEvent(
                                context: context,
                                parameter: params,
                                isResend: true,
                              ),
                            )
                        : null,
                    child: context
                            .watch<SendCodeBloc>()
                            .state
                            .requestState
                            .isLoading
                        ? const LoadingWidget()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextWidget(
                                StringManager.resendCode.tr(),
                                style:
                                    context.bodyMedium.colorExt(ColorManager.textPrimary),
                              ),
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: TextWidget(
                                  (state.counter == 0
                                      ? ' (00 : 00)'
                                      : ' (${Methods.formattedTime(seconds: state.counter)})'),
                                  style:
                                      context.bodyMedium.colorExt(ColorManager.textPrimary),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
