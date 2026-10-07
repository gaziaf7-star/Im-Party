part of 'package:general/src/features/auth/presentation/recover_password_auth/view/new_password_page.dart';

class _NewPasswordBody extends StatelessWidget {
  final String code, phone;
  const _NewPasswordBody({required this.code, required this.phone});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RecoverPasswordBloc>();
    return BlocBuilder<RecoverPasswordBloc, RecoverPasswordState>(
      buildWhen: (prev, curr) => prev.suffixIcon != curr.suffixIcon || prev.isPassword != curr.isPassword || prev.confirmSuffixIcon != curr.confirmSuffixIcon || prev.isConfirmPassword != curr.isConfirmPassword || prev.reqStateCP != curr.reqStateCP,
      builder: (context, state) {
        return Form(
          key: state.formKeyCP,
          child: SingleChildScrollView(
            padding: context.paddingSymmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                40.hBox,
                TextInputWidget(
                  errorBorder: InputBorder.none,
                  border: const UnderlineInputBorder(
                    borderSide:
                    BorderSide(color: ColorManager.transparent),
                  ),
                  title: StringManager.password.tr(),

                  StringManager.password.tr(),
                  suffixIcon: state.suffixIcon,
                  controller: state.passwordCtrl,
                  isPassword: state.isPassword,

                  suffixColor: ColorManager.grey,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2 )),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),

                  // prefixIcon: Image.asset(AssetsManager.lockMall,fit: BoxFit.none,scale: 3.5,color: ColorManager.blodColor,),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return StringManager.requiredField.tr();
                    }
                    return null;
                  },
                  onPressed: () => bloc.add(const RecoverTogglePasswordEvent()),
                ),
                15.hBox,
                TextInputWidget(
                  border:  InputBorder.none,
                  errorBorder: InputBorder.none,

                  title: StringManager.confirmPassword.tr(),
                  StringManager.confirmPassword.tr(),
                  // prefixIcon: Image.asset(AssetsManager.lockMall,fit: BoxFit.none,scale: 3.5,color: ColorManager.blodColor,),
                  suffixColor: ColorManager.grey,
                  suffixIcon: state.confirmSuffixIcon,
                  controller: state.confirmPasswordCtrl,
                  isPassword: state.isConfirmPassword,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2 )),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return StringManager.requiredField.tr();
                    } else if (value != state.passwordCtrl.text) {
                      return StringManager.passwordsDoNotMatch.tr();
                    }
                    return null;
                  },
                  onPressed: () =>
                      bloc.add(const RecoverToggleConfirmPasswordEvent()),
                ),
                30.hBox,
                ButtonWidget(
                  height: 55.h,
                  backgroundColor: ColorManager.primary,
                  title: StringManager.next.tr(),
                  isLoading: state.reqStateCP.isLoading,
                  onPressed: () => bloc.add(
                    RecoverPasswordEvent(
                      code: code,
                      phone: phone,
                      context: context,
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
