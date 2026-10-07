import 'package:flutter/foundation.dart';

enum UTDMiniOverlayState {
  idle,
  inAudioRoom,
  minimizing,
}

class UTDMiniOverlayMachine {
  UTDMiniOverlayMachine._();
  static final UTDMiniOverlayMachine instance = UTDMiniOverlayMachine._();

  final ValueNotifier<UTDMiniOverlayState> stateNotifier =
      ValueNotifier(UTDMiniOverlayState.idle);

  UTDMiniOverlayState get state => stateNotifier.value;

  bool get isMinimizing => state == UTDMiniOverlayState.minimizing;
  bool get isInAudioRoom => state == UTDMiniOverlayState.inAudioRoom;
  bool get isIdle => state == UTDMiniOverlayState.idle;

  void changeState(UTDMiniOverlayState newState) {
    if (stateNotifier.value == newState) return;
    debugPrint(
        '[UTDMiniOverlayMachine] ${stateNotifier.value.name} → ${newState.name}');
    stateNotifier.value = newState;
  }
}
