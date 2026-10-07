part of 'text_field__bloc.dart';

class TextFieldStates extends Equatable {
  final RequestState reqState;
  final RecorderController recordController;
  final File? voice;
  final bool isRecording, isDisplayVoice;
  final Timer? timer;
  final int counter;
  final bool isPaused;

  const TextFieldStates({
    this.reqState = RequestState.loading,
    required this.recordController,
    this.voice,
    this.isRecording = false,
    this.isDisplayVoice = false,
    this.timer,
    this.counter = 0,
    this.isPaused = false,
  });

  TextFieldStates copyWith({
    RequestState? reqState,
    RecorderController? recordController,
    File? voice,
    bool isVoiceNull = false,
    bool? isRecording,
    bool? isDisplayVoice,
    Timer? timer,
    int? counter,
    bool? isPaused,
  }) {
    return TextFieldStates(
      reqState: reqState ?? this.reqState,
      recordController: recordController ?? this.recordController,
      voice: isVoiceNull ? null : voice ?? this.voice,
      isRecording: isRecording ?? this.isRecording,
      isDisplayVoice: isDisplayVoice ?? this.isDisplayVoice,
      timer: timer ?? this.timer,
      counter: counter ?? this.counter,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  @override
  List<Object?> get props => [
        reqState,
        recordController,
        voice,
        isRecording,
        isDisplayVoice,
        // `timer` is intentionally NOT in props: a live Timer must not
        // participate in state equality (it changes identity on every re-arm
        // and would defeat Equatable's dedup of otherwise-identical states).
        counter,
        isPaused,
      ];
}
