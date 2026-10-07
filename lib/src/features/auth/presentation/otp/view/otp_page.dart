import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/screen_background.dart';
import 'package:general/src/features/auth/auth.dart';

part 'components/confirm_code_otp_body.dart';

part 'components/form_code_body.dart';

class OtpPage extends StatelessWidget {
  final SendCodeParameter parameter;

  const OtpPage({super.key, required this.parameter});

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Scaffold(
        backgroundColor: ColorManager.scaffoldBg,
        appBar:  AppBarWidget(

                backgroundColor: ColorManager.transparent,
                titleStyle: context.bodyMedium.bold.copyWith(
                    color: ColorManager.primary, fontSize: 17.sp),
              ),
        body: Padding(
          padding: context.paddingSymmetric(horizontal: 20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Image.asset(
                scale: 7,
                fit: BoxFit.contain,
                AssetsManager.logo,
              ),
              10.hBox,
              TextWidget(
                StringManager.codeSent.tr(),
                style: context.bodyMedium.size(16).bold,

              ),

              15.hBox,
              RichText(
                textAlign: TextAlign.start,
                text: TextSpan(

                  children: [
                    TextSpan(
                      text:  StringManager.whatsappCheck.tr(),
                      style: context.bodyMedium
                          .size(16)
                          .colorExt(ColorManager.textPrimary)
                          .copyWith(),
                    ),
                    TextSpan(
                      text:parameter.phone,
                        style: context.bodyMedium
                            .size(16)
                            .colorExt(ColorManager.primary)
                            .copyWith(fontWeight: FontWeight.w900)
                    ),
                  ],
                ),
              ),
              30.hBox,
              _FormOtpBody(params: parameter),
              15.hBox,

              _ConfirmCodeOTPBody
                (params: parameter),
            ],
          ),
        ),
      ),
    );
  }
}
