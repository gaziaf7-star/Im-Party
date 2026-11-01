import 'dart:io';

import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/app_update_prompt.dart';
import 'package:general/src/features/auth/presentation/auth_platform/bloc/auth_platform_bloc.dart';
import 'package:general/src/features/auth/presentation/splash/config_app/config_app_bloc.dart';
import 'package:general/src/features/setting/setting.dart';

class IntroPage extends StatefulWidget {
  final String? error;

  const IntroPage({super.key, this.error});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  bool _isAgreementAccepted = false;

  static const List<Map<String, String>> _supportedLanguages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'ar', 'name': 'العربية'},
    {'code': 'tr', 'name': 'Türkçe'},
    {'code': 'ur', 'name': 'اردو'},
    {'code': 'hi', 'name': 'हिन्दी'},
    {'code': 'id', 'name': 'Bahasa Indonesia'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppUpdatePrompt.showIfNeeded(context, di<ConfigAppBloc>().state);
      }
    });


    if (widget.error != null && (widget.error ?? '').isNotEmpty) {
      Future.delayed(
        const Duration(milliseconds: 800),
            () {
          if (!mounted) return;
          showDialog(
            context: context,
            builder: (context) => AnimatedDialog(
              title: StringManager.ban,
              description: widget.error ?? '',
              isHideConfirm: true,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConfigAppBloc, ConfigAppState>(
      bloc: di<ConfigAppBloc>(),
      listener: (context, state) =>
          AppUpdatePrompt.showIfNeeded(context, state),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Full-bleed brand wallpaper behind the whole welcome/login
            // screen, matching the reference design.
            Positioned.fill(
              child: Image.asset(
                AssetsManager.messageBackground,
                fit: BoxFit.cover,
              ),
            ),
            // Scrim: darker over the hero (logo/language picker) fading to
            // solid white by the button section, so the sign-in buttons,
            // agreement text and phone-login CTA stay fully legible.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.42),
                      Colors.white.withValues(alpha: 0.20),
                      Colors.white,
                    ],
                    stops: const [0.0, 0.34, 0.58],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  final screenHeight = constraints.maxHeight;

                  final horizontalPadding =
                  (screenWidth * 0.075).clamp(22.0, 44.0);
                  final heroTopGap =
                  (screenHeight * 0.125).clamp(68.0, 135.0);
                  final logoSize = (screenWidth * 0.28).clamp(96.0, 140.0);
                  final heroBottomGap =
                  (screenHeight * 0.072).clamp(38.0, 68.0);
                  final buttonHeight =
                  (screenHeight * 0.062).clamp(48.0, 55.0);
                  final buttonGap =
                  (screenHeight * 0.016).clamp(10.0, 16.0);

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: screenHeight),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 14),

                            Align(
                              alignment: AlignmentDirectional.topEnd,
                              child: _languageButton(context),
                            ),

                            SizedBox(height: heroTopGap),

                            Image.asset(
                              AssetsManager.logo,
                              width: logoSize,
                              height: logoSize,
                              fit: BoxFit.contain,
                            ),

                            SizedBox(height: heroBottomGap),

                            BlocBuilder<AuthPlatformBloc, AuthPlatformState>(
                              bloc: di<AuthPlatformBloc>(),
                              buildWhen: (prev, curr) =>
                              prev.requestStateGoogle !=
                                  curr.requestStateGoogle,
                              builder: (context, state) {
                                return _referenceButton(
                                  iconAsset: AssetsManager.google_,
                                  label: StringManager.signInWithGoogle.tr(),
                                  height: buttonHeight,
                                  iconSize: 28,
                                  gradient: _googleGradient,
                                  shadowColor: const Color(0xFF5204C6),
                                  enabled: _isAgreementAccepted,
                                  isLoading: state.requestStateGoogle.isLoading,
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

                            if (ConstantsManager.devicePlatform ==
                                StringManager.huawei) ...[
                              SizedBox(height: buttonGap),
                              BlocBuilder<AuthPlatformBloc, AuthPlatformState>(
                                bloc: di<AuthPlatformBloc>(),
                                buildWhen: (prev, curr) =>
                                prev.requestStateHuawei !=
                                    curr.requestStateHuawei,
                                builder: (context, state) {
                                  return _referenceButton(
                                    iconAsset: AssetsManager.huawei,
                                    label: StringManager.signInWithHuawei.tr(),
                                    height: buttonHeight,
                                    iconSize: 28,
                                    gradient: _huaweiGradient,
                                    shadowColor: const Color(0xFF2A6DFF),
                                    enabled: _isAgreementAccepted,
                                    isLoading: state.requestStateHuawei.isLoading,
                                    onTap: () {
                                      di<AuthPlatformBloc>().add(
                                        SignInHuaweiEvent(context: context),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],

                            if (Platform.isIOS) ...[
                              SizedBox(height: buttonGap),
                              BlocBuilder<AuthPlatformBloc, AuthPlatformState>(
                                bloc: di<AuthPlatformBloc>(),
                                buildWhen: (prev, curr) =>
                                prev.requestStateApple !=
                                    curr.requestStateApple,
                                builder: (context, state) {
                                  return _referenceButton(
                                    iconAsset: AssetsManager.apple,
                                    label: StringManager.signInWithApple.tr(),
                                    height: buttonHeight,
                                    iconSize: 27,
                                    gradient: _appleGradient,
                                    shadowColor: const Color(0xFF0D0D0F),
                                    enabled: _isAgreementAccepted,
                                    isLoading: state.requestStateApple.isLoading,
                                    onTap: () {
                                      di<AuthPlatformBloc>().add(
                                        SignInAppleEvent(context: context),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],

                            SizedBox(
                              height: (screenHeight * 0.030).clamp(18.0, 28.0),
                            ),

                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 180),
                              opacity: _isAgreementAccepted ? 1.0 : 0.52,
                              child: SizedBox(
                                width: double.infinity,
                                height: buttonHeight,
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                    buttonHeight / 2,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      if (!_isAgreementAccepted) {
                                        _showAgreementRequired();
                                        return;
                                      }
                                      context.pushNamedRoute(Routes.login);
                                    },
                                    borderRadius: BorderRadius.circular(
                                      buttonHeight / 2,
                                    ),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        // Its own warm gradient (was flat black),
                                        // distinct from every button above, so the
                                        // final CTA still stands out as the
                                        // primary action in the multi-gradient set.
                                        gradient: _phoneGradient,
                                        borderRadius: BorderRadius.circular(
                                          buttonHeight / 2,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x52FF5B7A),
                                            blurRadius: 16,
                                            offset: Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(width: 18.w),
                                          Container(
                                            width: 34.w,
                                            height: 34.w,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.12,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.phone_rounded,
                                              color: Colors.white,
                                              size: 18.h,
                                            ),
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                'Login with Phone',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15.5.sp,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 34.w,
                                            child: Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Colors.white,
                                              size: 19.h,
                                            ),
                                          ),
                                          SizedBox(width: 14.w),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              height: (screenHeight * 0.030).clamp(18.0, 28.0),
                            ),

                            // Terms/agreement now sits at the very bottom of the
                            // page (was between the sign-in buttons and the
                            // phone-login CTA), below every button.
                            _agreementCard(context),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _languageButton(BuildContext context) {
    final currentCode = context.locale.languageCode;
    final currentLanguage = _supportedLanguages.firstWhere(
          (item) => item['code'] == currentCode,
      orElse: () => _supportedLanguages.first,
    );

    return Material(
      color: const Color(0xFFF7F7F8),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: () => _showLanguagePicker(context),
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.language_rounded,
                size: 19,
                color: Color(0xFF1C1C1E),
              ),
              const SizedBox(width: 7),
              Text(
                currentLanguage['name'] ?? 'English',
                style: TextStyle(
                  color: const Color(0xFF1C1C1E),
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: Color(0xFF737373),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLanguagePicker(BuildContext pageContext) async {
    final currentCode = pageContext.locale.languageCode;

    final selectedCode = await showModalBottomSheet<String>(
      context: pageContext,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8D8DC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F3F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.translate_rounded,
                        size: 21,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _chooseLanguageTitle(currentCode),
                        style: TextStyle(
                          color: const Color(0xFF111111),
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ..._supportedLanguages.map((language) {
                  final code = language['code'] ?? 'en';
                  final isSelected = code == currentCode;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Material(
                      color: isSelected
                          ? const Color(0xFFF1F1F3)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: () => Navigator.of(sheetContext).pop(code),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  language['name'] ?? '',
                                  style: TextStyle(
                                    color: const Color(0xFF1B1B1D),
                                    fontSize: 15.5.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF111111),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (selectedCode == null ||
        selectedCode == currentCode ||
        !mounted) {
      return;
    }

    await pageContext.setLocale(Locale(selectedCode));
    DioFactory().updateLanguageHeader(selectedCode);
    di<LanguageBloc>().add(ChangeLanguageEvent(selectedCode));

    if (mounted) {
      setState(() {});
    }
  }

  String _chooseLanguageTitle(String code) {
    switch (code) {
      case 'ar':
        return 'اختر اللغة';
      case 'tr':
        return 'Dil seçin';
      case 'ur':
        return 'زبان منتخب کریں';
      case 'hi':
        return 'भाषा चुनें';
      case 'id':
        return 'Pilih bahasa';
      default:
        return 'Choose language';
    }
  }

  // Each sign-in option gets its own distinct premium gradient (was every
  // button sharing the single flat brand-purple gradient) so the button
  // stack reads as a richer, more deliberate palette instead of one colour
  // repeated five times.
  static const _googleGradient = LinearGradient(
    colors: [Color(0xFFA510FB), Color(0xFF5204C6)],
  );
  static const _huaweiGradient = LinearGradient(
    colors: [Color(0xFF22C7FF), Color(0xFF2A6DFF)],
  );
  static const _appleGradient = LinearGradient(
    colors: [Color(0xFF3A3A3C), Color(0xFF0D0D0F)],
  );
  static const _phoneGradient = LinearGradient(
    colors: [Color(0xFFFFA53E), Color(0xFFFF5B7A)],
  );

  Widget _referenceButton({
    required String iconAsset,
    required String label,
    required VoidCallback onTap,
    required double height,
    required bool enabled,
    required Gradient gradient,
    required Color shadowColor,
    double iconSize = 28,
    bool isLoading = false,
  }) {
    final canUse = enabled && !isLoading;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.6,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Material(
          // Premium brand-gradient pill (was a plain white/bordered button)
          // so every sign-in option shares the same smooth, elevated look.
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(height / 2),
          child: InkWell(
            onTap: isLoading
                ? null
                : () {
              if (!enabled) {
                _showAgreementRequired();
                return;
              }
              onTap();
            },
            borderRadius: BorderRadius.circular(height / 2),
            child: Ink(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(height / 2),
                boxShadow: canUse
                    ? [
                  BoxShadow(
                    color: shadowColor.withValues(alpha: 0.30),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
                    : null,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40.w,
                    child: Center(
                      child: isLoading
                          ? SizedBox(
                        width: 23,
                        height: 23,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: ColorManager.onBrandGradient,
                        ),
                      )
                          : Container(
                        width: iconSize.w + 10,
                        height: iconSize.w + 10,
                        padding: EdgeInsets.all(5.w),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          iconAsset,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ColorManager.onBrandGradient,
                          fontSize: 15.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 40.w),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _agreementCard(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
        color: _isAgreementAccepted
            ? const Color(0xFFF7F8F7)
            : const Color(0xFFFAFAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isAgreementAccepted
              ? const Color(0xFFD6DAD6)
              : const Color(0xFFE8E8EB),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: Checkbox(
              value: _isAgreementAccepted,
              onChanged: (value) {
                setState(() {
                  _isAgreementAccepted = value ?? false;
                });
              },
              activeColor: const Color(0xFF111111),
              checkColor: Colors.white,
              side: const BorderSide(
                color: Color(0xFF9A9AA0),
                width: 1.4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 3,
                runSpacing: 2,
                children: [
                  Text(
                    StringManager.haveRead.tr(),
                    style: TextStyle(
                      color: const Color(0xFF66666C),
                      fontSize: 12.5.sp,
                      height: 1.35,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  InkWell(
                    onTap: () => context.pushNamedRoute(Routes.privacy),
                    child: Text(
                      StringManager.termsAndCondition.tr(),
                      style: TextStyle(
                        color: const Color(0xFF111111),
                        fontSize: 12.5.sp,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Text(
                    '&',
                    style: TextStyle(
                      color: const Color(0xFF66666C),
                      fontSize: 12.5.sp,
                      height: 1.35,
                    ),
                  ),
                  InkWell(
                    onTap: () => context.pushNamedRoute(Routes.privacy),
                    child: Text(
                      StringManager.privacyPolicy_.tr(),
                      style: TextStyle(
                        color: const Color(0xFF111111),
                        fontSize: 12.5.sp,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAgreementRequired() {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            StringManager.acceptTerms.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF202024),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
