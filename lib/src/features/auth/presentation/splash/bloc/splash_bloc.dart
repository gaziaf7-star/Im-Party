import 'dart:async';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/presentation/splash/config_app/config_app_bloc.dart';
import '../../../../home/presentation/banner/banner_bloc/banner_bloc.dart';
import '../../../../home/presentation/banner/banner_bloc/banner_event.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(const SplashInitial()) {
    on<SplashNavigationEvent>(_navigationEvent);
  }

  // Events
  void _navigationEvent(
    SplashNavigationEvent event,
    Emitter<SplashState> emit,
  ) async {
    FlutterNativeSplash.remove();
    final token = HiveManager.instance
        .getData<String>(KeysManager.USER_BOX, KeysManager.TOKEN_KEY);

    // The language-picker and onboarding screens used to show on every
    // launch (gated only on their own "seen it" flags, which is why they
    // kept reappearing) -- they're now skipped entirely. A brand-new
    // install goes straight from splash to the Welcome/login page; every
    // later launch fetches the real /api/banners image and shows it
    // (like Bigo's app-open banner) before continuing, same as it already
    // did for the promo-event banner -- just no longer gated on having a
    // token first, and with no local placeholder art involved.
    final hasLaunchedBefore = Methods.getHasLaunchedBefore();

    if (!hasLaunchedBefore) {
      await Methods.saveHasLaunchedBefore();
      navKey.currentContext?.pushNamedAndRemoveUntil(Routes.intro);
    } else {
      // The banner is meant to show on every launch, so it's worth actually
      // waiting for the fetch instead of racing it -- the old 600ms cap
      // (carried over from when this branch was a "nice to have" promo
      // banner behind a login check) was shorter than this endpoint's real
      // response time, so the banner silently lost the race and every
      // launch fell straight through to home instead. 8s is generous for a
      // JSON GET; if it's genuinely down/offline this still won't hang the
      // app past that.
      di<BannerBloc>().add(const GetBannerEvent());
      await _waitForBanner();
      if (di<BannerBloc>().state.bannerEntity != null) {
        navKey.currentContext?.pushNamedAndRemoveUntil(Routes.bannerScreen);
      } else {
        token == null
            ? navKey.currentContext?.pushNamedAndRemoveUntil(Routes.intro)
            : navKey.currentContext?.pushNamedAndRemoveUntil(Routes.layout);
      }
    }
    if (di<ConfigAppBloc>().state.requestState.isError) {
      final context = SafeNavigator.context;
      if (context == null) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.refreshScreen,
        (route) => false,
      );
      return;
    }
  }

  // Wait (max 8s) for the banner request to reach a terminal state so the
  // bannerScreen-vs-direct decision is correct. Returns immediately if the
  // banner already resolved; falls through (skipping the banner) on timeout.
  Future<void> _waitForBanner() async {
    final bannerBloc = di<BannerBloc>();
    final state = bannerBloc.state;
    if (state.requestState.isLoaded ||
        state.requestState.isEmpty ||
        state.requestState.isError) {
      return;
    }
    try {
      await bannerBloc.stream
          .firstWhere((s) =>
              s.requestState.isLoaded ||
              s.requestState.isEmpty ||
              s.requestState.isError)
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      // Timed out or stream closed — skip the banner below.
    }
  }
}
