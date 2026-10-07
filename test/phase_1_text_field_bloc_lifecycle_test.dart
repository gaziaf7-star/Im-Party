// Phase 1 — TextFieldBloc (voice-recording composer) lifecycle safety.
//
// Locks the crash/leak fixes for findings #13 + #42:
//   * #13 emit() is now only ever called from inside an event handler. The
//     per-second counter is driven by a TickCounter EVENT (the Timer callback
//     does add(TickCounter()), never emit()), and both the TickCounter and the
//     internal _EmitState handlers are guarded by emit.isDone.
//   * close() cancels the live counter timer and disposes the RecorderController
//     so a closed/reset bloc can never emit again (no StateError after close)
//     and the native recorder + its file handles are released.
//
// We exercise the REAL bloc (it is plugin-light: RecorderController's ctor sets
// a flag only, and dispose() on a never-started, default-`stopped` controller
// makes no platform call). A method-channel stub covers any incidental call so
// the test stays hermetic.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:general/src/features/messages/presentation/messages/blocs/text_field_bloc/text_field__bloc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Stub the audio_waveforms plugin channel so RecorderController never reaches
  // a missing native side during construction/dispose.
  const channel = MethodChannel('simform_audio_waveforms_plugin/methods');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('TextFieldBloc lifecycle (#13 / #42)', () {
    test('TickCounter event increments the counter (event-driven path)',
        () async {
      final bloc = TextFieldBloc();
      addTearDown(bloc.close);

      expect(bloc.state.counter, 0);

      bloc.add(const TickCounter());
      await bloc.stream.firstWhere((s) => s.counter == 1);
      expect(bloc.state.counter, 1);

      bloc.add(const TickCounter());
      await bloc.stream.firstWhere((s) => s.counter == 2);
      expect(bloc.state.counter, 2);
    });

    test('close() cancels the live counter timer (no orphaned timer)',
        () async {
      final bloc = TextFieldBloc();

      // Arm the counter timer through the real production path (TickCounter per
      // tick), then capture the live Timer instance from state.
      bloc.armCounterTimerForTest();
      await bloc.stream.firstWhere((s) => s.timer != null);
      final timer = bloc.state.timer!;
      expect(timer.isActive, isTrue);

      await bloc.close();

      // close() must have cancelled the timer so it can never fire (and
      // dispatch add(TickCounter())) against the now-closed bloc.
      expect(timer.isActive, isFalse,
          reason: 'close() must cancel the live counter timer');
    });

    test(
        'a tick in-flight at close time does not throw StateError (emit.isDone guard)',
        () async {
      final bloc = TextFieldBloc();

      // Queue a tick, then close before it is processed. The handler runs
      // against an already-done Emitter; the emit.isDone guard must make it a
      // no-op instead of throwing "Cannot add new events / emit after close".
      Object? zoneError;
      await runZonedGuarded(() async {
        bloc.add(const TickCounter());
        await bloc.close();
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }, (e, st) => zoneError = e);

      expect(zoneError, isNull,
          reason: 'guarded handler must not surface a StateError after close');
    });

    test('constructing and closing the bloc disposes cleanly (no throw)',
        () async {
      final bloc = TextFieldBloc();
      // RecorderController.dispose() runs inside close(); on a default-stopped
      // controller it makes no platform call and must not throw.
      await expectLater(bloc.close(), completes);
    });
  });
}
