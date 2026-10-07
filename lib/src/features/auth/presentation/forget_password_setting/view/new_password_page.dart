import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/presentation/forget_password_setting/reset_password/reset_password_bloc.dart';

part 'components/new_password_body.dart';

class NewRecoverPasswordPage extends StatelessWidget {
  final String code, phone;
  const NewRecoverPasswordPage({
    super.key,
    required this.code,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorManager.scaffoldBg,
      appBar:  AppBarWidget(
        backgroundColor: ColorManager.scaffoldBg,
        title: StringManager.createNewPassword.tr(),
      ),
      body: _NewRecoverPasswordBody(code: code, phone: phone),
    );
  }
}
