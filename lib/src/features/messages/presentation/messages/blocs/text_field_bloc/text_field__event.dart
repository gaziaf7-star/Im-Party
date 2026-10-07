part of 'text_field__bloc.dart';

abstract class TextFieldEvents extends Equatable {
  const TextFieldEvents();

  @override
  List<Object?> get props => [];
}

/// Begin a new recording (open recorder + start the per-second counter).
class StartRecord extends TextFieldEvents {
  const StartRecord();
}

/// Stop the current recording and reset the recorder UI state.
class StopRecord extends TextFieldEvents {
  const StopRecord();
}

/// Pause an active recording, or resume a paused one.
class PauseResumeRecord extends TextFieldEvents {
  const PauseResumeRecord();
}

/// One per-second counter tick, dispatched FROM the periodic timer callback so
/// the state change happens inside an Emitter scope (never emit() from a Timer).
class TickCounter extends TextFieldEvents {
  const TickCounter();
}

/// Carries a fully-built next state to emit from inside a handler scope (used by
/// the async record/stop flows that must emit after awaited work).
class _EmitState extends TextFieldEvents {
  const _EmitState(this.state);

  final TextFieldStates state;

  @override
  List<Object?> get props => [state];
}
