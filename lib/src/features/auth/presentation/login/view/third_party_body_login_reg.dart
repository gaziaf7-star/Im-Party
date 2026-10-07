import 'dart:io';

import 'package:general/src/features/auth/presentation/auth_platform/bloc/auth_platform_bloc.dart';

import '../../../../../core/index.dart';

class ThirdPartyBodyLoginRegister extends StatelessWidget {
  const ThirdPartyBodyLoginRegister({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingSymmetric(
        horizontal: 30.w,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BlocBuilder<AuthPlatformBloc, AuthPlatformState>(
            bloc: di<AuthPlatformBloc>(),
            buildWhen: (prev, curr) => prev.requestStateGoogle != curr.requestStateGoogle,
            builder: (context, state) {
              return GoogleAppleButton(
                isLoading: state.requestStateGoogle.isLoading,
                onPressed: () {
                  di<AuthPlatformBloc>()
                      .add(SignInGoogleEvent(context: context));
                },

                image: AssetsManager.google,
              );
            },
          ),
          if (Platform.isIOS) ...[
            15.wBox,
         GoogleAppleButton(
          isLoading:  di<AuthPlatformBloc>().state.requestStateGoogle.isLoading,
          onPressed: () {
            di<AuthPlatformBloc>()
                .add(SignInAppleEvent(context: context));
          },

          image: AssetsManager.apple,
        )
          ],
        ],
      ),
    );
  }
}

class GoogleAppleButton extends StatelessWidget {
  const GoogleAppleButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    required this.image,
  });
  final void Function()? onPressed;
  final bool isLoading;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,

          backgroundColor: Colors.white,
          shadowColor: ColorManager.transparent,
          padding: context.paddingZero(),
          maximumSize: Size(double.infinity, 50.h),

        ),
        child:isLoading == true
            ? LoadingWidget(
          color: ColorManager.primary,
        ): Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            image,
            scale: 3.8,
          ),
        ),
      ),
    );
  }
}
