part of 'package:general/src/features/auth/presentation/forget_password_setting/view/new_password_page.dart';

class _NewRecoverPasswordBody extends StatelessWidget {
  final String code, phone;
  const _NewRecoverPasswordBody({required this.code, required this.phone});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ResetPasswordBloc>();
    return BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
      buildWhen: (prev, curr) => prev.suffixIcon != curr.suffixIcon || prev.isPassword != curr.isPassword || prev.confirmSuffixIcon != curr.confirmSuffixIcon || prev.isConfirmPassword != curr.isConfirmPassword || prev.reqStateCP != curr.reqStateCP,
      builder: (context, state) {
        return Form(
          key: state.formKeyCP,
          child: Padding(
            padding: context.paddingSymmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                10.hBox,
                Image.asset(
                  scale: 7,
                  fit: BoxFit.contain,
                  AssetsManager.logo,
                ),
                10.hBox,
                TextWidget(StringManager.createNewPassword.tr(),
                    style: context.bodyMedium.size(24).bold),
                const SizedBox(height: 5),
                TextWidget(StringManager.createNewPasswordSubtitle.tr(),
                    style: context.bodyMedium.size(16).colorExt(ColorManager.textPrimary)),
                20.hBox,
                TextInputWidget(
                  fillColor: ColorManager.grayLight.withValues(alpha: 0.7),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: 20.radius,
                    borderSide: BorderSide(
                      width: 1.5,
                      color: ColorManager.grayLight.withValues(alpha: 0.7),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: 30.radius,
                    borderSide: BorderSide(
                      width: 1.5,
                      color: ColorManager.grayLight.withValues(alpha: 0.7),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: 30.radius,
                    borderSide: BorderSide(
                      width: 1.5,
                      color: ColorManager.redAccount.withValues(alpha: 0.7),
                    ),
                  ),
                  errorBorder: InputBorder.none,
                  title: StringManager.password.tr(),
                  suffixIcon: state.suffixIcon,
                  StringManager.password.tr(),
                  suffixColor: ColorManager.grey,
                  controller: state.passwordCtrl,
                  isPassword: state.isPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return StringManager.requiredField.tr();
                    }
                    return null;
                  },
                  onPressed: () =>
                      bloc.add(const RecoverPasswordTogglePassword1Event()),
                ),
                15.hBox,
                TextInputWidget(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: 20.radius,
                    borderSide: BorderSide(
                      width: 1.5,
                      color: ColorManager.grayLight.withValues(alpha: 0.7),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: 30.radius,
                    borderSide: BorderSide(
                      width: 1.5,
                      color: ColorManager.grayLight.withValues(alpha: 0.7),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: 30.radius,
                    borderSide: BorderSide(
                      width: 1.5,
                      color: ColorManager.redAccount.withValues(alpha: 0.7),
                    ),
                  ),
                  errorBorder: InputBorder.none,
                  suffixIcon: state.confirmSuffixIcon,
                  suffixColor: ColorManager.grey,
                  fillColor: ColorManager.grayLight.withValues(alpha: 0.7),
                  StringManager.confirmPassword.tr(),
                  title: StringManager.confirmPassword.tr(),
                  controller: state.confirmPasswordCtrl,
                  isPassword: state.isConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return StringManager.requiredField.tr();
                    } else if (value != state.passwordCtrl.text) {
                      return StringManager.passwordsDoNotMatch.tr();
                    }
                    return null;
                  },
                  onPressed: () =>
                      bloc.add(const RecoverPasswordTogglePassword2Event()),
                ),
                Padding(
                  padding: context.paddingOnly(start: 20, end: 20, top: 30),
                  child: ButtonWidget(
                    backgroundColor: ColorManager.primary,
                    height: 45.h,
                    radius: 20.r,
                    title: StringManager.next.tr(),
                    isLoading: state.reqStateCP.isLoading,
                    onPressed: () {
                      if (state.formKeyCP.currentState?.validate() == false) {
                        return;
                      }else{
                        showDialog(
                          context: context,
                          builder: (context) => AnimatedDialog(
                            title: StringManager.warning.tr(),
                            description: StringManager.needToExitFromOther.tr(),
                            conText: StringManager.yes.tr(),
                            cancelText: StringManager.no.tr(),
                            onTapCancel: () async {

                              bloc.add(
                                RecoverPasswordEvent(
                                    codeOtp: code,
                                    number: phone,
                                    context: context,
                                    type: '0'),
                              );
                            },
                            onTap: () async {
                              bloc.add(
                                RecoverPasswordEvent(
                                    codeOtp: code,
                                    number: phone,
                                    context: context,
                                    type: '1'),
                              );
                            },
                          ),
                        );
                      }

                    },
                  ),
                ),
                50.hBox
              ],
            ),
          ),
        );
      },
    );
  }
}
