import 'package:general/src/core/index.dart';

import 'rocket_realtime_controller.dart';

/// Floating banner card shown while the rocket launch animation plays: it
/// slides in smoothly from the left to the middle, stays for 9 seconds, then
/// slides back out to the left -- rocket image (left) + winner name (middle) +
/// winner avatar (right). Purely decorative: it never touches
/// [RocketRealtimeController.launchEvent] (the full-screen overlay owns that)
/// and starts together with the animation ([RocketRealtimeController
/// .launchAnimating]).
class RocketLaunchBanner extends StatelessWidget {
  const RocketLaunchBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: RocketRealtimeController.instance.launchAnimating,
      builder: (context, animating, _) => animating
          ? _banner(context)
          : const SizedBox.shrink(),
    );
  }

  Widget _banner(BuildContext context) {
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: RocketRealtimeController.instance.launchEvent,
      builder: (context, data, _) {
        if (data == null) return const SizedBox.shrink();

        final winnersRaw = data['winners'];
        final winners = winnersRaw is List
            ? winnersRaw.whereType<Map>().toList()
            : const <Map>[];
        final topWinner =
        winners.isNotEmpty ? Map<String, dynamic>.from(winners.first) : null;

        final level = data['level'];
        final levelMap = level is Map ? Map<String, dynamic>.from(level) : null;
        final rocketImage = (levelMap?['rocket_image'] ??
            levelMap?['platform_image'] ??
            '')
            .toString();

        return Positioned(
          top: 20.h,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: _RocketBannerBody(
              key: ValueKey('${data['event_id'] ?? data['launch_id']}'),
              name: (topWinner?['name'] ?? '').toString(),
              profileImage: RocketRealtimeController.profileUrl(
                  topWinner?['profile_image'],
                  label: 'banner winner'),
              rocketImage: rocketImage,
            ),
          ),
        );
      },
    );
  }
}

class _RocketBannerBody extends StatefulWidget {
  final String name;
  final String profileImage;
  final String rocketImage;

  const _RocketBannerBody({
    super.key,
    required this.name,
    required this.profileImage,
    required this.rocketImage,
  });

  @override
  State<_RocketBannerBody> createState() => _RocketBannerBodyState();
}

class _RocketBannerBodyState extends State<_RocketBannerBody>
    with SingleTickerProviderStateMixin {
  // 0.6s slide in + 9s hold + 0.4s slide out, matching the ~10s launch
  // animation so both start and end together.
  static const _totalDuration = Duration(seconds: 10);

  late final AnimationController _controller;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _totalDuration)
      ..forward();
    _slide = TweenSequence<Offset>([
      // Slide in from off-screen left to the middle.
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(-1.4, 0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 6,
      ),
      // Hold in the middle for 9 seconds.
      TweenSequenceItem(tween: ConstantTween<Offset>(Offset.zero), weight: 90),
      // Slide back out to the left.
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset.zero, end: const Offset(-1.4, 0))
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 4,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.isCompleted) return const SizedBox.shrink();
        return SlideTransition(
          position: _slide,
          child: _bannerContent(context, screenWidth),
        );
      },
    );
  }

  Widget _bannerContent(BuildContext context, double screenWidth) {
    // Narrower floating card (not edge-to-edge) and taller than the first
    // pass, matching a typical game-win/lucky-box banner card proportions
    // instead of a stretched full-width strip.
    final bannerWidth = (screenWidth * 0.78).clamp(260.0, 330.0);
    const bannerHeight = 96.0;

    return Center(
      child: Container(
        width: bannerWidth,
        height: bannerHeight.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CacheSvgaWidget(
                url: AssetsManager.giftBanner1,
                isAsset: true,
                width: bannerWidth,
                height: bannerHeight.h,
                boxFit: BoxFit.cover,
              ),
              // Responsive content: every size is a fraction of the banner, so
              // it scales with the card. The green plate of the SVGA sits
              // below the crown/wings, so the content starts ~30% down and
              // keeps clear of the left/right wing ornaments.
              LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth;
                  final h = c.maxHeight;
                  // Small picture + rocket so everything stays inside the green
                  // plate (the plate starts ~30% down).
                  final contentH = h * 0.34;
                  final rocketH = h * 0.46;
                  return Padding(
                    padding: EdgeInsets.fromLTRB(w * 0.17, h * 0.32, w * 0.17, h * 0.12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Winner picture on the left.
                        // Hard size box + clip: it can never spill out of the card.
                        // Nudged down a little inside the plate.
                        Transform.translate(
                          offset: Offset(0, h * 0.05),
                          child: SizedBox(
                            width: contentH,
                            height: contentH,
                            child: ClipOval(
                              child: UserImage(
                                image: widget.profileImage,
                                displayName: widget.name,
                                imageSize: contentH,
                                uniquId: widget.name,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: w * 0.03),
                        // Name on top, caption under it.
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name at the top of the plate, a bit lower than
                              // the very edge.
                              SizedBox(height: h * 0.09),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: TextWidget(
                                  widget.name,
                                  maxLines: 1,
                                  style: context.bodyMedium.w800
                                      .colorExt(ColorManager.white),
                                ),
                              ),
                              SizedBox(height: h * 0.005),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: TextWidget(
                                  'Rocket launched',
                                  maxLines: 1,
                                  style: context.bodySmall.w600.colorExt(
                                      ColorManager.white
                                          .withValues(alpha: 0.85)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: w * 0.03),
                        // Rocket on the right.
                        if (widget.rocketImage.isNotEmpty)
                          ImageViewWidget(
                            url: widget.rocketImage,
                            height: rocketH,
                            width: rocketH,
                            boxFit: BoxFit.contain,
                          ),
                      ],
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
