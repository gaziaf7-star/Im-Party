import 'dart:async';
import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/messages/messages.dart';
import 'package:uuid/uuid.dart';

part 'text_field__event.dart';
part 'text_field_state.dart';

/// Maximum voice note duration in seconds. Auto-finalizes at this limit so
/// the recorder never runs indefinitely (#85).
const int kMaxVoiceDurationSeconds = 120;

class TextFieldBloc extends Bloc<TextFieldEvents, TextFieldStates> {
  TextFieldBloc()
      : super(
          TextFieldStates(
            recordController: RecorderController(),
          ),
        ) {
    // Every state change goes through an event handler so emit() is only ever
    // called inside an Emitter scope (never from an async method body or a
    // Timer callback, which crashes with StateError once the bloc is closed).
    on<_EmitState>((event, emit) {
      if (emit.isDone) return;
      emit(event.state);
    });
    on<TickCounter>((event, emit) {
      if (emit.isDone) return;
      final next = state.counter + 1;
      emit(state.copyWith(counter: next));
      // Auto-finalize at the cap so the recorder never runs indefinitely (#85).
      if (next >= kMaxVoiceDurationSeconds) {
        add(const StopRecord());
      }
    });
    on<StartRecord>((event, emit) => _startRecord());
    on<StopRecord>((event, emit) => _stopRecord());
    on<PauseResumeRecord>((event, emit) => _pauseOrResumeRecorder());
  }

  /// Emit a fully-built next state from outside a handler safely (routed through
  /// the `_EmitState` handler so it always lands inside an Emitter scope).
  void _emit(TextFieldStates next) {
    if (isClosed) return;
    add(_EmitState(next));
  }

  // --- public API (called from the view / toggle_app_bar_bloc) ---------------

  Future<void> toggleRecorder() async {
    switch (state.isRecording) {
      case true:
        add(const StopRecord());
        break;
      case false:
        add(const StartRecord());
        break;
    }
  }

  void startRecord() => add(const StartRecord());

  void stopRecord() => add(const StopRecord());

  void pauseOrResumeRecorder() => add(const PauseResumeRecord());

  // --- implementations -------------------------------------------------------

  Future<void> _startRecord() async {
    try {
      await _openTheRecorder();
      _startTimerCountDown();
      final String uniqueKey = const Uuid().v4() +
          DateTime.now().toIso8601String().replaceAll('.', '-');
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      final voiceFile = File("$tempPath/$uniqueKey.mp3");
      _emit(state.copyWith(voice: voiceFile));
      await state.recordController.record(path: voiceFile.path);
      _emit(state.copyWith(isRecording: true));
      di<ToggleAppBarBloc>().add(const InitAppBarEvent());
    } catch (error) {
      if (state.timer?.isActive == true) state.timer?.cancel();
      _emit(state.copyWith(isRecording: false, isVoiceNull: true));
    }
  }

  Future<void> _openTheRecorder() async {
    final PermissionStatus status =
        await Methods.requestPermission(Permission.microphone);
    // Fail-CLOSED: abort unless the mic is actually granted. The old guard was
    // inverted (it only threw when checkPermission() was ALSO true, so a denied
    // mic silently fell through and "recorded" a phantom voice). Surface the
    // reason and, on permanent denial, point the user to system settings.
    if (!status.isGranted) {
      final ctx = navKey.currentContext;
      if (ctx != null) {
        Methods.showToast(
          ctx,
          isError: true,
          message: status.isPermanentlyDenied
              ? StringManager.MicPermissionDescription.tr()
              : StringManager.MicPermission.tr(),
        );
      }
      if (status.isPermanentlyDenied) {
        // Best-effort hop to settings so the user can re-enable the mic.
        unawaited(openAppSettings());
      }
      throw 'Microphone permission not granted';
    }
  }

  Future<void> _stopRecord() async {
    await state.recordController.stop();
    if (state.timer?.isActive == true) state.timer?.cancel();
    _emit(
      state.copyWith(
        isRecording: false,
        isPaused: false,
        isDisplayVoice: false,
        isVoiceNull: true,
      ),
    );
  }

  void _startTimerCountDown() async {
    state.timer?.cancel();
    await state.recordController.stop();
    const second = Duration(seconds: 1);
    // Never emit from a Timer callback — dispatch a TickCounter event so the
    // increment lands inside the handler's Emitter (and is a no-op after close).
    _emit(
      state.copyWith(
        counter: 0,
        timer: Timer.periodic(second, (Timer timer) => add(const TickCounter())),
      ),
    );
  }

  Future<void> _pauseOrResumeRecorder() async {
    if (state.isPaused) {
      await state.recordController.record(path: state.voice?.path);
      const second = Duration(seconds: 1);
      _emit(
        state.copyWith(
          timer:
              Timer.periodic(second, (Timer timer) => add(const TickCounter())),
          isPaused: false,
        ),
      );
    } else {
      await state.recordController.pause();
      state.timer?.cancel();
      _emit(state.copyWith(isPaused: true));
    }
  }

  @override
  Future<void> close() {
    // Cancel the live counter timer and release the native recorder + its
    // ChangeNotifier so a closed/reset bloc can never emit again and the mic
    // session + file handles are freed.
    state.timer?.cancel();
    state.recordController.dispose();
    return super.close();
  }

  /// Arms a periodic counter timer into state exactly as the recording flow
  /// does (TickCounter per tick), WITHOUT touching the native recorder — so the
  /// timer-cancellation-on-close guarantee can be exercised in a unit test.
  @visibleForTesting
  void armCounterTimerForTest() {
    state.timer?.cancel();
    const second = Duration(seconds: 1);
    _emit(
      state.copyWith(
        counter: 0,
        timer: Timer.periodic(second, (Timer timer) => add(const TickCounter())),
      ),
    );
  }
}
