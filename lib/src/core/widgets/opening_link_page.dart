import 'dart:math' as math;
import 'package:general/src/core/index.dart';

class OpeningLinkPage extends StatefulWidget {
  const OpeningLinkPage({super.key});

  @override
  State<OpeningLinkPage> createState() => _OpeningLinkPageState();
}

class _OpeningLinkPageState extends State<OpeningLinkPage>
    with TickerProviderStateMixin {
  late AnimationController _windowController;
  late AnimationController _rotateController;
  late AnimationController _dot1Controller;
  late AnimationController _dot2Controller;
  late AnimationController _dot3Controller;

  late Animation<double> _windowAnimation;

  @override
  void initState() {
    super.initState();

    // Window pop animation
    _windowController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _windowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.05)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
    ]).animate(_windowController);

    // Globe rotation
    _rotateController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Dot animations
    _dot1Controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();

    _dot2Controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();

    _dot3Controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();

    // Start animations with delays
    _windowController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _dot2Controller.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _dot3Controller.forward();
    });
  }

  @override
  void dispose() {
    _windowController.dispose();
    _rotateController.dispose();
    _dot1Controller.dispose();
    _dot2Controller.dispose();
    _dot3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImgWidget(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔹 Animated Browser Window
              AnimatedBuilder(
                animation: _windowAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _windowController.value,
                    child: Transform.scale(
                      scale: _windowAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: _buildBrowserIcon(),
              ),

              const SizedBox(height: 30),

              // 🔹 Titles
              TextWidget(
                StringManager.openingLink,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              TextWidget(
                StringManager.launchingDefaultBrowser,
                style: TextStyle(
                  fontSize: 15,
                  color: ColorManager.secondaryText,
                ),
              ),

              const SizedBox(height: 30),

              // 🔹 External Link Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: ColorManager.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLinkIcon(),
                    const SizedBox(width: 8),
                    TextWidget(
                      StringManager.externalLink,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ColorManager.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // 🔹 Loading Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLoadingDot(_dot1Controller),
                  const SizedBox(width: 8),
                  _buildLoadingDot(_dot2Controller),
                  const SizedBox(width: 8),
                  _buildLoadingDot(_dot3Controller),
                ],
              ),

              const SizedBox(height: 12),

              // 🔹 Status
              TextWidget(
                StringManager.pleaseWaitAMoment,
                style: TextStyle(
                  fontSize: 14,
                  color: ColorManager.secondaryText,
                ),
              ),

              const SizedBox(height: 40),

              // 🔹 Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextWidget(
                  StringManager.redirectExternalSite,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: ColorManager.secondaryText,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrowserIcon() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Browser Header
            Container(
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFFE8EAED),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  _buildBrowserDot(const Color(0xFFFF5F57)),
                  const SizedBox(width: 6),
                  _buildBrowserDot(const Color(0xFFFFBD2E)),
                  const SizedBox(width: 6),
                  _buildBrowserDot(const Color(0xFF28CA42)),
                ],
              ),
            ),
            // Browser Content
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _rotateController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotateController.value * 2 * math.pi,
                      child: child,
                    );
                  },
                  child: _buildGlobeIcon(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowserDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildGlobeIcon() {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          // Circle border
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ColorManager.primary,
                width: 3,
              ),
            ),
          ),
          // Horizontal line
          Center(
            child: Container(
              width: 40,
              height: 2,
              color: ColorManager.primary,
            ),
          ),
          // Vertical line
          Center(
            child: Container(
              width: 2,
              height: 40,
              color: ColorManager.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkIcon() {
    return SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: ColorManager.primary, width: 2),
                  right: BorderSide(color: ColorManager.primary, width: 2),
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: ColorManager.primary, width: 2),
                  left: BorderSide(color: ColorManager.primary, width: 2),
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingDot(AnimationController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double value = controller.value;
        double scale;
        double opacity;

        if (value < 0.4) {
          scale = 0.8 + (value / 0.4) * 0.4;
          opacity = 0.5 + (value / 0.4) * 0.5;
        } else if (value < 0.8) {
          scale = 1.2 - ((value - 0.4) / 0.4) * 0.4;
          opacity = 1.0 - ((value - 0.4) / 0.4) * 0.5;
        } else {
          scale = 0.8;
          opacity = 0.5;
        }

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: ColorManager.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}
