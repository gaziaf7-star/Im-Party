// Phase C battery gating tests (Jo Live, package `general`).
//
// Two things are pinned here:
//
//   1. AppLifecycleSignal — the new app-wide foreground/background signal in
//      lib/src/core/utils/app_lifecycle_signal.dart. It is plugin-free (only
//      flutter/widgets for AppLifecycleState + ValueNotifier), so we import the
//      REAL class and exercise its public API directly:
//        update(resumed)                       -> isForeground == true
//        update(paused|inactive|hidden|detached) -> isForeground == false
//      plus: listeners are notified when the value actually changes.
//
//   2. The frame-widget gate decision: shouldRun = visible && foreground.
//      That predicate lives inline in the seat-frame widgets and is not directly
//      callable, so we replicate the tiny pure rule (same convention as
//      test/crash_fix_helpers_test.dart) and lock its full 4-row truth table:
//      only (visible:true, fg:true) runs; the other 3 combos stop to save battery.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:general/src/core/utils/app_lifecycle_signal.dart';

// ---------------------------------------------------------------------------
// Replica of the frame-widget gate predicate: shouldRun = visible && foreground.
// (Pure boolean rule used to start/stop per-seat frame animations.)
// ---------------------------------------------------------------------------
bool shouldRun({required bool visible, required bool foreground}) =>
    visible && foreground;

void main() {
  // The real AppLifecycleSignal uses ValueNotifier, which needs no plugin or
  // binding, but flutter_test sets up the test binding anyway so this is safe.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLifecycleSignal.update (real class, foreground rule)', () {
    // isForeground is a static singleton; reset to its default before each test
    // so ordering can never leak state between cases.
    setUp(() {
      AppLifecycleSignal.update(AppLifecycleState.resumed);
    });

    test('resumed -> foreground (true)', () {
      AppLifecycleSignal.update(AppLifecycleState.resumed);
      expect(AppLifecycleSignal.isForeground.value, isTrue);
    });

    test('paused -> not foreground (false)', () {
      AppLifecycleSignal.update(AppLifecycleState.paused);
      expect(AppLifecycleSignal.isForeground.value, isFalse);
    });

    test('inactive -> not foreground (false)', () {
      AppLifecycleSignal.update(AppLifecycleState.inactive);
      expect(AppLifecycleSignal.isForeground.value, isFalse);
    });

    test('hidden -> not foreground (false)', () {
      AppLifecycleSignal.update(AppLifecycleState.hidden);
      expect(AppLifecycleSignal.isForeground.value, isFalse);
    });

    test('detached -> not foreground (false)', () {
      AppLifecycleSignal.update(AppLifecycleState.detached);
      expect(AppLifecycleSignal.isForeground.value, isFalse);
    });

    test('only resumed maps to foreground across every lifecycle state', () {
      for (final state in AppLifecycleState.values) {
        AppLifecycleSignal.update(state);
        expect(
          AppLifecycleSignal.isForeground.value,
          state == AppLifecycleState.resumed,
          reason: 'state $state should map to foreground='
              '${state == AppLifecycleState.resumed}',
        );
      }
    });
  });

  group('AppLifecycleSignal listener notification (single shared source)', () {
    setUp(() {
      AppLifecycleSignal.update(AppLifecycleState.resumed);
    });

    test('listener fires when value changes resumed -> paused', () {
      var notifications = 0;
      void listener() => notifications++;
      AppLifecycleSignal.isForeground.addListener(listener);
      addTearDown(() => AppLifecycleSignal.isForeground.removeListener(listener));

      AppLifecycleSignal.update(AppLifecycleState.paused); // true -> false
      expect(notifications, 1);
      expect(AppLifecycleSignal.isForeground.value, isFalse);
    });

    test('listener fires again on paused -> resumed', () {
      AppLifecycleSignal.update(AppLifecycleState.paused);

      var notifications = 0;
      void listener() => notifications++;
      AppLifecycleSignal.isForeground.addListener(listener);
      addTearDown(() => AppLifecycleSignal.isForeground.removeListener(listener));

      AppLifecycleSignal.update(AppLifecycleState.resumed); // false -> true
      expect(notifications, 1);
      expect(AppLifecycleSignal.isForeground.value, isTrue);
    });

    test('no notification when value is unchanged (ValueNotifier dedup)', () {
      var notifications = 0;
      void listener() => notifications++;
      AppLifecycleSignal.isForeground.addListener(listener);
      addTearDown(() => AppLifecycleSignal.isForeground.removeListener(listener));

      // Already resumed (true) from setUp; updating to resumed again is a no-op.
      AppLifecycleSignal.update(AppLifecycleState.resumed);
      expect(notifications, 0);

      // Two consecutive background states stay false -> only one notification.
      AppLifecycleSignal.update(AppLifecycleState.paused); // true -> false (1)
      AppLifecycleSignal.update(AppLifecycleState.hidden); // false -> false (no-op)
      expect(notifications, 1);
    });
  });

  group('frame gate predicate: shouldRun = visible && foreground', () {
    test('visible & foreground -> RUN (the only running combo)', () {
      expect(shouldRun(visible: true, foreground: true), isTrue);
    });

    test('visible but background -> STOP', () {
      expect(shouldRun(visible: true, foreground: false), isFalse);
    });

    test('hidden but foreground -> STOP', () {
      expect(shouldRun(visible: false, foreground: true), isFalse);
    });

    test('hidden & background -> STOP', () {
      expect(shouldRun(visible: false, foreground: false), isFalse);
    });

    test('full truth table: exactly one of four combos runs', () {
      final results = <List<bool>, bool>{};
      for (final visible in <bool>[true, false]) {
        for (final foreground in <bool>[true, false]) {
          results[<bool>[visible, foreground]] =
              shouldRun(visible: visible, foreground: foreground);
        }
      }
      final running = results.values.where((r) => r).length;
      expect(running, 1, reason: 'only (visible, foreground) may run');
      expect(shouldRun(visible: true, foreground: true), isTrue);
    });
  });
}
