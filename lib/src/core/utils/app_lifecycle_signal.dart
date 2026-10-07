import 'package:flutter/widgets.dart';

/// Single app-wide foreground/background signal.
///
/// Updated by one observer (`_TempAppState.didChangeAppLifecycleState`) so that
/// many widgets (e.g. the up-to-22 seat frames) can listen to a single source
/// instead of each registering its own [WidgetsBindingObserver].
///
/// `true` means the app is in the foreground (`AppLifecycleState.resumed`);
/// any other state (paused / inactive / hidden / detached) is treated as not
/// foreground so animations can be paused to save battery.
class AppLifecycleSignal {
  AppLifecycleSignal._();

  static final ValueNotifier<bool> isForeground = ValueNotifier<bool>(true);

  static void update(AppLifecycleState state) {
    isForeground.value = state == AppLifecycleState.resumed;
  }
}
