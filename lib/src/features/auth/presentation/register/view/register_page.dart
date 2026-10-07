import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

part 'components/form_auth_body.dart';

class RegisterPage extends StatelessWidget {
  final String countryName;
  final String countryCode;
  final TextEditingController phoneNumber;

  const RegisterPage(
      {super.key,
      required this.countryName,
      required this.countryCode,
      required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          bool exit = await showExitDialog(context, false);
          if (exit && context.mounted) {
            Navigator.of(context).pop();
            context.read<OtpBloc>().resetTimerCounter();
          }
        });
      },
      child: Scaffold(
        backgroundColor: ColorManager.scaffoldBg,
        appBar: AppBarWidget(
          onLeadingPressed: () async {
            bool exit = await showExitDialog(context, false);
            if (exit) {
              Navigator.pop(context);
              context.read<OtpBloc>().resetTimerCounter();
            }
          },
          title: StringManager.registration.tr(),
          backgroundColor: ColorManager.scaffoldBg,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: context.paddingOnly(start: 15, end: 15),
            child: _FormAuthBody(
              countryName: countryName,
              countryCode: countryCode,
              phoneNumberText: phoneNumber,
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool> showExitDialog(BuildContext context, bool? isResatPass) async {
  return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          title: TextWidget(
            isResatPass ?? false
                ? StringManager.exitDialogForgetPass.tr()
                : StringManager.exitDialogTitle.tr(),
            style:
                context.bodyMedium.size(15).colorExt(ColorManager.textPrimary).w500,
          ),
          actions: [
            ButtonWidget(
                backgroundColor: ColorManager.primary,
                title: TextWidget(
                  StringManager.thinkAgain.tr(),
                  style: context.bodyMedium.colorExt(ColorManager.textPrimary),
                ),
                onPressed: () => Navigator.of(context).pop(false)),
            20.hBox,
            ButtonWidget(
                backgroundColor: ColorManager.scaffoldBg,
                borderColor: ColorManager.primary,
                title: TextWidget(
                  isResatPass ?? false
                      ? StringManager.giveUpResat
                      : StringManager.giveUpRegistering.tr(),
                  style: context.bodyMedium.colorExt(ColorManager.primary),
                ),
                onPressed: () => Navigator.maybeOf(context)?.pop(true)),
          ],
        ),
      ) ??
      false; // Default to false if dialog is dismissed
}
