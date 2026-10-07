import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/setting/presentation/account_setting/bind_number/bind_number_bloc.dart';

part '../page/bind_number_body.dart';

class BindNumberScreen extends StatelessWidget {
  const BindNumberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBarWidget(
        title: "",
        titleStyle: context.bodyMedium.bold.copyWith(fontSize: 17.sp),
        backgroundColor: ColorManager.transparent,
      ),
      body: const _BindNumberBody(),
    );
  }
}
