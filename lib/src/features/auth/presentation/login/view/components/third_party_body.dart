

import 'package:general/src/features/auth/presentation/auth_platform/bloc/auth_platform_bloc.dart';

import '../../../../../../core/index.dart';

class ThirdPartyBody extends StatelessWidget {
  const ThirdPartyBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BlocBuilder<AuthPlatformBloc, AuthPlatformState>(
          bloc: di<AuthPlatformBloc>(),
          buildWhen: (prev, curr) => prev.requestStateGoogle != curr.requestStateGoogle,
          builder: (context, state) {
            return _SocialIconBtnWidget(
              onTap: () => di<AuthPlatformBloc>().add(SignInGoogleEvent(context: context)),
              icon: AssetsManager.google,
              size: 40,
              isLoading: state.requestStateGoogle.isLoading,
            );
          },
        ),
        //if (Platform.isIOS) ...[
          15.wBox,
          _SocialIconBtnWidget(onTap: () =>di<AuthPlatformBloc>().add(SignInAppleEvent(context: context)), icon: AssetsManager.apple),
       // ],
      ],
    );
  }
}

class _SocialIconBtnWidget extends StatelessWidget {
  const _SocialIconBtnWidget({
    required this.icon,
    required this.onTap,
    this.size,
    this.isLoading = false,
  });
  final String icon;
  final VoidCallback onTap;
  final double? size;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onTap,
      padding: context.paddingZero(),
      style: TextButton.styleFrom(
        minimumSize: Size(50.w, 50.h),
        backgroundColor: ColorManager.primary,
      ),
      icon: isLoading == true
          ? const LoadingWidget()
          : Image.asset(
              icon,
              height: size?.h ?? 27.5.h,
              width: size?.w ?? 27.5.w,
              color: ColorManager.white,
            ),
    );
  }
}
