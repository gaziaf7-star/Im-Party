part of 'package:general/src/features/auth/presentation/otp/view/otp_page.dart';

class _ConfirmCodeOTPBody extends StatelessWidget {
  const _ConfirmCodeOTPBody({required this.params});

  final SendCodeParameter params;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OtpBloc, OtpState>(
      bloc: di<OtpBloc>(),
      buildWhen: (prev, curr) => prev.reqState != curr.reqState,
      builder: (context_, state) => InkWell(
        child: ButtonWidget(
          title: StringManager.next.tr(),
          fontSize: 15.sp,
          height: 45.h,
          radius: 30.r,
          shadowColor: ColorManager.buleShadw,
          elevation: 6,
          backgroundColor: ColorManager.primary,
          width: double.infinity,
          isLoading: state.reqState.isLoading,
          onPressed: () => di<OtpBloc>().add(
            VerifyCodeOTPEvent(context: context, parameter: params),
          ),
        ),
      ),
    );
  }
}
