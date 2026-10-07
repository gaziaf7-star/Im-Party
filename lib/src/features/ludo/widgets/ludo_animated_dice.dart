import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/sound_service.dart';
import 'ludo_dice_dots_painter.dart';

/// Animated dice following game_u.md §1, §2, §3:
///
/// Timeline:
///   0ms      → tap, scale 0.9 (button press feedback)
///   100ms    → shake begins
///   150ms    → face cycling 1→4→2→6→3→5→FINAL
///   200–700ms → rotation tumble
///   700ms    → final number revealed
///   750ms    → bounce settle
///
/// Three combined effects (game_u.md §2):
///   A. Scale: 1.0 → 0.88 → 1.08 → 1.0
///   B. Rotation: 0° → 15° → -20° → 25° → -10° → 0°
///   C. Face cycling: 1→4→2→6→3→5→FINAL
class LudoAnimatedDice extends StatefulWidget {
  final int diceValue;
  final bool isRolling;
  final bool canRoll;
  final bool glowEnabled;

  /// Whose-ever turn it is to roll: the dice keeps a gentle wobble.
  final bool waiting;

  const LudoAnimatedDice({
    super.key,
    required this.diceValue,
    required this.isRolling,
    required this.canRoll,
    this.glowEnabled = true,
    this.waiting = false,
  });

  @override
  State<LudoAnimatedDice> createState() => _LudoAnimatedDiceState();
}

class _LudoAnimatedDiceState extends State<LudoAnimatedDice>
    with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late AnimationController _idle;

  // Dice animation curves (game_u.md §2)
  late Animation<double> _scaleAnim;
  late Animation<double> _rotateAnim;

  // Face cycling sequence: 1 → 4 → 2 → 6 → 3 → 5 → FINAL (game_u.md §2.C)
  static const List<int> _faceCycle = [1, 4, 2, 6, 3, 5];
  int _displayFace = 1;
  bool _wasRolling = false;

  @override
  void initState() {
    super.initState();
    _displayFace = widget.diceValue;

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Scale: 1.0 → 0.88 → 1.08 → 1.0  (game_u.md §2.A)
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.88), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.08), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    // Rotation: 0° → 15° → -20° → 25° → -10° → 0°  (game_u.md §2.B)
    _rotateAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 15.0 * math.pi / 180),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 15.0 * math.pi / 180, end: -20.0 * math.pi / 180),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -20.0 * math.pi / 180, end: 25.0 * math.pi / 180),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 25.0 * math.pi / 180, end: -10.0 * math.pi / 180),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -10.0 * math.pi / 180, end: 0.0),
        weight: 20,
      ),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    _idle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _syncIdle();

    _ctrl.addListener(_onAnimationTick);
    _ctrl.addStatusListener(_onAnimationStatus);
  }

  void _syncIdle() {
    final on = widget.waiting && !widget.isRolling;
    if (on && !_idle.isAnimating) {
      _idle.repeat(reverse: true);
    } else if (!on && _idle.isAnimating) {
      _idle.stop();
      _idle.value = 0;
    }
  }

  void _onAnimationTick() {
    // Face cycling while rolling: show cycling faces every ~16% of animation
    if (widget.isRolling) {
      final progress = _ctrl.value; // 0.0 → 1.0
      // cycle through 6 faces over first 85% of animation
      if (progress < 0.85) {
        final cycleIndex = (progress / 0.85 * _faceCycle.length).floor().clamp(
          0,
          _faceCycle.length - 1,
        );
        if (_displayFace != _faceCycle[cycleIndex]) {
          setState(() => _displayFace = _faceCycle[cycleIndex]);
        }
      } else {
        // Reveal final value in last 15%
        if (_displayFace != widget.diceValue) {
          setState(() => _displayFace = widget.diceValue);
        }
      }
    }
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() => _displayFace = widget.diceValue);
    }
  }

  @override
  void didUpdateWidget(LudoAnimatedDice old) {
    super.didUpdateWidget(old);
    _syncIdle();

    // Dice started rolling
    if (widget.isRolling && !_wasRolling) {
      _wasRolling = true;
      _displayFace = _faceCycle[0];
      _ctrl.forward(from: 0.0);
      SoundService.instance.playDiceRoll();
    }

    // Dice stopped rolling — reveal final value + bounce settle + result sound
    if (!widget.isRolling && _wasRolling) {
      _wasRolling = false;
      setState(() => _displayFace = widget.diceValue);
      // Small bounce settle (game_u.md: 750ms → bounce)
      _ctrl.animateTo(0.0, duration: const Duration(milliseconds: 100));
      SoundService.instance.playDiceResult();
      if (widget.diceValue == 6) {
        Future.delayed(
          const Duration(milliseconds: 150),
          SoundService.instance.playSixRoll,
        );
      }
    }

    // Whenever no animation is running the face must show the real value (the
    // result can arrive after the spin ended, and the spin may have revealed a
    // stale number).
    if (!_ctrl.isAnimating && _displayFace != widget.diceValue) {
      setState(() => _displayFace = widget.diceValue);
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onAnimationTick);
    _ctrl.removeStatusListener(_onAnimationStatus);
    _ctrl.dispose();
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_ctrl, _idle]),
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_idle.value);
        return Transform.rotate(
          angle: _rotateAnim.value + (t - 0.5) * 0.28,
          child: Transform.scale(
            scale: _scaleAnim.value * (1 + 0.07 * t),
            child: Container(
              width: 54.r,
              height: 54.r,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 2.w),
                boxShadow: [
                  const BoxShadow(
                    color: Color(0xFF94A3B8),
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                  if (widget.canRoll && widget.glowEnabled)
                    BoxShadow(
                      color: const Color(0xFF287BFF).withValues(alpha: 0.55),
                      blurRadius: 18,
                      spreadRadius: 3,
                    ),
                  if (widget.isRolling)
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: CustomPaint(
                painter: LudoDiceDotsPainter(value: _displayFace.clamp(1, 6)),
              ),
            ),
          ),
        );
      },
    );
  }
}
