import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

part 'components/new_password_body.dart';

class NewPasswordPage extends StatelessWidget {
  final String code, phone;

  const NewPasswordPage({
    super.key,
    required this.code,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.scaffoldBgAlt,
      appBar:  AppBarWidget(
        title: TextWidget(StringManager.forgotPassword.
        tr(),style: context.bodyLarge.size(18),
        ),
        backgroundColor: ColorManager.scaffoldBgAlt,
      ),
      body: _NewPasswordBody(code: code, phone: phone),
    );
  }
}
