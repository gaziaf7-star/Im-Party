import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controller/utd_room_controller.dart';

class UTDMiniOverlayPage extends StatefulWidget {
  final UTDRoomController controller;
  final Size? size;
  final Offset? topLeft;

  const UTDMiniOverlayPage({
    super.key,
    required this.controller,
    this.size,
    this.topLeft,
  });

  @override
  State<UTDMiniOverlayPage> createState() => _UTDMiniOverlayPageState();
}

class _UTDMiniOverlayPageState extends State<UTDMiniOverlayPage>
    with TickerProviderStateMixin {
  late Offset _position;
  late Size _overlaySize;

  late final AnimationController _entranceController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  late final List<AnimationController> _waveControllers;

  // Snap-to-edge: on release the bubble springs to the nearest side (or the
  // side a flick points at) instead of floating where it was dropped.
  late final AnimationController _snapController;
  Animation<Offset>? _snapAnimation;
  bool _dragging = false;

  final ValueNotifier<bool> _isSpeakingNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    final config = widget.controller.minimize.config;
    _overlaySize = widget.size ??
        Size(
          config?.overlayWidth ?? 100,
          config?.overlayHeight ?? 100,
        );
    _position = widget.topLeft ??
        Offset(
          100,
          MediaQueryData.fromView(
                      WidgetsBinding.instance.platformDispatcher.views.first)
                  .size
                  .height -
              (config?.overlayBottomOffset ?? 120) -
              _overlaySize.height,
        );

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutBack,
    );
    _opacityAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _entranceController.forward();

    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..addListener(() {
        final anim = _snapAnimation;
        if (anim != null) setState(() => _position = anim.value);
      });

    // Created STOPPED — driven on/off by speaking state below. The old version
    // repeat()'d all three forever, so they ticked a vsync callback every frame
    // for the whole minimized session even in a silent room.
    _waveControllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 600 + (i * 200)),
      );
    });

    // Event-driven speaking state: activeSpeakers is already a ValueNotifier, so
    // the ring reacts instantly instead of lagging up to ~1s behind a polling
    // Timer (and no timer ticks while nobody talks).
    widget.controller.activeSpeakers.addListener(_onSpeakersChanged);
    _onSpeakersChanged();
  }

  void _onSpeakersChanged() {
    if (!mounted) return;
    final isSpeaking = widget.controller.activeSpeakers.value.isNotEmpty;
    if (_isSpeakingNotifier.value != isSpeaking) {
      _isSpeakingNotifier.value = isSpeaking;
    }
    _applyWaveAnimation(isSpeaking);
  }

  /// Run the wave controllers only while someone is speaking; stop them at rest
  /// so a silent minimized room holds zero per-frame animation work.
  void _applyWaveAnimation(bool isSpeaking) {
    for (final c in _waveControllers) {
      if (isSpeaking) {
        if (!c.isAnimating) c.repeat(reverse: true);
      } else if (c.isAnimating) {
        c.stop();
      }
    }
  }

  @override
  void dispose() {
    widget.controller.activeSpeakers.removeListener(_onSpeakersChanged);
    _snapController.dispose();
    _entranceController.dispose();
    for (final c in _waveControllers) {
      c.dispose();
    }
    _isSpeakingNotifier.dispose();
    super.dispose();
  }

  /// Clamp within the screen AND clear of system chrome (status bar / notch /
  /// home indicator) so the bubble can never tuck behind it and become
  /// impossible to grab.
  Offset _clampToBounds(Offset pos) {
    final screenSize = MediaQuery.of(context).size;
    final inset = MediaQuery.of(context).viewPadding;
    return Offset(
      pos.dx.clamp(0.0, screenSize.width - _overlaySize.width),
      pos.dy.clamp(
        inset.top + 8,
        screenSize.height - inset.bottom - _overlaySize.height - 8,
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    _snapController.stop();
    HapticFeedback.lightImpact();
    setState(() => _dragging = true);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _position = _clampToBounds(_position + details.delta);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() => _dragging = false);
    final screenSize = MediaQuery.of(context).size;
    final vx = details.velocity.pixelsPerSecond.dx;
    final center = _position.dx + _overlaySize.width / 2;
    // A deliberate flick throws it to the side its velocity points at;
    // otherwise snap to whichever edge is nearer.
    final bool toLeft = vx.abs() > 300 ? vx < 0 : center < screenSize.width / 2;
    final double targetX =
        toLeft ? 12.0 : screenSize.width - _overlaySize.width - 12.0;
    final target = _clampToBounds(Offset(targetX, _position.dy));
    _snapAnimation = Tween<Offset>(begin: _position, end: target).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOutCubic),
    );
    _snapController.forward(from: 0).then((_) {
      if (mounted) HapticFeedback.lightImpact();
    });
  }

  void _onRestore() {
    HapticFeedback.selectionClick();
    _entranceController.reverse().then((_) {
      if (!mounted) return;
      widget.controller.minimize.restoreWithNavigator();
    });
  }

  void _onClose() {
    HapticFeedback.mediumImpact();
    _entranceController.reverse().then((_) {
      widget.controller.minimize.close();
    });
  }

  void _onMicToggle() {
    HapticFeedback.selectionClick();
    final media = widget.controller.mediaController;
    media.setMicrophoneEnabled(!media.isMicEnabled.value);
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.controller.minimize.config;

    if (config?.overlayBuilder != null) {
      return config!.overlayBuilder!(
        onRestore: _onRestore,
        onClose: _onClose,
      );
    }

    final borderRadius = config?.borderRadius ?? 16.0;
    final showMic = config?.showMicToggle ?? true;
    final showLeave = config?.showLeaveButton ?? true;
    final roomImage = config?.roomImage;
    final waveColor = config?.soundWaveColor ?? Colors.green;

    return AnimatedBuilder(
      animation: _entranceController,
      builder: (_, __) {
        return Positioned(
          left: _position.dx,
          top: _position.dy,
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            onTap: _onRestore,
            // Lift on grab: scale only. Per perf guidance the (blurred) shadow
            // is NOT animated during the drag — only a cheap transform.
            child: AnimatedScale(
              scale: _dragging ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 120),
              child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value.clamp(0.0, 1.0),
                child: ValueListenableBuilder<bool>(
                  valueListenable: _isSpeakingNotifier,
                  builder: (_, isSpeaking, child) {
                    return _SoundWaveBorder(
                      isSpeaking: isSpeaking,
                      waveControllers: _waveControllers,
                      waveColor: waveColor,
                      borderRadius: borderRadius,
                      size: _overlaySize,
                      child: child!,
                    );
                  },
                  child: Container(
                    width: _overlaySize.width,
                    height: _overlaySize.height,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(borderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (roomImage != null && roomImage.isNotEmpty)
                            Image.network(
                              roomImage,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.black.withValues(alpha: 0.88),
                              ),
                            ),
                          Container(
                            color: Colors.black.withValues(alpha: 0.35),
                          ),
                          if (showLeave)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: _onClose,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.call_end,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          if (showMic)
                            Positioned(
                              bottom: 6,
                              right: 6,
                              child: _MicToggleButton(
                                controller: widget.controller,
                                onTap: _onMicToggle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ),
          ),
        );
      },
    );
  }
}

class _SoundWaveBorder extends StatelessWidget {
  final bool isSpeaking;
  final List<AnimationController> waveControllers;
  final Color waveColor;
  final double borderRadius;
  final Size size;
  final Widget child;

  const _SoundWaveBorder({
    required this.isSpeaking,
    required this.waveControllers,
    required this.waveColor,
    required this.borderRadius,
    required this.size,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSpeaking) return child;

    return Stack(
      alignment: Alignment.center,
      children: [
        for (int i = 0; i < waveControllers.length; i++)
          AnimatedBuilder(
            animation: waveControllers[i],
            builder: (_, __) {
              final scale = 1.0 + (waveControllers[i].value * 0.04 * (i + 1));
              final opacity =
                  (1.0 - waveControllers[i].value * 0.6).clamp(0.0, 1.0);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: size.width,
                  height: size.height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                      color: waveColor.withValues(alpha: opacity * 0.5),
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
        child,
      ],
    );
  }
}

class _MicToggleButton extends StatelessWidget {
  final UTDRoomController controller;
  final VoidCallback onTap;

  const _MicToggleButton({
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: controller.mutedParticipants,
      builder: (_, muted, __) {
        final localId = controller.localIdentity;
        final isMuted = localId != null && muted.contains(localId);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isMuted
                  ? Colors.red.withValues(alpha: 0.2)
                  : Colors.green.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isMuted ? Icons.mic_off : Icons.mic,
              color: isMuted ? Colors.red : Colors.green,
              size: 16,
            ),
          ),
        );
      },
    );
  }
}
