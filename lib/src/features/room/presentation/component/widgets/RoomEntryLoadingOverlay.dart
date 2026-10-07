import 'package:general/src/core/index.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// Full-screen branded "setting up your live" cover.
///
/// Placed as the TOPMOST layer of [ForegroundWidget]'s stack while the room
/// engine is still connecting, so it covers whatever the underlying
/// closed-source room kit renders on its own while joining -- replacing the
/// plain/bare connecting spinner with a proper, on-brand loading screen, on
/// request ("ami chai amar akhna akta primuim live create page dhakba
/// loading a, akta profational live ar moto"). Deliberately reuses the exact
/// splash-screen branding (logo scale/fade, gradient wordmark, tagline,
/// threeArchedCircle spinner) so the create → connect → enter flow reads as
/// one polished sequence instead of two different loading looks back to
/// back. It disappears the instant the room reports connected; the room
/// itself was already mounting/joining underneath the whole time, so this
/// only changes what's ON SCREEN during that wait, never the timing of it.
class RoomEntryLoadingOverlay extends StatefulWidget {
  const RoomEntryLoadingOverlay({super.key});

  @override
  State<RoomEntryLoadingOverlay> createState() =>
      _RoomEntryLoadingOverlayState();
}

class _RoomEntryLoadingOverlayState extends State<RoomEntryLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );
    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _logoController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.white,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            final logoSize = (width * 0.29).clamp(100.0, 145.0);
            final nameSize = (width * 0.08).clamp(24.0, 34.0);
            final centerTop = (height * 0.28).clamp(140.0, 260.0);

            return Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: Colors.white),

                // Soft central glow behind the app logo -- same treatment as
                // the app splash screen.
                Positioned(
                  top: centerTop - 54,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: logoSize + 100,
                      height: logoSize + 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFFF4BC8).withValues(alpha: 0.075),
                            const Color(0xFF7F5BFF).withValues(alpha: 0.045),
                            const Color(0xFF22C7FF).withValues(alpha: 0.015),
                            Colors.transparent,
                          ],
                        ),
                      ),
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
                            padding: EdgeInsets.all(logoSize * 0.025),
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

                      SizedBox(height: (height * 0.02).clamp(14.0, 22.0)),

                      FadeTransition(
                        opacity: _logoOpacity,
                        child: ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) {
                            return const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFFEC24C8),
                                Color(0xFF8B4EF5),
                                Color(0xFF2AB8FF),
                              ],
                            ).createShader(bounds);
                          },
                          child: Text(
                            'Setting up your live...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: nameSize,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: (height * 0.01).clamp(6.0, 12.0)),

                      FadeTransition(
                        opacity: _logoOpacity,
                        child: Text(
                          'Just a moment while we connect you',
                          style: TextStyle(
                            color:
                            const Color(0xFF8C8C98).withValues(alpha: 0.9),
                            fontSize: (width * 0.033).clamp(12.0, 14.0),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const Spacer(),

                      Padding(
                        padding: EdgeInsets.only(
                          bottom: (height * 0.06).clamp(32.0, 58.0),
                        ),
                        child: LoadingAnimationWidget.threeArchedCircle(
                          color: const Color(0xFF8D4AF4),
                          size: (width * 0.085).clamp(28.0, 38.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}