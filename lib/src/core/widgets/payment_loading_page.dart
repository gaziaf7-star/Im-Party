import 'dart:math' as math;
import 'package:general/src/core/index.dart';

class PaymentLoadingPage extends StatefulWidget {
  const PaymentLoadingPage({super.key});

  @override
  State<PaymentLoadingPage> createState() => _PaymentLoadingPageState();
}

class _PaymentLoadingPageState extends State<PaymentLoadingPage>
    with TickerProviderStateMixin {
  late final AnimationController shimmerController;
  late final AnimationController spinController;

  @override
  void initState() {
    super.initState();

    shimmerController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    spinController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
  }

  @override
  void dispose() {
    shimmerController.dispose();
    spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final green = ColorManager.primary;

    return BackgroundImgWidget(
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔒 Lock Icon
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: shimmerController,
                      builder: (_, __) {
                        final opacity = 0.7 +
                            0.3 * math.sin(shimmerController.value * math.pi);
                        return CustomPaint(
                          size: const Size(50, 75),
                          painter: LockPainter(opacity: opacity, color: green),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 🧾 Payment Processing
              TextWidget(
                StringManager.processingPayment,
                style: TextStyle(
                  color: ColorManager.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              const TextWidget(
                StringManager.connectingSecureGateway,
                style: TextStyle(
                  color: Color(0xFF7F8C8D),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),

              // 🔄 Spinner
              RotationTransition(
                turns: spinController,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFFE0E0E0), width: 4),
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 4,
                      height: 25,
                      decoration: BoxDecoration(
                        color: ColorManager.primary,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(2),
                          bottomRight: Radius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              TextWidget(
                StringManager.doNotCloseWindow,
                style: TextStyle(
                  color: green,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),

              // 🛡️ Security Badge
              Column(
                children: [
                  const Divider(color: Color(0xFFECF0F1)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(16, 16),
                        painter: ShieldPainter(color: green),
                      ),
                      const SizedBox(width: 8),
                      const TextWidget(
                        StringManager.sslEncrypted,
                        style: TextStyle(
                          color: Color(0xFF95A5A6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LockPainter extends CustomPainter {
  final double opacity;
  final Color color;

  LockPainter({required this.opacity, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    // Lock Body
    final bodyRect =
        Rect.fromLTWH(size.width / 2 - 25, size.height - 40, 50, 40);
    final bodyRRect =
        RRect.fromRectAndRadius(bodyRect, const Radius.circular(8));
    canvas.drawRRect(bodyRRect, paint);

    // Shackle
    final shacklePaint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    final shackleRect = Rect.fromLTWH(size.width / 2 - 17.5, 5, 35, 30);
    final shacklePath = Path()..addArc(shackleRect, math.pi, math.pi);
    canvas.drawPath(shacklePath, shacklePaint);

    // Keyhole
    final keyholePaint = Paint()..color = Colors.white;
    final keyholeTop = Rect.fromCircle(
        center: Offset(size.width / 2, size.height - 20), radius: 4);
    final keyholeBottom =
        Rect.fromLTWH(size.width / 2 - 2, size.height - 16, 4, 8);
    canvas.drawOval(keyholeTop, keyholePaint);
    canvas.drawRect(keyholeBottom, keyholePaint);
  }

  @override
  bool shouldRepaint(covariant LockPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}

class ShieldPainter extends CustomPainter {
  final Color color;

  ShieldPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height * 0.25)
      ..lineTo(size.width, size.height * 0.75)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height * 0.75)
      ..lineTo(0, size.height * 0.25)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ShieldPainter oldDelegate) => false;
}
