import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/auth/presentation/splash/config_app/config_app_bloc.dart';
import 'package:ipapi/ipapi.dart';
import 'package:ipapi/models/geo_data.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  bool _hasNavigated = false;
  StreamSubscription<ConfigAppState>? _configSubscription;

  // Drives the one-shot staggered entrance: logo -> name -> tagline -> loader.
  late final AnimationController _introController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _nameSlide;
  late final Animation<double> _nameOpacity;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _loaderOpacity;

  // Slow ambient breathing glow behind the logo, loops for as long as the
  // splash is on screen so it never feels static while config loads.
  late final AnimationController _glowController;

  // Soft light sweep across the wordmark, purely a premium visual touch.
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    _logoScale = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
    );

    _logoOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    _nameSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.32, 0.68, curve: Curves.easeOutCubic),
      ),
    );

    _nameOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.32, 0.68, curve: Curves.easeOut),
    );

    _taglineOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.55, 0.85, curve: Curves.easeOut),
    );

    _loaderOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    );

    _introController.forward();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    if (Platform.isAndroid) {
      ConstantsManager.devicePlatform = StringManager.android;
    } else if (Platform.isIOS) {
      ConstantsManager.devicePlatform = StringManager.ios;
    }

    di<ConfigAppBloc>().add(
      ConfigAppEvent(
        devicePLATFORM: ConstantsManager.devicePlatform,
        versionApp: ConstantsManager.appVersionCode.toString(),
      ),
    );

    // Keep the existing splash navigation flow unchanged.
    _listenToConfigAndNavigate();

    // Keep the existing location bootstrap unchanged.
    _initLocation();
  }

  void _listenToConfigAndNavigate() {
    final configBloc = di<ConfigAppBloc>();

    if (configBloc.state.requestState.isLoaded ||
        configBloc.state.requestState.isEmpty ||
        configBloc.state.requestState.isError) {
      if (!_hasNavigated) {
        _hasNavigated = true;
        context.read<SplashBloc>().add(const SplashNavigationEvent());
      }
      return;
    }

    _configSubscription = configBloc.stream.listen((state) {
      if (state.requestState.isLoaded ||
          state.requestState.isEmpty ||
          state.requestState.isError) {
        if (!_hasNavigated) {
          _hasNavigated = true;
          context.read<SplashBloc>().add(const SplashNavigationEvent());
        }
        _configSubscription?.cancel();
      }
    });
  }

  Future<void> _initLocation() async {
    try {
      GeoData? geoData;
      geoData = await IpApi.getData();

      ConstantsManager.updateLocation(
        latitude: geoData?.lat ?? 0.0,
        longitude: geoData?.lon ?? 0.0,
        isoCode: geoData?.countryCode ?? "unknown",
      );
    } catch (e) {
      debugPrint('Error fetching location data: $e');
      ConstantsManager.updateLocation(
        latitude: 0.0,
        longitude: 0.0,
        isoCode: "unknown",
      );
    }
  }

  @override
  void dispose() {
    _configSubscription?.cancel();
    _introController.dispose();
    _glowController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SplashBloc, SplashState>(
      buildWhen: (prev, curr) => prev != curr,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              final logoSize = (width * 0.29).clamp(100.0, 145.0);
              final nameSize = (width * 0.095).clamp(30.0, 46.0);
              final centerTop = (height * 0.30).clamp(180.0, 310.0);

              return Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: Colors.white),

                  // Premium white background with very subtle logo-inspired
                  // party shapes. No image asset is required for this layer.
                  IgnorePointer(
                    child: CustomPaint(
                      painter: _ImPartySplashPatternPainter(),
                    ),
                  ),

                  // Soft central glow behind the app logo, breathing gently
                  // so the splash still feels alive while config loads.
                  Positioned(
                    top: centerTop - 54,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _glowController,
                        builder: (context, child) {
                          final t = Curves.easeInOut.transform(
                            _glowController.value,
                          );
                          final glowSize = logoSize + 100 + (t * 22);
                          final glowStrength = 0.85 + (t * 0.3);

                          return Container(
                            width: glowSize,
                            height: glowSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFFFF4BC8).withValues(
                                    alpha: 0.075 * glowStrength,
                                  ),
                                  const Color(0xFF7F5BFF).withValues(
                                    alpha: 0.045 * glowStrength,
                                  ),
                                  const Color(0xFF22C7FF).withValues(
                                    alpha: 0.015 * glowStrength,
                                  ),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  SafeArea(
                    child: Column(
                      children: [
                        SizedBox(height: centerTop),

                        FadeTransition(
                          opacity: _logoOpacity,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: Container(
                              width: logoSize,
                              height: logoSize,
                              padding: EdgeInsets.all((logoSize * 0.025)),
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(logoSize * 0.24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF7A3DF0)
                                        .withValues(alpha: 0.16),
                                    blurRadius: 34,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 12),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF24C7FF)
                                        .withValues(alpha: 0.10),
                                    blurRadius: 28,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius:
                                BorderRadius.circular(logoSize * 0.22),
                                child: Image.asset(
                                  AssetsManager.logo,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: (height * 0.025).clamp(18.0, 28.0)),

                        FadeTransition(
                          opacity: _nameOpacity,
                          child: SlideTransition(
                            position: _nameSlide,
                            child: AnimatedBuilder(
                              animation: _shimmerController,
                              builder: (context, child) {
                                // Sweeps a light highlight left-to-right over
                                // the brand gradient on a loop.
                                final sweep = _shimmerController.value;
                                return ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: const [
                                        Color(0xFFEC24C8),
                                        Color(0xFF8B4EF5),
                                        Color(0xFF2AB8FF),
                                        Colors.white,
                                        Color(0xFF2AB8FF),
                                        Color(0xFF8B4EF5),
                                        Color(0xFFEC24C8),
                                      ],
                                      stops: [
                                        0.0,
                                        0.18,
                                        0.36,
                                        (0.36 + sweep * 1.1).clamp(0.36, 1.0),
                                        (0.52 + sweep * 1.1).clamp(0.52, 1.0),
                                        (0.7 + sweep * 1.1).clamp(0.7, 1.0),
                                        1.0,
                                      ],
                                    ).createShader(bounds);
                                  },
                                  child: child,
                                );
                              },
                              child: Text(
                                'Im Party',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: nameSize,
                                  height: 1,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.1,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: const Color(0xFF8E4CF1)
                                          .withValues(alpha: 0.14),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: (height * 0.012).clamp(8.0, 14.0)),

                        FadeTransition(
                          opacity: _taglineOpacity,
                          child: Text(
                            'Connect • Live • Celebrate',
                            style: TextStyle(
                              color:
                              const Color(0xFF8C8C98).withValues(alpha: 0.9),
                              fontSize: (width * 0.035).clamp(12.0, 15.0),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.25,
                            ),
                          ),
                        ),

                        const Spacer(),

                        FadeTransition(
                          opacity: _loaderOpacity,
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: (height * 0.055).clamp(32.0, 58.0),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                LoadingAnimationWidget.threeArchedCircle(
                                  color: const Color(0xFF8D4AF4),
                                  size: (width * 0.085).clamp(28.0, 38.0),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Getting things ready...',
                                  style: TextStyle(
                                    color: const Color(0xFFA2A2AE),
                                    fontSize:
                                    (width * 0.031).clamp(11.5, 13.5),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _ImPartySplashPatternPainter extends CustomPainter {
  const _ImPartySplashPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(27);

    final patternColors = <Color>[
      const Color(0xFFFF3FC7).withValues(alpha: 0.035),
      const Color(0xFF8655FF).withValues(alpha: 0.032),
      const Color(0xFF20C9FF).withValues(alpha: 0.03),
      const Color(0xFFFFB632).withValues(alpha: 0.034),
    ];

    final cellW = size.width / 4.5;
    final cellH = size.height / 8.5;

    for (int row = 0; row < 10; row++) {
      for (int col = 0; col < 6; col++) {
        final dx = col * cellW +
            (row.isOdd ? cellW * 0.45 : 0) +
            random.nextDouble() * 8;
        final dy = row * cellH + random.nextDouble() * 10;

        if (dx > size.width || dy > size.height) continue;

        final color = patternColors[(row + col) % patternColors.length];
        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6;

        final radius = 10.0 + random.nextDouble() * 6.0;

        switch ((row + col) % 4) {
          case 0:
            _drawStar(canvas, Offset(dx, dy), radius, paint);
            break;
          case 1:
            canvas.drawCircle(Offset(dx, dy), radius, paint);
            canvas.drawCircle(
              Offset(dx, dy),
              radius * 0.48,
              paint..strokeWidth = 1.2,
            );
            break;
          case 2:
            _drawSparkle(canvas, Offset(dx, dy), radius, paint);
            break;
          default:
            _drawPartyRing(canvas, Offset(dx, dy), radius, paint);
        }
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();

    for (int i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + i * math.pi / 5;
      final r = i.isEven ? radius : radius * 0.45;
      final point = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawSparkle(
      Canvas canvas,
      Offset center,
      double radius,
      Paint paint,
      ) {
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(
        center.dx + radius * 0.18,
        center.dy - radius * 0.18,
        center.dx + radius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx + radius * 0.18,
        center.dy + radius * 0.18,
        center.dx,
        center.dy + radius,
      )
      ..quadraticBezierTo(
        center.dx - radius * 0.18,
        center.dy + radius * 0.18,
        center.dx - radius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx - radius * 0.18,
        center.dy - radius * 0.18,
        center.dx,
        center.dy - radius,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  void _drawPartyRing(
      Canvas canvas,
      Offset center,
      double radius,
      Paint paint,
      ) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, -0.25, 1.9, false, paint);
    canvas.drawArc(rect, 2.85, 1.3, false, paint);

    final dotPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx + radius * 0.72, center.dy - radius * 0.70),
      2.4,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}