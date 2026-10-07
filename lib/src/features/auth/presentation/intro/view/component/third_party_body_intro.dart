import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/presentation/auth_platform/bloc/auth_platform_bloc.dart';

class ThirdPartyBodyIntro extends StatelessWidget {
  final bool isAddAccount;
  const ThirdPartyBodyIntro({super.key, required this.isAddAccount});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BlocBuilder<AuthPlatformBloc, AuthPlatformState>(
          bloc: di<AuthPlatformBloc>(),
          buildWhen: (prev, curr) => prev.requestStateGoogle != curr.requestStateGoogle,
          builder: (context, state) {
            return _ThirdButtonBody(
              isLoading: state.requestStateGoogle.isLoading,
              onPressed: () {
                di<AuthPlatformBloc>().add(
                  SignInGoogleEvent(
                    context: context,
                    isAddAccount: isAddAccount,
                  ),
                );
              },
            );
          },
        ),
        if (ConstantsManager.devicePlatform == StringManager.huawei) ...[
          15.hBox,
          BlocBuilder<AuthPlatformBloc, AuthPlatformState>(
            bloc: di<AuthPlatformBloc>(),
            buildWhen: (prev, curr) => prev.requestStateHuawei != curr.requestStateHuawei,
            builder: (context, state) {
              return _ThirdButtonBody(
                title: StringManager.continueHuawei.tr(),
                image: AssetsManager.huawei,
                isLoading: state.requestStateHuawei.isLoading,
                onPressed: () {
                  di<AuthPlatformBloc>()
                      .add(SignInHuaweiEvent(context: context));
                },
              );
            },
          ),
        ],
        if (ConstantsManager.devicePlatform == StringManager.ios) ...[
          15.hBox,
          BlocBuilder<AuthPlatformBloc, AuthPlatformState>(
            bloc: di<AuthPlatformBloc>(),
            buildWhen: (prev, curr) => prev.requestStateApple != curr.requestStateApple,
            builder: (context, state) {
              return _ThirdButtonBody(
                title: StringManager.signInWithApple.tr(),
                image: AssetsManager.apple,
                isLoading: state.requestStateApple.isLoading,
                onPressed: () {
                  di<AuthPlatformBloc>()
                      .add(SignInAppleEvent(context: context));
                },
              );
            },
          ),
        ],
      ],
    );
  }
}

class _ThirdButtonBody extends StatelessWidget {
  const _ThirdButtonBody({
    required this.onPressed,
    this.isLoading = false,
    this.title,
    this.image,
  });
  final void Function() onPressed;
  final bool isLoading;
  final String? title, image;

  @override
  Widget build(BuildContext context) {
    return ButtonWidget(
      shadowColor: ColorManager.transparent,
      elevation: 0,
      radius: 60.r,
      height: 55,
      isLoading: isLoading,
      onPressed: onPressed,
      cLoadingColor: ColorManager.primary,
      width: ScreenUtil().screenWidth,
      padding: EdgeInsets.zero,
      paddingButton: EdgeInsets.zero,
      title: SizedBox(
        width: 280.w,
        child: Row(
          children: [
            5.wBox,
            Image.asset(
              height: 38.5.h,
              width: 38.5.w,
              image ?? AssetsManager.google_,
            ),
            const Spacer(),
            TextWidget(
              title ?? StringManager.signInWithGoogle.tr(),
              style: context.bodyMedium.w400
                  .colorExt(ColorManager.textPrimary)
                  .copyWith(fontSize: 16.sp),
            ),
            const Spacer(flex: 4),
          ],
        ),
      ),
      backgroundColor: ColorManager.scaffoldBg,
    );
  }
}
