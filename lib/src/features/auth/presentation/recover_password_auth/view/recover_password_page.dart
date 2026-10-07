import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

part 'components/recover_password_body.dart';

class RecoverPasswordPage extends StatelessWidget {
  const RecoverPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          bool exit = await showExitDialog(context, true);
          if (exit && context.mounted) {
            Navigator.of(context).pop();
          }
        });
      },
      child: Scaffold(
        backgroundColor: ColorManager.scaffoldBg,
        appBar: AppBarWidget(
          onLeadingPressed: () async {
            bool exit = await showExitDialog(context, true);
            if (exit) {
              Navigator.pop(context);
              Navigator.pop(context);
            }
          },
          backgroundColor: ColorManager.scaffoldBg,
          title: TextWidget(
            StringManager.receiveCode.tr(),
            style: context.bodyLarge.bold
                .colorExt(ColorManager.textColorMain)
                .copyWith(fontSize: 21.sp),
          ),
        ),
        body: const SingleChildScrollView(
          child: _RecoverPasswordBody(),
        ),
      ),
    );
  }
}
