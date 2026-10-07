import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/register_dialog.dart';
import 'package:general/src/features/auth/auth.dart';

part 'components/form_auth_body.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(
        backgroundColor: Colors.white,
        shadow: Colors.transparent,
        iconColor: Colors.black,
        title: 'Login with Phone',
        titleStyle: context.titleLarge
            .size(18)
            .bold
            .colorExt(Colors.black),
      ),
      body: const SafeArea(
        top: false,
        child: _FormAuthBody(),
      ),
    );
  }
}
