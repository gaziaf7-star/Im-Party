import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:general/src/core/index.dart';

/// "Congratulations on getting" popup shown after claiming a daily reward:
/// golden title, the reward card on a rotating light burst, a golden Confirm
/// button and a close (X) under it, over a light see-through backdrop. Plays
/// the claim sound when it opens.
class DailyPrizePicked extends StatefulWidget {
  final String image;
  final String name;

  const DailyPrizePicked({
    super.key,
    required this.image,
    required this.name,
  });

  static const String _sound = 'sounds/daily_reward_claim.mp3';

  /// Opens the popup with its light backdrop.
  static Future<void> show(
    BuildContext context, {
    required String image,
    required String name,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
        child: DailyPrizePicked(image: image, name: name),
      ),
    );
  }

  @override
  State<DailyPrizePicked> createState() => _DailyPrizePickedState();
}

class _DailyPrizePickedState extends State<DailyPrizePicked>
    with TickerProviderStateMixin {
  static const _goldLight = Color(0xFFFFF6B0);
  static const _gold = Color(0xFFFFD43B);
  static const _goldDeep = Color(0xFFE9A400);
  static const _brown = Color(0xFF5A3400);

  late final AnimationController _rays = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  )..forward();

  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playSound();
  }

  Future<void> _playSound() async {
    try {
      await _player.setVolume(0.9);
      await _player.play(AssetSource(DailyPrizePicked._sound));
    } catch (_) {
      // Sound is decoration only.
    }
  }

  @override
  void dispose() {
    _rays.dispose();
    _pop.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width * 0.86).clamp(260.0, 360.0);
    final burst = width * 0.95;
    final card = width * 0.4;

    return ScaleTransition(
      scale: CurvedAnimation(parent: _pop, curve: Curves.easeOutBack),
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _title(width),
            SizedBox(
              width: burst,
              height: burst * 0.78,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Rotating golden light burst behind the card.
                  AnimatedBuilder(
                    animation: _rays,
                    builder: (_, __) => Transform.rotate(
                      angle: _rays.value * 2 * math.pi,
                      child: CustomPaint(
                        size: Size.square(burst),
                        painter: _RaysPainter(),
                      ),
                    ),
                  ),
                  Container(
                    width: burst * 0.6,
                    height: burst * 0.6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        _goldLight.withValues(alpha: 0.85),
                        _gold.withValues(alpha: 0.25),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                  _rewardCard(card),
                ],
              ),
            ),
            _confirmButton(width),
            SizedBox(height: 18.h),
            _closeButton(),
          ],
        ),
      ),
    );
  }

  Widget _title(double width) {
    return ShaderMask(
      shaderCallback: (r) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_goldLight, _gold, _goldDeep],
      ).createShader(r),
      child: Text(
        'Congratulations on getting',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: width * 0.085,
          fontWeight: FontWeight.w900,
          height: 1.15,
          shadows: [
            Shadow(
              color: _brown.withValues(alpha: 0.55),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rewardCard(double size) {
    final name = widget.name.trim();
    final label = name.isEmpty
        ? ''
        : (num.tryParse(name) != null ? 'x $name' : name);
    return Container(
      width: size,
      height: size * 1.12,
      padding: EdgeInsets.all(size * 0.08),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.55),
            _goldLight.withValues(alpha: 0.55),
          ],
        ),
        border: Border.all(color: _gold, width: 2),
        boxShadow: [
          BoxShadow(color: _gold.withValues(alpha: 0.6), blurRadius: 18),
        ],
      ),
      child: Column(
        children: [
          Expanded(child: Center(child: _image(size * 0.7))),
          if (label.isNotEmpty)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: _brown,
                  fontSize: size * 0.13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _image(double size) {
    final image = widget.image;
    if (image.isEmpty) {
      return Icon(Icons.card_giftcard_rounded, size: size, color: _goldDeep);
    }
    if (image.contains('.svga') || image.contains('.zz')) {
      return CacheSvgaWidget(
        isStopErrorAndLoadingFrame: false,
        url: image,
        width: size,
        height: size,
        boxFit: BoxFit.contain,
      );
    }
    return ImageViewWidget(
      url: image,
      width: size,
      height: size,
      boxFit: BoxFit.contain,
    );
  }

  Widget _confirmButton(double width) {
    final w = width * 0.68;
    final h = w * 0.22;
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: w,
        height: h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(h / 2),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_goldLight, _gold, _goldDeep],
            stops: [0, 0.45, 1],
          ),
          border: Border.all(color: const Color(0xFFFFFBE3), width: 2),
          boxShadow: [
            BoxShadow(color: _gold.withValues(alpha: 0.7), blurRadius: 16),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          StringManager.confirm.tr(),
          style: TextStyle(
            color: _brown,
            fontSize: h * 0.42,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _closeButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.25),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.8), width: 1.5),
        ),
        child: const Icon(Icons.close_rounded, size: 20, color: Colors.white),
      ),
    );
  }
}

/// Soft golden light rays fanning out from the centre.
class _RaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    const count = 14;
    final paint = Paint()
      ..shader = RadialGradient(colors: [
        const Color(0xFFFFE680).withValues(alpha: 0.7),
        const Color(0xFFFFD43B).withValues(alpha: 0.0),
      ]).createShader(Rect.fromCircle(center: c, radius: r));
    for (var i = 0; i < count; i++) {
      final a = i * 2 * math.pi / count;
      const half = math.pi / count / 2.2;
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx + r * math.cos(a - half), c.dy + r * math.sin(a - half))
        ..lineTo(c.dx + r * math.cos(a + half), c.dy + r * math.sin(a + half))
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
