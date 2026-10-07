import 'dart:math';

import 'package:general/src/core/index.dart';

import 'live_taps_controller.dart';

/// Floating tap-hearts layer: every spawn event from [LiveTapsController]
/// becomes ONE emoji that rises from the BOTTOM-LEFT corner of the screen
/// (owner spec 2026-06-12 — the physical left, in RTL too) with a sway,
/// starting fully vivid and fading out gradually until it disappears.
/// Renders at most [LiveTapsController.maxConcurrentHearts] at once — extra
/// taps still count, they just don't add more sprites (battery).
class LiveTapHeartsOverlay extends StatefulWidget {
  const LiveTapHeartsOverlay({super.key});

  @override
  State<LiveTapHeartsOverlay> createState() => _LiveTapHeartsOverlayState();
}

class _Heart {
  final int id;
  final String emoji;
  final double xJitter; // start-x offset
  final double swayPhase;
  final double size;
  const _Heart(this.id, this.emoji, this.xJitter, this.swayPhase, this.size);
}

class _LiveTapHeartsOverlayState extends State<LiveTapHeartsOverlay> {
  static const List<String> _emojis = ['❤️', '🧡', '💛', '💚', '💙', '💜', '👍', '🌹'];

  final List<_Heart> _hearts = [];
  int _nextId = 0;
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    LiveTapsController.instance.heartSpawns.addListener(_onSpawn);
  }

  @override
  void dispose() {
    LiveTapsController.instance.heartSpawns.removeListener(_onSpawn);
    super.dispose();
  }

  void _onSpawn() {
    if (!mounted) return;
    if (_hearts.length >= LiveTapsController.maxConcurrentHearts) return;
    final seed = LiveTapsController.instance.lastSpawnSeed;
    setState(() {
      _hearts.add(_Heart(
        _nextId++,
        _emojis[seed % _emojis.length],
        _rng.nextDouble() * 36,
        _rng.nextDouble() * pi * 2,
        24 + _rng.nextDouble() * 10,
      ));
    });
  }

  void _remove(int id) {
    if (!mounted) return;
    setState(() => _hearts.removeWhere((h) => h.id == id));
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          for (final h in _hearts)
            _RisingHeart(
              key: ValueKey('tap_heart_${h.id}'),
              heart: h,
              onDone: () => _remove(h.id),
            ),
        ],
      ),
    );
  }
}

class _RisingHeart extends StatefulWidget {
  final _Heart heart;
  final VoidCallback onDone;

  const _RisingHeart({super.key, required this.heart, required this.onDone});

  @override
  State<_RisingHeart> createState() => _RisingHeartState();
}

class _RisingHeartState extends State<_RisingHeart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..forward().whenCompleteOrCancel(widget.onDone);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.heart;
    final screenH = MediaQuery.sizeOf(context).height;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        final rise = Curves.easeOut.transform(t) * screenH * 0.55;
        final sway = sin(h.swayPhase + t * pi * 3) * 16;
        // Vivid at launch, then a continuous fade-out for the whole flight
        // (slow at first, faster near the top) until it disappears.
        final opacity = 1.0 - Curves.easeIn.transform(t);
        final scale = 0.7 + min(t * 4, 1.0) * 0.5;
        return Positioned(
          // Launches from the physical bottom-left corner (not the reading
          // edge — in RTL "start" would be the right) and rises upward.
          bottom: 10 + rise,
          left: 18 + h.xJitter + sway,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: scale,
              child: Text(h.emoji, style: TextStyle(fontSize: h.size)),
            ),
          ),
        );
      },
    );
  }
}

/// Small live counter chip (❤ 12.4K) shown inside the live room.
class LiveTapsCounterChip extends StatelessWidget {
  const LiveTapsCounterChip({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: LiveTapsController.instance.displayTotal,
      builder: (context, total, _) {
        if (total <= 0) return const SizedBox.shrink();
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: ColorManager.black.withValues(alpha: 0.35),
            borderRadius: 12.radius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('❤️', style: TextStyle(fontSize: 11.sp)),
              4.wBox,
              TextWidget(
                Methods().convertToAbbreviatedString(total),
                style: context.bodySmall.w600
                    .colorExt(ColorManager.white)
                    .size(11),
              ),
            ],
          ),
        );
      },
    );
  }
}
