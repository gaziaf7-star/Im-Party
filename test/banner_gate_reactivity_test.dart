// fix(banners): reactivity tests for the banner-overlay gate (Jo Live,
// package `general`).
//
// Root cause RC1 (2026-06-12 plan): the `_BannerOverlay` gate in
// lib/src/core/app.dart was evaluated ONCE (cold start, splash on top) and
// never again — `NavObserver.currentRoute` was a plain field, so no route
// change ever re-triggered `_shouldShowBanner`, killing every special banner
// for the whole session.
//
// What is pinned here against the REAL production classes:
//
//   1. `NavObserver.currentRoute` is now a static ValueNotifier seeded with
//      the initial route ("/", not null) and updated + notifying on
//      didPush / didPop / didReplace / didRemove (with the didRemove guard:
//      removing a COVERED route — pushNamedAndRemoveUntil — must not clobber
//      the just-pushed top route).
//
//   2. The exact gate wiring `_BannerOverlay` uses —
//      `Listenable.merge([NavObserver.currentRoute, isInPip])` — re-runs its
//      builder on every route change AND on every PiP flip.
//
//   3. The tab path: the real `LayoutBloc` (+ the `buildWhen: prev != curr`
//      the overlay uses) re-evaluates on a REAL tab change and stays silent on
//      a same-index re-emission — which is exactly why the route notifier (1)
//      is required for cold start (`ChangeIndexEvent(0)` over default index 0
//      never rebuilds).
//
// `_BannerOverlay` itself is private and di-coupled, so the queue-preservation
// branch (suppression hides, never clears `LuckyBoxVariables.activeBanners`)
// is enforced by code review of app.dart — the clear call was removed.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:general/main.dart' show isInPip;
import 'package:general/src/core/app.dart' show NavObserver;
import 'package:general/src/features/layout/bloc/layout_bloc.dart';

Widget _navApp(NavObserver observer, {TransitionBuilder? builder}) {
  return MaterialApp(
    navigatorObservers: [observer],
    initialRoute: '/',
    builder: builder,
    onGenerateRoute: (settings) => MaterialPageRoute(
      settings: settings,
      builder: (_) => Scaffold(body: Text('page:${settings.name}')),
    ),
  );
}

