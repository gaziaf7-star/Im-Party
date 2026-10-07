import 'package:flutter/material.dart';

import '../controller/utd_room_controller.dart';

/// Compact, view-only content rendered inside the Android system PiP window
/// while [UTDRoomController.pip] reports `isInPip == true`.
///
/// Mirrors the in-app minimize overlay's look (room cover + active-speaker
/// sound wave) but full-bleed and non-interactive — the OS ignores touches in
/// a PiP window, so there are no buttons or drag handles here.
class UTDPipView extends StatefulWidget {
  final UTDRoomController controller;

  const UTDPipView({super.key, required this.controller});

  @override
  State<UTDPipView> createState() => _UTDPipViewState();
}

class _UTDPipViewState extends State<UTDPipView> with TickerProviderStateMixin {
  late final List<AnimationController> _waveControllers;
  final ValueNotifier<bool> _isSpeaking = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _waveControllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 900 + (i * 250)),
      ),
    );
    // Event-driven (activeSpeakers is a ValueNotifier) — reacts instantly and
    // never ticks a timer while nobody talks.
    widget.controller.activeSpeakers.addListener(_onSpeakersChanged);
    _onSpeakersChanged();
  }

  void _onSpeakersChanged() {
    if (!mounted) return;
    final speaking = widget.controller.activeSpeakers.value.isNotEmpty;
    if (_isSpeaking.value != speaking) {
      _isSpeaking.value = speaking;
    }
    _applyWaveAnimation(speaking);
  }

  /// The rings only need to tick while someone is speaking — leaving the
  /// controllers repeating when idle burns a vsync callback every frame for
  /// widgets that aren't even built (they render only when `isSpeaking`).
  void _applyWaveAnimation(bool speaking) {
    for (final c in _waveControllers) {
      if (speaking) {
        if (!c.isAnimating) c.repeat(reverse: true);
      } else {
        c.stop();
      }
    }
  }

  @override
  void dispose() {
    widget.controller.activeSpeakers.removeListener(_onSpeakersChanged);
    for (final c in _waveControllers) {
      c.dispose();
    }
    _isSpeaking.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.controller.minimize.config;
    final roomImage = config?.roomImage;
    final waveColor = config?.soundWaveColor ?? Colors.green;

    return Material(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Room cover.
          if (roomImage != null && roomImage.isNotEmpty)
            Image.network(
              roomImage,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: Colors.black),
            ),
          // Dark scrim for contrast.
          const ColoredBox(color: Color(0x59000000)),
          // Active-speaker sound wave (centered pulsing rings).
          Center(
            child: ValueListenableBuilder<bool>(
              valueListenable: _isSpeaking,
              builder: (_, isSpeaking, __) => _SoundWave(
                isSpeaking: isSpeaking,
                controllers: _waveControllers,
                color: waveColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Concentric pulsing rings around a center mic glyph; rings only animate while
/// someone is speaking.
class _SoundWave extends StatelessWidget {
  final bool isSpeaking;
  final List<AnimationController> controllers;
  final Color color;

  const _SoundWave({
    required this.isSpeaking,
    required this.controllers,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (isSpeaking)
          for (int i = 0; i < controllers.length; i++)
            AnimatedBuilder(
              animation: controllers[i],
              builder: (_, __) {
                final t = controllers[i].value;
                final size = 56.0 + (t * 22 * (i + 1));
                final opacity = (1.0 - t * 0.7).clamp(0.0, 1.0);
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: opacity * 0.6),
                      width: 2,
                    ),
                  ),
                );
              },
            ),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isSpeaking
                ? color.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSpeaking ? Icons.graphic_eq : Icons.headset,
            color: Colors.white,
            size: 26,
          ),
        ),
      ],
    );
  }
}
