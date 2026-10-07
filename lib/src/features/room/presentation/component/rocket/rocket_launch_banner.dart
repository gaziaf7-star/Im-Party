import 'package:general/src/core/index.dart';

import 'rocket_realtime_controller.dart';

/// Floating top banner card shown the moment a rocket launches: slides in
/// from the right, holds at the top for the same 7s as
/// [RocketLaunchOverlay]'s flight animation, then slides out to the left --
/// mirroring the Lucky Box banner's slide-in/pause/slide-out shape (see
/// `show_lucky_banner_widget.dart`), just re-timed to 7s and content swapped
/// for the rocket image (left) + winner name/countdown (middle) + winner
/// avatar (right). Purely decorative: hides itself when its own animation
/// finishes and never touches [RocketRealtimeController.launchEvent] (the
/// full-screen overlay owns that).
class RocketLaunchBanner extends StatelessWidget {
  const RocketLaunchBanner({super.key});

  @override
  Widget build(BuildContext context) {
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
              profileImage: (topWinner?['profile_image'] ?? '').toString(),
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
  // Matches RocketLaunchOverlay's `_flightDuration` so the banner's slide and
  // the full-screen flight countdown start and end together.
  static const _totalDuration = Duration(seconds: 7);

  late final AnimationController _controller;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _totalDuration)
      ..forward();
    _slide = TweenSequence<Offset>([
      // Slide in from off-screen right.
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(1.4, 0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 12,
      ),
      // Hold in place at the top.
      TweenSequenceItem(tween: ConstantTween<Offset>(Offset.zero), weight: 76),
      // Slide out to off-screen left.
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset.zero, end: const Offset(-1.4, 0))
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 12,
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
        final secondsLeft =
        (7 * (1 - _controller.value)).ceil().clamp(0, 7);
        return SlideTransition(
          position: _slide,
          child: _bannerContent(context, screenWidth, secondsLeft),
        );
      },
    );
  }

  Widget _bannerContent(BuildContext context, double screenWidth, int secondsLeft) {
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
                url: AssetsManager.newGamesBannerSVGA,
                isAsset: true,
                width: bannerWidth,
                height: bannerHeight.h,
                boxFit: BoxFit.cover,
              ),
              Padding(
                // Shift all banner foreground content slightly downward so the
                // rocket, text and profile sit visually centered under the
                // crown/top glow of the SVGA banner.
                padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 6.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.rocketImage.isNotEmpty)
                      ImageViewWidget(
                        url: widget.rocketImage,
                        height: 54.h,
                        width: 54.h,
                        boxFit: BoxFit.contain,
                      ),
                    10.wBox,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextWidget(
                            widget.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.bodyMedium.w800
                                .colorExt(ColorManager.white),
                          ),
                          2.hBox,
                          TextWidget(
                            'Launching in ${secondsLeft}s',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.bodySmall.w600.colorExt(
                                ColorManager.white.withValues(alpha: 0.85)),
                          ),
                        ],
                      ),
                    ),
                    8.wBox,
                    UserImage(
                      image: widget.profileImage,
                      displayName: widget.name,
                      imageSize: 42.w,
                      uniquId: widget.name,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