void main() {
  setUp(() {
    // The notifier is static (shared app-wide) — reset between tests.
    NavObserver.currentRoute.value = '/';
    isInPip.value = false;
  });

  group('NavObserver.currentRoute is a reactive route notifier', () {
    testWidgets('seeded with the initial route, not null', (tester) async {
      expect(NavObserver.currentRoute.value, '/');
      await tester.pumpWidget(_navApp(NavObserver()));
      expect(NavObserver.currentRoute.value, '/');
    });

    testWidgets('didPush + didPop update the value and notify',
        (tester) async {
      var notifications = 0;
      void listener() => notifications++;
      NavObserver.currentRoute.addListener(listener);
      addTearDown(() => NavObserver.currentRoute.removeListener(listener));

      await tester.pumpWidget(_navApp(NavObserver()));
      final nav = tester.state<NavigatorState>(find.byType(Navigator));

      nav.pushNamed('/live_room_screen');
      await tester.pumpAndSettle();
      expect(NavObserver.currentRoute.value, '/live_room_screen');
      expect(notifications, greaterThan(0));

      final afterPush = notifications;
      nav.pop();
      await tester.pumpAndSettle();
      expect(NavObserver.currentRoute.value, '/');
      expect(notifications, greaterThan(afterPush));
    });

    testWidgets('didReplace updates the value', (tester) async {
      await tester.pumpWidget(_navApp(NavObserver()));
      final nav = tester.state<NavigatorState>(find.byType(Navigator));

      nav.pushNamed('/a');
      await tester.pumpAndSettle();
      nav.pushReplacementNamed('/b');
      await tester.pumpAndSettle();
      expect(NavObserver.currentRoute.value, '/b');
    });

    testWidgets(
        'didRemove guard: pushNamedAndRemoveUntil keeps the NEW top route '
        '(removed covered routes must not clobber it)', (tester) async {
      await tester.pumpWidget(_navApp(NavObserver()));
      final nav = tester.state<NavigatorState>(find.byType(Navigator));

      nav.pushNamed('/a');
      await tester.pumpAndSettle();
      nav.pushNamedAndRemoveUntil('/layout_screen', (route) => false);
      await tester.pumpAndSettle();
      expect(NavObserver.currentRoute.value, '/layout_screen');
    });

    test('didRemove of the VISIBLE route falls back to the route below', () {
      final observer = NavObserver();
      final removed = MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/top'),
        builder: (_) => const SizedBox(),
      );
      final below = MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/below'),
        builder: (_) => const SizedBox(),
      );
      NavObserver.currentRoute.value = '/top';
      observer.didRemove(removed, below);
      expect(NavObserver.currentRoute.value, '/below');
    });
  });

  group('gate listenable (route + PiP) re-evaluates — _BannerOverlay wiring',
      () {
    testWidgets('builder re-runs on route change and on PiP flip',
        (tester) async {
      var evaluations = 0;
      // Same composition as _BannerOverlay: the gate sits ABOVE the navigator
      // and merges the route notifier with the PiP flag.
      await tester.pumpWidget(_navApp(
        NavObserver(),
        builder: (context, child) => Stack(
          textDirection: TextDirection.ltr,
          children: [
            child!,
            ListenableBuilder(
              listenable:
                  Listenable.merge([NavObserver.currentRoute, isInPip]),
              builder: (_, __) {
                evaluations++;
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ));
      final baseline = evaluations;
      final nav = tester.state<NavigatorState>(find.byType(Navigator));

      // Route change (splash -> live, the frozen cold-start scenario).
      nav.pushNamed('/live_room_screen');
      await tester.pumpAndSettle();
      expect(evaluations, greaterThan(baseline),
          reason: 'pushing a route must re-evaluate the banner gate');

      // PiP flip.
      final afterRoute = evaluations;
      isInPip.value = true;
      await tester.pump();
      expect(evaluations, greaterThan(afterRoute),
          reason: 'a PiP flip must re-evaluate the banner gate');
    });
  });

  group('tab path (real LayoutBloc, buildWhen: prev != curr)', () {
    testWidgets('re-evaluates on a tab CHANGE', (tester) async {
      final bloc = LayoutBloc();
      addTearDown(bloc.close);
      var evaluations = 0;
      var lastIndex = -1;

      await tester.pumpWidget(MaterialApp(
        home: BlocBuilder<LayoutBloc, LayoutState>(
          bloc: bloc,
          buildWhen: (prev, curr) => prev != curr,
          builder: (_, state) {
            evaluations++;
            lastIndex = state.currentIndex;
            return const SizedBox.shrink();
          },
        ),
      ));
      final baseline = evaluations;

      bloc.add(const ChangeIndexEvent(currentIdex: 1));
      await tester.pumpAndSettle();
      expect(evaluations, greaterThan(baseline));
      expect(lastIndex, 1);
    });

    testWidgets(
        'same-index re-emission does NOT rebuild — why cold start needed the '
        'route notifier', (tester) async {
      final bloc = LayoutBloc();
      addTearDown(bloc.close);
      var evaluations = 0;

      await tester.pumpWidget(MaterialApp(
        home: BlocBuilder<LayoutBloc, LayoutState>(
          bloc: bloc,
          buildWhen: (prev, curr) => prev != curr,
          builder: (_, state) {
            evaluations++;
            return const SizedBox.shrink();
          },
        ),
      ));
      final baseline = evaluations;

      // layout_page.dart fires ChangeIndexEvent(0) over the default index 0:
      // Equatable state -> buildWhen blocks the rebuild.
      bloc.add(const ChangeIndexEvent(currentIdex: 0));
      await tester.pumpAndSettle();
      expect(evaluations, baseline);
    });
  });
}
