import 'dart:math' as math show pi;
import 'package:general/src/core/index.dart';

class GameLoadingScreen extends StatefulWidget {
  const GameLoadingScreen({super.key});

  @override
  State<GameLoadingScreen> createState() => _GameLoadingScreenState();
}

class _GameLoadingScreenState extends State<GameLoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController pulseController;
  late final AnimationController rotateController;
  late final AnimationController glowController;

  @override
  void initState() {
    super.initState();

    pulseController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    rotateController =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();

    glowController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    pulseController.dispose();
    rotateController.dispose();
    glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: ColorManager.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: ColorManager.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // 🔵 Rotating circular light ring
                  AnimatedBuilder(
                    animation: rotateController,
                    builder: (context, _) {
                      return Transform.rotate(
                        angle: rotateController.value * 2 * math.pi,
                        child: CustomPaint(
                          painter: _CircularArcPainter(),
                          size: const Size(150, 150),
                        ),
                      );
                    },
                  ),

                  // ✨ Glowing inner pulse
                  AnimatedBuilder(
                    animation: glowController,
                    builder: (context, _) {
                      final glow = 0.4 + glowController.value * 0.6;
                      return Container(
                        width: 80 + glowController.value * 10,
                        height: 80 + glowController.value * 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: glow),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(
                          Icons.sports_esports_rounded,
                          color: Colors.white,
                          size: 50,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // 🎯 Text: Loading Game
              FadeTransition(
                opacity: pulseController,
                child:  TextWidget(
                  StringManager.loadingGame,
                  style: TextStyle(
                    color: ColorManager.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    shadows: const [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.white24,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ⏳ Please wait...
              AnimatedBuilder(
                animation: pulseController,
                builder: (context, _) {
                  final dotsCount = (pulseController.value * 3).floor() + 1;
                  final dots = '.' * dotsCount;
                  return TextWidget(
                    "${StringManager.pleaseWaitGameLoading.tr()}$dots",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🎨 Painter for glowing rotating ring
class _CircularArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..shader = SweepGradient(
        colors: [
          Colors.white.withValues(alpha: 0.2),
          Colors.white,
          Colors.white.withValues(alpha: 0.2),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
          Rect.fromCircle(center: size.center(Offset.zero), radius: 70));

    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: 70),
      0,
      2 * math.pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
