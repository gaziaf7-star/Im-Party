import 'dart:io';
import 'dart:math' as math;
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/presentation/auth_platform/bloc/auth_platform_bloc.dart';
import 'package:general/src/core/widgets/update_dialog.dart';
import 'package:general/src/features/auth/presentation/splash/config_app/config_app_bloc.dart';

class Theme2IntroPage extends StatefulWidget {
  final String? error;
  const Theme2IntroPage({super.key, this.error});

  @override
  State<Theme2IntroPage> createState() => _Theme2IntroPageState();
}

class _Theme2IntroPageState extends State<Theme2IntroPage>
    with TickerProviderStateMixin {
  late final AnimationController _mainCtrl;
  final ValueNotifier<Offset> _parallaxOffset = ValueNotifier(Offset.zero);

  @override
  void initState() {
    super.initState();

    _mainCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);

    if (widget.error != null && (widget.error ?? '').isNotEmpty) {
      Future.delayed(
        const Duration(milliseconds: 800),
        () {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AnimatedDialog(
                title: StringManager.ban,
                description: widget.error ?? '',
                isHideConfirm: true,
              ),
            );
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _parallaxOffset.dispose();
    super.dispose();
  }

  void _onPointerMove(PointerEvent e, Size size) {
    final nx = ((e.position.dx / size.width) - 0.5).clamp(-0.5, 0.5);
    final ny = ((e.position.dy / size.height) - 0.5).clamp(-0.5, 0.5);
    _parallaxOffset.value = Offset(nx * 18, ny * 18);
  }

  Widget _emojiWidget({
    required String emoji,
    required double fontSize,
    required double offset,
    required double delay,
  }) {
    return AnimatedBuilder(
      animation: _mainCtrl,
      builder: (context, child) {
        final t =
            (math.sin((_mainCtrl.value * math.pi * 2) + delay) * 0.5) + 0.5;
        final dy = offset * t;
        final scale =
            1 + 0.04 * math.sin((_mainCtrl.value * math.pi * 2) + delay);
        return Transform.translate(
          offset: Offset(0, -dy),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: TextWidget(
        emoji,
        style: context.bodyMedium.copyWith(
          fontSize: fontSize,
          height: 1,
          color: ColorManager.onDark.withValues(alpha: 0.95),
          shadows: const [
            Shadow(blurRadius: 6, color: Colors.black26, offset: Offset(0, 3)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = ColorManager.primary;
    final hsl = HSLColor.fromColor(baseColor);

    final gradient = LinearGradient(
      begin: AlignmentDirectional.topStart,
      end: AlignmentDirectional.bottomEnd,
      colors: [
        hsl.withLightness((hsl.lightness + 0.05).clamp(0.0, 1.0)).toColor(),
        hsl.withLightness((hsl.lightness - 0.25).clamp(0.0, 1.0)).toColor(),
        hsl.withLightness((hsl.lightness - 0.35).clamp(0.0, 1.0)).toColor(),
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    final size = MediaQuery.sizeOf(context);

    return BlocListener<ConfigAppBloc, ConfigAppState>(
      bloc: di<ConfigAppBloc>(),
      listener: (context, state) {
        if (state.requestState.isLoaded) {
          if (state.config?.isLastVersion != true) {
            showDialog(
              context: context,
              barrierDismissible: !(state.config?.isForce ?? false),
              barrierColor: Colors.black.withValues(alpha: 0.5),
              builder: (_) => PopScope(
                canPop: false,
                onPopInvoked: (_) {},
                child: ForceUpdateDialog(
                  description: StringManager.updatDesc.tr(),
                  isOptionalUpdate: !(state.config?.isForce ?? false),
                  onConfirm: () {
                    Methods.openUrl(ConstantsManager.appURL);
                  },
                ),
              ),
            );
          }
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: gradient),
          child: Listener(
            onPointerHover: (e) => _onPointerMove(e, size),
            onPointerMove: (e) => _onPointerMove(e, size),
            child: Stack(
              children: [
                // ─── Animated Emoji Background ─────────────
                ValueListenableBuilder<Offset>(
                  valueListenable: _parallaxOffset,
                  builder: (context, offset, child) {
                    return Transform.translate(offset: offset, child: child);
                  },
                  child: Opacity(
                    opacity: 0.45,
                    child: Stack(
                      children: [
                        Positioned(
                          left: size.width * 0.040,
                          top: size.height * 0.080,
                          child: _emojiWidget(
                              emoji: '🎮',
                              fontSize: 70.h,
                              offset: 25,
                              delay: 0),
                        ),
                        Positioned(
                          left: size.width * 0.080,
                          top: size.height * 0.25,
                          child: _emojiWidget(
                              emoji: '😎',
                              fontSize: 45.h,
                              offset: 20,
                              delay: 1.2),
                        ),
                        Positioned(
                          right: size.width * 0.080,
                          top: size.height * 0.10,
                          child: _emojiWidget(
                              emoji: '📹',
                              fontSize: 50.h,
                              offset: 18,
                              delay: 2.4),
                        ),
                        Positioned(
                          right: size.width * 0.10,
                          top: size.height * 0.45,
                          child: _emojiWidget(
                              emoji: '💬',
                              fontSize: 50.h,
                              offset: 20,
                              delay: 0.9),
                        ),
                        Positioned(
                          right: size.width * 0.22,
                          bottom: size.height * 0.25,
                          child: _emojiWidget(
                              emoji: '🏆',
                              fontSize: 60.h,
                              offset: 28,
                              delay: 1.8),
                        ),
                        Positioned(
                          left: size.width * 0.070,
                          bottom: size.height * 0.180,
                          child: _emojiWidget(
                              emoji: '▶️',
                              fontSize: 50.h,
                              offset: 20,
                              delay: 0.9),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Content ───────────────────────────────
                Positioned.fill(
                  child: SafeArea(
                    child: Column(
                      children: [
                        16.hBox,

                        // ─── Logo + App Name ─────────────
                        Expanded(
                          flex: 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(24.r),
                                child: Image.asset(
                                  AssetsManager.logo,
                                  height: 110.h,
                                  width: 110.w,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              12.hBox,
                              TextWidget(
                                StringManager.appName,
                                style: context.bodyMedium.bold.size(28).colorExt(
                                      ColorManager.onDark,
                                    ),
                              ),
                              8.hBox,
                              TextWidget(
                                StringManager.playStreamConnect,
                                style:
                                    context.bodyMedium.w400.size(16).colorExt(
                                          ColorManager.onDark
                                              .withValues(alpha: 0.8),
                                        ),
                              ),
                            ],
                          ),
                        ),

                        // ─── Auth Buttons ────────────────
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 32.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Google button (main large button)
                                BlocBuilder<AuthPlatformBloc,
                                    AuthPlatformState>(
                                  bloc: di<AuthPlatformBloc>(),
                                  buildWhen: (prev, curr) =>
                                      prev.requestStateGoogle !=
                                      curr.requestStateGoogle,
                                  builder: (context, state) {
                                    return _mainAuthButton(
                                      icon: AssetsManager.google_,
                                      label: StringManager.signInWithGoogle,
                                      isLoading:
                                          state.requestStateGoogle.isLoading,
                                      onTap: () {
                                        di<AuthPlatformBloc>().add(
                                          SignInGoogleEvent(
                                            context: context,
                                            isAddAccount: false,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                                30.hBox,

                                // Bottom icon row: Phone + Apple + Huawei
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Phone login
                                    _circleAuthButton(
                                      icon: AssetsManager.phone,
                                      onTap: () => context
                                          .pushNamedRoute(Routes.login),
                                    ),
                                    if (Platform.isIOS) ...[
                                      24.wBox,
                                      // Apple login
                                      BlocBuilder<AuthPlatformBloc,
                                          AuthPlatformState>(
                                        bloc: di<AuthPlatformBloc>(),
                                        buildWhen: (prev, curr) =>
                                            prev.requestStateApple !=
                                            curr.requestStateApple,
                                        builder: (context, state) {
                                          return _circleAuthButton(
                                            icon: AssetsManager.apple,
                                            isLoading: state
                                                .requestStateApple.isLoading,
                                            onTap: () {
                                              di<AuthPlatformBloc>().add(
                                                SignInAppleEvent(
                                                  context: context,
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                    if (ConstantsManager.devicePlatform ==
                                        StringManager.huawei) ...[
                                      24.wBox,
                                      // Huawei login
                                      BlocBuilder<AuthPlatformBloc,
                                          AuthPlatformState>(
                                        bloc: di<AuthPlatformBloc>(),
                                        buildWhen: (prev, curr) =>
                                            prev.requestStateHuawei !=
                                            curr.requestStateHuawei,
                                        builder: (context, state) {
                                          return _circleAuthButton(
                                            icon: AssetsManager.huawei,
                                            isLoading: state
                                                .requestStateHuawei.isLoading,
                                            onTap: () {
                                              di<AuthPlatformBloc>().add(
                                                SignInHuaweiEvent(
                                                  context: context,
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ─── Terms & Privacy ─────────────
                        Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: GestureDetector(
                            onTap: () =>
                                context.pushNamedRoute(Routes.privacy),
                            child: Text.rich(
                              textAlign: TextAlign.center,
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: StringManager.bySigningUp.tr(),
                                  ),
                                  TextSpan(
                                    text:
                                        StringManager.termsOfService.tr(),
                                    style: const TextStyle(
                                      decoration:
                                          TextDecoration.underline,
                                      decorationColor: ColorManager.onDark,
                                    ),
                                  ),
                                  const TextSpan(text: ' • '),
                                  TextSpan(
                                    text:
                                        StringManager.privacyPolicy_.tr(),
                                    style: const TextStyle(
                                      decoration:
                                          TextDecoration.underline,
                                      decorationColor: ColorManager.onDark,
                                    ),
                                  ),
                                ],
                              ),
                              style: context.bodyMedium
                                  .size(12)
                                  .colorExt(ColorManager.onDark
                                      .withValues(alpha: 0.7)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mainAuthButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 56.h,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  height: 22.h,
                  width: 22.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ColorManager.primary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(icon, height: 24.h, width: 24.w),
                  10.wBox,
                  TextWidget(
                    label,
                    style: context.bodyMedium.w500
                        .size(15)
                        .colorExt(ColorManager.textPrimary),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _circleAuthButton({
    required String icon,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 56.h,
        width: 56.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ColorManager.white.withValues(alpha: 0.15),
          border: Border.all(
            color: ColorManager.white.withValues(alpha: 0.3),
          ),
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  height: 20.h,
                  width: 20.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ColorManager.white,
                  ),
                ),
              )
            : Center(
                child: Image.asset(icon, height: 28.h, width: 28.w),
              ),
      ),
    );
  }
}
